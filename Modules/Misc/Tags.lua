local TXUI, F, E, I, V, L, P, G = unpack((select(2, ...)))
local M = TXUI:GetModule("Misc")
local UF = E:GetModule("UnitFrames")
local ElvUF = E.oUF

local ipairs = ipairs
local select = select
local floor = math.floor
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local Abbrev = E.TagFunctions.Abbrev

function M:_TagsUpdate()
  if not F.IsTXUIProfile() then return end

  for _, unit in ipairs { "party", "arena", "boss", "pet", "player", "target", "targettarget", "focus", "raid1", "raid2", "raid3" } do
    if unit == "party" or unit:find("raid") then
      for i = 1, UF[unit]:GetNumChildren() do
        local child = select(i, UF[unit]:GetChildren())
        for x = 1, child:GetNumChildren() do
          local subchild = select(x, child:GetChildren())
          if subchild then subchild:UpdateTags() end
        end
      end
    elseif unit == "boss" or unit == "arena" then
      for i = 1, 10 do
        local unitframe = UF[unit .. i]
        if unitframe then unitframe:UpdateTags() end
      end
    else
      local unitframe = UF[unit]
      if unitframe then unitframe:UpdateTags() end
    end
  end
end

function M:TagsUpdate()
  if UF.Initialized then
    F.Event.RunNextFrame(function()
      F.Event.ContinueAfterElvUIUpdate(function()
        self:_TagsUpdate()
      end)
    end)
  elseif not self:IsHooked(UF, "Initialize") then
    self:SecureHook(UF, "Initialize", F.Event.GenerateClosure(self.TagsUpdate, self))
  end
end

-- Table for referencing which gradients should be reversed
local reverseUnitsTable = {
  ["target"] = true,
  ["focus"] = true,
  ["arena1"] = true,
  ["arena2"] = true,
  ["arena3"] = true,
  ["arena4"] = true,
  ["arena5"] = true,
  ["boss1"] = true,
  ["boss2"] = true,
  ["boss3"] = true,
  ["boss4"] = true,
  ["boss5"] = true,
  ["boss6"] = true,
  ["boss7"] = true,
  ["boss8"] = true,
}

