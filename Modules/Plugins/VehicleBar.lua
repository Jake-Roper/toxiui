local TXUI, F, E, I, V, P, G = unpack((select(2, ...)))
local VB = TXUI:NewModule("VehicleBar", "AceHook-3.0")
local LAB = LibStub("LibActionButton-1.0-ElvUI")

-- Globals
local CreateFrame = CreateFrame
local format = string.format
local GetOverrideBarIndex = GetOverrideBarIndex
local GetVehicleBarIndex = GetVehicleBarIndex
local InCombatLockdown = InCombatLockdown
local ipairs = ipairs
local pairs = pairs
local RegisterStateDriver = RegisterStateDriver
local strsplit = strsplit
local UnregisterStateDriver = UnregisterStateDriver

function VB:StopAllAnimations()
  if self.bar.SlideIn and (self.bar.SlideIn.SlideIn:IsPlaying()) then self.bar.SlideIn.SlideIn:Finish() end

  for _, button in ipairs(self.bar.buttons) do
    if button.FadeIn and (button.FadeIn:IsPlaying()) then
      button.FadeIn:Stop()
      button:SetAlpha(1)
    end
  end
end

function VB:SetupButtonAnim(button, index)
  local iconFade = (1 * self.db.animationsMult)
  local iconHold = (index * 0.10) * self.db.animationsMult

  button.FadeIn = button.FadeIn or TXUI:CreateAnimationGroup(button)

  button.FadeIn.ResetFade = button.FadeIn.ResetFade or button.FadeIn:CreateAnimation("Fade")
  button.FadeIn.ResetFade:SetDuration(0)
  button.FadeIn.ResetFade:SetChange(0)
  button.FadeIn.ResetFade:SetOrder(1)

  button.FadeIn.Hold = button.FadeIn.Hold or button.FadeIn:CreateAnimation("Sleep")
  button.FadeIn.Hold:SetDuration(iconHold)
  button.FadeIn.Hold:SetOrder(2)

  button.FadeIn.Fade = button.FadeIn.Fade or button.FadeIn:CreateAnimation("Fade")
  button.FadeIn.Fade:SetEasing("out-quintic")
  button.FadeIn.Fade:SetChange(1)
  button.FadeIn.Fade:SetDuration(iconFade)
  button.FadeIn.Fade:SetOrder(3)
end

function VB:OnShowEvent()
  self:StopAllAnimations()

  local animationsAllowed = self.db.animations and (not InCombatLockdown()) and not self.combatLock

  if animationsAllowed then
    for i, button in ipairs(self.bar.buttons) do
      self:SetupButtonAnim(button, i)
    end
  end

  for _, button in ipairs(self.bar.buttons) do
    if animationsAllowed then
      button:SetAlpha(0)
      button.FadeIn:Play()
    else
      button:SetAlpha(1)
    end
  end

  -- Update keybinds when the bar is shown
  self:UpdateKeybinds()
end

function VB:OnCombatEvent(toggle)
  self.combatLock = toggle
  if self.combatLock then self:StopAllAnimations() end
end

-- Function to format keybind with class color for modifier
local function FormatKeybind(keybind)
  local modifier, key = keybind:match("^(%w)-(.+)$")
  if modifier and key then
    if E.db.TXUI.addons.colorModifiers.enabled then
      local color = E:ClassColor(E.myclass, true)
      local r, g, b = color.r, color.g, color.b
      return string.format("|cff%02x%02x%02x%s|r%s", r * 255, g * 255, b * 255, modifier:upper(), key)
    else
      return modifier:upper() .. key
    end
  else
    return keybind
  end
end

