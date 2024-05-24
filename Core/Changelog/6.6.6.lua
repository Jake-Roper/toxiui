local TXUI, F, E, I, V, P, G = unpack((select(2, ...)))

TXUI.Changelog["6.6.6"] = {
  HOTFIX = true,
  CHANGES = {
    "* Breaking changes",

    "* New features",
    "Additional Scaling for Item Upgrade & Catalyst UIs",
    "Add Additional Scaling button to Reset section",
    "Abbreviate Level text option in Armory",

    "* Bug fixes",
    "Show Missing Belt enchant in Armory",

    "* Profile updates",
    "Fix Raid 2 not seeing 6th group",

    "* Documentation",
    "Update Disenchant exlude list for Deconstruct",
    "Increase max level in Cata",

    "* Settings refactoring",

    "* Development improvements",
    F.String.MinElv("13.65"),
  },
}