function M:Tags()
  local classIcon = [[|TInterface\AddOns\ElvUI_ToxiUI\Media\Textures\Icons\ToxiClasses:32:32:0:0:512:512:%s|t]]
  local classIcons = {
    WARRIOR = "0:64:0:64",
    MAGE = "64:128:0:64",
    ROGUE = "128:192:0:64",
    DRUID = "192:256:0:64",
    HUNTER = "0:64:64:128",
    SHAMAN = "64:128:64:128",
    PRIEST = "128:192:64:128",
    WARLOCK = "192:256:64:128",
    PALADIN = "0:64:128:192",
    DEATHKNIGHT = "64:128:128:192",
    MONK = "128:192:128:192",
    DEMONHUNTER = "192:256:128:192",
    EVOKER = "256:320:0:64",
  }

  local function SetGradientColorMapString(name, unitClass, reverseGradient)
    if not name or name == "" then return end
    local classColorMap = E.db.TXUI.themes.gradientMode.classColorMap
    local reactionColorMap = E.db.TXUI.themes.gradientMode.reactionColorMap

    local colorMap = {}
    F.Table.Crush(colorMap, classColorMap, reactionColorMap)

    local left = colorMap[1][unitClass] -- Left (player UF)
    local right = colorMap[2][unitClass] -- Right (player UF)

    local r1, g1, b1
    local r2, g2, b2

    if E.db.TXUI.themes.gradientMode.saturationBoost then
      -- mod values taken from F.Color.GenerateCache()
      -- maybe can use instead F.Color.GetMap??
      local modS1, modL1 = 1.6, 0.6
      local modS2, modL2 = 0.9, 1

      local h1, s1, l1 = F.ConvertToHSL(left.r, left.g, left.b)
      local h2, s2, l2 = F.ConvertToHSL(right.r, right.g, right.b)

      r1, g1, b1 = F.ConvertToRGB(F.ClampToHSL(h1, s1 * modS1, l1 * modL1))
      r2, g2, b2 = F.ConvertToRGB(F.ClampToHSL(h2, s2 * modS2, l2 * modL2))
    else
      r1, g1, b1 = left.r, left.g, left.b
      r2, g2, b2 = right.r, right.g, right.b
    end

    -- Reverse color for target frame etc
    if reverseGradient then
      return E:TextGradient(name, r2, g2, b2, r1, g1, b1)
    else
      return E:TextGradient(name, r1, g1, b1, r2, g2, b2)
    end
  end

  local dm = TXUI:GetModule("ThemesDarkTransparency")

  local function FormatColorTag(str, unit, reverse)
    -- i don't fucking know, i don't see this string anywhere but otherwise get Lua errors
    if not str then return "Missing string, very bad!" end

    if UnitIsPlayer(unit) then
      local _, unitClass = UnitClass(unit)
      if E.db.TXUI.themes.darkMode.gradientName then
        return SetGradientColorMapString(str, unitClass, reverse)
      else
        local cs = ElvUF.colors.class[unitClass]
        return (cs and "|cff" .. F.String.FastRGB(cs[1], cs[2], cs[3]) .. str) or "|cffcccccc" .. str
      end
    else
      if E.db.TXUI.themes.darkMode.gradientName then
        local reaction = UnitReaction(unit, "player")
        if reaction then
          if reaction >= 5 then
            return SetGradientColorMapString(str, "GOOD", reverse)
          elseif reaction == 4 then
            return SetGradientColorMapString(str, "NEUTRAL", reverse)
          elseif reaction <= 3 and reaction > 0 then
            return SetGradientColorMapString(str, "BAD", reverse)
          end
        end
      else
        local cr = ElvUF.colors.reaction[UnitReaction(unit, "player")]
        return (cr and "|cff" .. F.String.FastRGB(cr[1], cr[2], cr[3]) .. str) or "|cffcccccc" .. str
      end
    end
  end

  -- Name tags
  local nameLength = { veryshort = 5, short = 10, medium = 15, long = 20 }
  for textFormat, length in pairs(nameLength) do
    E:AddTag(format("tx:name:%s", textFormat), "UNIT_NAME_UPDATE PLAYER_TARGET_CHANGED UNIT_FACTION INSTANCE_ENCOUNTER_ENGAGE_UNIT UNIT_FACTION", function(unit)
      local name = UnitName(unit)
      if not name then return "missing name wtf" end

      if not dm.isEnabled then
        if name then return E:ShortenString(name, length) end
      end

      local reverseGradient = reverseUnitsTable[unit]
      return FormatColorTag(name, unit, reverseGradient)
    end)

    E:AddTag(format("tx:name:abbrev:%s", textFormat), "UNIT_NAME_UPDATE PLAYER_TARGET_CHANGED UNIT_FACTION INSTANCE_ENCOUNTER_ENGAGE_UNIT", function(unit)
      local name = UnitName(unit)
      if name and strfind(name, "%s") then name = Abbrev(name) end

      if not dm.isEnabled then
        if name then return E:ShortenString(name, length) end
      end

      local reverseGradient = reverseUnitsTable[unit]
      return FormatColorTag(name, unit, reverseGradient)
    end)
  end

  -- Health tags
  E:AddTag("tx:perhp", "UNIT_HEALTH PLAYER_TARGET_CHANGED UNIT_FACTION UNIT_MAXHEALTH", function(unit)
    local max = UnitHealthMax(unit)
    local health

    if max == 0 then
      health = 0
    else
      health = floor(UnitHealth(unit) / max * 100 + 0.5)
    end

    if not dm.isEnabled then return health end

    -- convert health to string
    local healthStr = tostring(health)

    local reverseGradient = reverseUnitsTable[unit]
    return FormatColorTag(healthStr, unit, not reverseGradient)
  end)

  E:AddTag("tx:health:current:shortvalue", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED", function(unit)
    local status = not UnitIsFeignDeath(unit) and UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
    if status then
      return status
    else
      local min, max = UnitHealth(unit), UnitHealthMax(unit)
      local health = E:GetFormattedText("CURRENT", min, max, nil, true)

      if not dm.isEnabled then return health end

      local reverseGradient = reverseUnitsTable[unit]
      return FormatColorTag(health, unit, not reverseGradient)
    end
  end)

  -- Power Tag
  E:AddTag("tx:power", "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit)
    local power = floor(UnitPower(unit) / max * 100 + 0.5)

    if not dm.isEnabled then
      if max ~= 0 then return power end
    end

    local powerStr = tostring(power)

    local reverseGradient = reverseUnitsTable[unit]
    if max ~= 0 then return FormatColorTag(powerStr, unit, reverseGradient) end
  end)

  -- Class Icon Tag
  E:AddTag("tx:classicon", "PLAYER_TARGET_CHANGED", function(unit)
    if UnitIsPlayer(unit) then
      local _, class = UnitClass(unit)
      local icon = classIcons[class]
      if icon then return format(classIcon, icon) end
    end
  end)

  -- Tag info
  E:AddTagInfo("tx:name:veryshort", TXUI.Title, "Displays the name of the unit with " .. TXUI.Title .. " colors. (limited to 5 letters)")
  E:AddTagInfo("tx:name:short", TXUI.Title, "Displays the name of the unit with " .. TXUI.Title .. " colors. (limited to 10 letters)")
  E:AddTagInfo("tx:name:medium", TXUI.Title, "Displays the name of the unit with " .. TXUI.Title .. " colors. (limited to 15 letters)")
  E:AddTagInfo("tx:name:long", TXUI.Title, "Displays the name of the unit with " .. TXUI.Title .. " colors. (limited to 20 letters)")

  E:AddTagInfo("tx:name:abbrev:veryshort", TXUI.Title, "Displays the name of the unit with abbreviation and " .. TXUI.Title .. " colors. (limited to 5 letters)")
  E:AddTagInfo("tx:name:abbrev:short", TXUI.Title, "Displays the name of the unit with abbreviation and " .. TXUI.Title .. " colors. (limited to 10 letters)")
  E:AddTagInfo("tx:name:abbrev:medium", TXUI.Title, "Displays the name of the unit with abbreviation and " .. TXUI.Title .. " colors. (limited to 15 letters)")
  E:AddTagInfo("tx:name:abbrev:long", TXUI.Title, "Displays the name of the unit with abbreviation and " .. TXUI.Title .. " colors. (limited to 20 letters)")

  E:AddTagInfo("tx:perhp", TXUI.Title, "Displays percentage HP of unit without decimals or the % sign. Also adds " .. TXUI.Title .. " colors.")
  E:AddTagInfo("tx:health:current:shortvalue", TXUI.Title, "Shortvalue of the unit's current health (e.g. 81k instead of 81200). Also adds " .. TXUI.Title .. " colors.")

  E:AddTagInfo(
    "tx:power",
    TXUI.Title,
    "Displays percentage Power of unit without decimals or the % sign. Also adds " .. TXUI.Title .. " colors and does not display when Power is at 0."
  )

  E:AddTagInfo("tx:classicon", TXUI.Title, "Displays " .. TXUI.Title .. " class icon.")

  -- Settings Callback
  F.Event.RegisterCallback("Tags.DatabaseUpdate", self.TagsUpdate, self)
  F.Event.RegisterCallback("TXUI.DatabaseUpdate", self.TagsUpdate, self)
  F.Event.RegisterOnceCallback("TXUI.InitializedSafe", F.Event.GenerateClosure(self.TagsUpdate, self))
end

M:AddCallback("Tags")
