Menus["default crafting origin"] = {
    text = color.Orange .. "What would you like to craft?\n" ..
            color.Yellow .. "White pillow" .. color.White .. " - 1 per 2 folded cloth\n" ..
            color.Yellow .. "Hammock pillow" .. color.White .. " - 15 per 1 bolt of cloth\n" ..
            color.Yellow .. "Guarskin drum" .. color.White .. " - 1 per 3 guar hides",
    buttons = {
        { caption = "White pillow",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("default crafting pillow white",
                {
                    menuHelper.conditions.requireItem("misc_de_foldedcloth00", 2)
                })
            }
        },
        { caption = "Hammock pillow",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("default crafting pillow hammock",
                {
                    menuHelper.conditions.requireItem({"misc_clothbolt_01", "misc_clothbolt_02", "misc_clothbolt_03"}, 1)
                })
            }
        },
        { caption = "Guarskin drum",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("default crafting drum guarskin",
                {
                    menuHelper.conditions.requireItem("ingred_guar_hide_01", 3)
                })
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["default crafting pillow white"] = {
    text = "How many would you like to craft?",
    buttons = {
        { caption = "1",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("reward generic singular",
                {
                    menuHelper.conditions.requireItem("misc_de_foldedcloth00", 2)
                },
                {
                    menuHelper.effects.removeItem("misc_de_foldedcloth00", 2),
                    menuHelper.effects.giveItem("misc_uni_pillow_01", 1)
                })
            }
        },
        { caption = "5",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("reward generic plural",
                {
                    menuHelper.conditions.requireItem("misc_de_foldedcloth00", 10)
                },
                {
                    menuHelper.effects.removeItem("misc_de_foldedcloth00", 10),
                    menuHelper.effects.giveItem("misc_uni_pillow_01", 5)
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setDefault("default crafting origin") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["default crafting pillow hammock"] = {
    text = "How many would you like to craft?",
    buttons = {
        { caption = "15",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("reward generic plural",
                {
                    menuHelper.conditions.requireItem({"misc_clothbolt_01", "misc_clothbolt_02", "misc_clothbolt_03"}, 1)

                },
                {
                    menuHelper.effects.removeItem({"misc_clothbolt_01", "misc_clothbolt_02", "misc_clothbolt_03"}, 1),
                    menuHelper.effects.giveItem("Misc_Uni_Pillow_02", 15)
                })
            }
        },
        { caption = "60",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("reward generic plural",
                {
                    menuHelper.conditions.requireItem({"misc_clothbolt_01", "misc_clothbolt_02", "misc_clothbolt_03"}, 4)
                },
                {
                    menuHelper.effects.removeItem({"misc_clothbolt_01", "misc_clothbolt_02", "misc_clothbolt_03"}, 4),
                    menuHelper.effects.giveItem("Misc_Uni_Pillow_02", 60)
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setDefault("default crafting origin") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["default crafting drum guarskin"] = {
    text = "How many would you like to craft?",
    buttons = {
        { caption = "1",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("reward generic singular",
                {
                    menuHelper.conditions.requireItem("ingred_guar_hide_01", 3)
                },
                {
                    menuHelper.effects.removeItem("ingred_guar_hide_01", 3),
                    menuHelper.effects.giveItem("misc_de_drum_02", 1)
                })
            }
        },
        { caption = "5",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("reward generic plural",
                {
                    menuHelper.conditions.requireItem("ingred_guar_hide_01", 15)
                },
                {
                    menuHelper.effects.removeItem("ingred_guar_hide_01", 15),
                    menuHelper.effects.giveItem("misc_de_drum_02", 5)
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setDefault("default crafting origin") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["lack of materials"] = {
    text = "You lack the materials required.",
    buttons = {
        { caption = "Back", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Ok", destinations = nil }
    }
}

Menus["reward generic singular"] = {
    text = "Congratulations! The item is now yours",
    buttons = {
        { caption = "Craft more", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["reward generic plural"] = {
    text = "Congratulations! The items are now yours",
    buttons = {
        { caption = "Craft more", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}