-- Function to update keybinds
function VB:UpdateKeybinds()
  for i, button in ipairs(self.bar.buttons) do
    local buttonIndex = (i == 8) and 12 or i
    local actionButton = _G["ActionButton" .. buttonIndex]
    if actionButton then
      local keybind = GetBindingKey("ACTIONBUTTON" .. buttonIndex)
      if keybind then
        button.HotKey:SetTextColor(1, 1, 1)
        button.HotKey:SetText(FormatKeybind(GetBindingText(keybind, "KEY_", 1)))
        button.HotKey:Show()
      else
        button.HotKey:Hide()
      end
    end
  end
end

function VB:UpdateBar()
  -- Vars
  local size = 48
  local spacing = 2

  -- Create or get bar
  local init = self.bar == nil
  local bar = self.bar or CreateFrame("Frame", "TXUIVehicleBar", E.UIParent, "SecureHandlerStateTemplate")

  -- Default position
  local point, anchor, attachTo, x, y = strsplit(",", F.Position(strsplit(",", self.db.position)))
  bar:SetPoint(point, anchor, attachTo, x, y)

  -- Set bar vars
  self.bar = bar
  self.bar.id = 1

  -- Page Handling
  bar:SetAttribute(
    "_onstate-page",
    [[
        newstate = ((HasTempShapeshiftActionBar() and self:GetAttribute("hasTempBar")) and GetTempShapeshiftBarIndex())
        or (UnitHasVehicleUI("player") and GetVehicleBarIndex())
        or (HasOverrideActionBar() and GetOverrideBarIndex())
        or newstate

        if not newstate then
            return
        end

        if newstate ~= 0 then
            self:SetAttribute("state", newstate)
            control:ChildUpdate("state", newstate)
        else
            local newCondition = self:GetAttribute("newCondition")
            if newCondition then
                newstate = SecureCmdOptionParse(newCondition)
                self:SetAttribute("state", newstate)
                control:ChildUpdate("state", newstate)
            end
        end
    ]]
  )

  -- Create Buttons
  if not bar.buttons then
    bar.buttons = {}

    for i = 1, 8 do
      local buttonIndex = (i == 8) and 12 or i

      -- Create button
      local button = LAB:CreateButton(buttonIndex, "TXUIVehicleBarButton" .. buttonIndex, bar, nil)

      -- Set state aka actions
      button:SetState(0, "action", buttonIndex)
      for k = 1, 18 do
        button:SetState(k, "action", (k - 1) * 12 + buttonIndex)
      end
      if buttonIndex == 12 then button:SetState(12, "custom", self.ab.customExitButton) end

      -- Style
      self.ab:StyleButton(button, nil, nil)
      button:SetTemplate("Transparent")
      button:SetCheckedTexture("")
      button.MasqueSkinned = true -- Ugly fix for smaller cooldowns, not actually using Masque

      -- Adjust the count position
      button.Count:ClearAllPoints()
      button.Count:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 2)

      -- Add to array
      bar.buttons[i] = button
    end
  end

  -- Calculate Bar Width/Height
  local width = (size * 8) + (spacing * (8 - 1)) + 4
  bar:SetWidth(width)
  bar:SetHeight((width / 4 * 3))

  -- Update button position and size
  for i, button in ipairs(bar.buttons) do
    button:SetSize(size, size / 4 * 3)
    button:ClearAllPoints()

    if i == 1 then
      button:SetPoint("BOTTOMLEFT", 2, 2)
    else
      button:SetPoint("LEFT", bar.buttons[i - 1], "RIGHT", spacing, 0)
    end
  end

  -- Update Paging
  if not TXUI.IsVanilla then
    local pageState = format(
      "[overridebar] %d; [vehicleui] %d; [possessbar] %d; [shapeshift] 13; %s",
      GetOverrideBarIndex(),
      GetVehicleBarIndex(),
      GetVehicleBarIndex(),
      (self.db.dragonRiding and "[bonusbar:5] 11;") or ""
    )
    local pageAttribute = self.ab:GetPage("bar1", 1, pageState)
    RegisterStateDriver(bar, "page", pageAttribute)
    self.bar:SetAttribute("page", pageAttribute)
  end

  -- ElvUI Bar config
  self.ab:UpdateButtonConfig("bar1", "ACTIONBUTTON")
  self.ab:PositionAndSizeBar("bar1")

  -- Hook for animation
  self:SecureHookScript(bar, "OnShow", "OnShowEvent")

  -- Hide
  bar:Hide()

  -- Only run after first creation
  if init then
    -- Create Mover
    E:CreateMover(bar, "ToxiUIVehicleBar", TXUI.Title .. " Vehicle Bar")

    -- Force update
    for _, button in pairs(bar.buttons) do
      button:UpdateAction()
    end

    -- Initial call to update keybinds
    self:UpdateKeybinds()
  end
