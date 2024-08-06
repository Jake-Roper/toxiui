local TXUI, F, E, I, V, P, G = unpack((select(2, ...)))

TXUI.Changelog["6.7.8"] = {
  HOTFIX = true,
  CHANGES = {
    "* Breaking changes",

    "* New features",
    "Add Korean glyphs to fonts used in ToxiUI" .. F.String.Sublist("Credits to bbingr"),
    F.String.Class("Class") .. " background option in " .. F.String.Menu.Armory(),
    "Show labels option for Mythic+ flyout in " .. F.String.Menu.WunderBar(),

    "* Bug fixes",
    "Fix error with Game Menu skin when background fade is disabled",
    "Fix Spellbook scaling for Retail",

    "* Profile updates",

    "* Documentation",

    "* Settings refactoring",
    "Move Talents frame scaling to Classic only",

    "* Development improvements",
  },
}