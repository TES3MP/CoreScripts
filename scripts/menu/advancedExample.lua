Menus["advanced example origin"] = {
    text = color.Orange .. "This is an example of an advanced menu. Use it as a starting point for your own.\n\n" ..
                color.White .. "Select an object whose functions you want to run.",
    buttons = {
        { caption = "This player",
            destinations = { menuHelper.destinations.setDefault("advanced example player") }
        },
        { caption = "The world instance",
            destinations = { menuHelper.destinations.setDefault("advanced example world") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["advanced example player"] = {
    text = color.Orange .. "Select a function to run on this player.",
    buttons = {
        { caption = "Save()",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                {
                    menuHelper.effects.runPlayerFunction("Save")
                })
            }
        },
        { caption = "Message(\"This is a test\n\")",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                {
                    menuHelper.effects.runPlayerFunction("Message", {"This is a test\n"})
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["advanced example world"] = {
    text = color.Orange .. "Select a function to run on this world.",
    buttons = {
        { caption = "IncrementDay() and LoadTime(nil, true)",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                {
                    menuHelper.effects.runGlobalFunction("WorldInstance", "IncrementDay"),
                    menuHelper.effects.runGlobalFunction("WorldInstance", "LoadTime", {nil, true})
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}