end

function VB:Disable()
  if not self.Initialized then return end

  self:UnhookAll()

  if self.bar then
    self:StopAllAnimations()

    UnregisterStateDriver(self.bar, "visibility")
    UnregisterStateDriver(self.ab["handledBars"]["bar1"], "visibility")
    RegisterStateDriver(self.ab["handledBars"]["bar1"], "visibility", E.db.actionbar["bar1"].visibility)

    self.bar:Hide()
  end

  F.Event.UnregisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self)
  F.Event.UnregisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self)
end

function VB:Enable()
  if not self.Initialized and E.private.actionbar.enable then return end

  -- Update or create bar
  self:UpdateBar()

  -- Overwrite default bar visibility
  local visibility = format("[petbattle] hide; [vehicleui][overridebar][shapeshift][possessbar]%s hide;", (self.db.dragonRiding and "[bonusbar:5]") or "")

  self:Hook(self.ab, "PositionAndSizeBar", function(_, barName)
    local bar = self.ab["handledBars"][barName]
    if E.db.actionbar[barName].enabled and (barName == "bar1") then
      UnregisterStateDriver(bar, "visibility")
      RegisterStateDriver(bar, "visibility", visibility .. E.db.actionbar[barName].visibility)
    end
  end)

  -- Unregister/Register State Driver
  UnregisterStateDriver(self.bar, "visibility")
  UnregisterStateDriver(self.ab["handledBars"]["bar1"], "visibility")

  RegisterStateDriver(
    self.bar,
    "visibility",
    format("[petbattle] hide; [vehicleui][overridebar][shapeshift][possessbar]%s show; hide", (self.db.dragonRiding and "[bonusbar:5]") or "")
  )
  RegisterStateDriver(self.ab["handledBars"]["bar1"], "visibility", visibility .. E.db.actionbar["bar1"].visibility)

  -- Register Events
  F.Event.RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self.OnCombatEvent, self, false)
  F.Event.RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self.OnCombatEvent, self, true)
end

function VB:DatabaseUpdate()
  -- Disable
  self:Disable()

  -- Set db
  self.db = F.GetDBFromPath("TXUI.vehicleBar")

  -- Enable only out of combat
  F.Event.ContinueOutOfCombat(function()
    if TXUI:HasRequirements(I.Requirements.VehicleBar) and (self.db and self.db.enabled) and E.private.actionbar.enable then self:Enable() end
  end)
end

function VB:Initialize()
  -- Don't init second time
  if self.Initialized then return end

  -- Vars
  self.combatLock = false
  self.ab = E:GetModule("ActionBars")

  -- Register for updates
  F.Event.RegisterOnceCallback("TXUI.InitializedSafe", F.Event.GenerateClosure(self.DatabaseUpdate, self))
  F.Event.RegisterCallback("TXUI.DatabaseUpdate", self.DatabaseUpdate, self)
  F.Event.RegisterCallback("VehicleBar.DatabaseUpdate", self.DatabaseUpdate, self)
  F.Event.RegisterCallback("VehicleBar.SettingsUpdate", self.UpdateBar, self)

  -- We are done, hooray!
  self.Initialized = true
end

TXUI:RegisterModule(VB:GetName())
