local TXUI, F, E, I, V, P, G = unpack((select(2, ...)))

TXUI.Changelog["6.5.9"] = {
  HOTFIX = true,
  CHANGES = {
    "* Breaking changes",
    "Remove " .. F.String.NameplateSCT() .. " profiles",

    "* New features",
    TXUI.Title
      .. " Debug Mode" --
      .. F.String.Sublist("Inspired by " .. F.String.ElvUI() .. "'s Debug Mode")
      .. F.String.Sublist("Chat command: /tx debug [on/off]"),
    "Add " --
      .. TXUI.Title
      .. " Class Icons to "
      .. F.String.Details()
      .. " Icon select dropdown!"
      .. F.String.Sublist("/details config -> Bars: General -> Icons -> Texture"),
    "Add Health Coloring to UnitFrames" --
      .. F.String.Sublist("Enabled by default")
      .. F.String.Sublist("Only works in " .. F.String.GradientString() .. " mode")
      .. F.String.Sublist("All information and options can be found under " .. F.String.FastGradientHex("Themes", "#73e8ff", "#0086c3") .. " -> Gradient Mode -> Settings"),
    "Add " .. F.String.ToxiUI("Equipment Sets") .. " DataText from " .. F.String.ElvUI() .. " to WunderBar",

    "* Bug fixes",
    "Add safety checks and fallbacks to F.Color.SetGradient",

    "* Profile updates",
    "Update Plater colors to match UnitFrames more closely",
    "Make Details windows wider" --
      .. F.String.Sublist("In some edge cases the name string would get too long to fit and cause all sorts of various bugs"),

    "* Documentation",
    F.String.MinElv("13.61"),

    "* Settings refactoring",
    "Rename " --
      .. F.String.ToxiUI("DPS/Tank")
      .. " and "
      .. F.String.Class("Healer", "MONK")
      .. " layouts to "
      .. F.String.ToxiUI("Vertical")
      .. " and "
      .. F.String.Class("Horizontal", "MONK")
      .. " respectively",
    "Add images to Core Settings page of installer",
    "Refactor Additional AddOns page's images" --
      .. F.String.Sublist("Images show only for the loaded AddOns"),

    "* Development improvements",
    "Internally rename Classic & Classic Era to Vanilla",
  },
}