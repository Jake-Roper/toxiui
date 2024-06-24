local TXUI, F, E, I, V, P, G = unpack((select(2, ...)))

TXUI.Changelog["6.7.0"] = {
  HOTFIX = true,
  CHANGES = {
    "* Breaking changes",

    "* New features",
    TXUI.Title
      .. " Specialization icons for UnitFrames & Details!"
      .. F.String.Sublist("UnitFrame icons are available only for Retail due to API constraints")
      .. F.String.Sublist("Change in " .. TXUI.Title .. " -> " .. F.String.Menu.Skins() .. " -> " .. F.String.Class("Class ") .. "Icons"),
    "Add Line Height option for " .. F.String.Menu.Armory() .. " decorative lines",
    "Add " .. F.String.Class("Gradient Class color") .. " option for " .. F.String.Menu.Armory() .. " decorative lines",
    "Vehicle Bar updates:" --
      .. F.String.Sublist("Display 8 buttons instead of 7")
      .. F.String.Sublist("Increase button size")
      .. F.String.Sublist("Display keybindings")
      .. F.String.Sublist("Keybindings respect the Color Modifiers setting")
      .. F.String.Sublist("Remove stuck animation of moving up"),
    "Vigor (Dragonriding) bar for Vehicle Bar",
    "Button width option for Vehicle Bar",
    "Redesigned AFK screen",

    "* Bug fixes",
    "Improve fallback colors for F.Color.SetGradient",
    "Update " .. TXUI.Title .. " class icon on spec change",

    "* Profile updates",
    "Update default Hunter's shift color",

    "* Documentation",

    "* Settings refactoring",
    "Class Icons now have their own dedicated tab" .. F.String.Sublist(TXUI.Title .. " -> " .. F.String.Menu.Skins() .. " -> " .. F.String.Class("Class ") .. "Icons"),
    "Rename Miscellaneous tab to " .. F.String.Menu.Plugins(),

    "* Development improvements",
    "Add string functions for " .. TXUI.Title .. " settings menu names",
    "Remove Priest color overrides" .. F.String.Sublist("It never worked correctly and caused more issues than benefits"),
  },
}