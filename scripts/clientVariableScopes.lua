-- Place clientside variables in different categories to decide how they are synchronized,
-- saved and loaded
--
-- Note: Currently, only global variables are handled, not local or member variables
--
-- Descriptions:
-- * "ignored" is where you place variables that clients should not send packets about,
--   either because they are already handled in other packets or because they would cause
--   unnecessary packet spam
-- * "personal" is where you place variables that are always exclusive to specific players
--   and that should not be shared regardless of other server options
-- * "quest" is where you place variables that should be synchronized and shared across
--   players based on the value of config.shareJournal
-- * "kills" is where you place variables that should be handled the same as kill counts
--   and should be cleared whenever the regular kill counts are
-- * "faction" is where you place variables that should be synchronized and shared across
--   players based on the value of config.shareFactionRanks
-- * "worldwide" is where you place variables that are always shared across all players
--   because they affect the physical world in a way that should be visible to everyone,
--   i.e. they affect structures, mechanism states, water levels, and so on
local clientVariableScopes = {
    globals = {}
}

if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Morrowind.esm") then

    local addedVariableScopes = {
        globals = {
            ignored = {
                -- game state
                "random100",
                -- game settings
                "npcvoicedistance",
                -- time
                "gamehour", "timescale", "month", "day", "year",
                -- player character details
                "pcrace",
                -- player state
                "chargenstate", "pchascrimegold", "crimegolddiscount", "crimegoldturnin", "pchasgolddiscount",
                "pchasturnin",
                -- player equipment
                "wearinglegionuni", "wearingordinatoruni", "wearinghelmhhda", "wraithguardequipped", "tgglove",
                -- faction expulsion
                "expredoran", "expmagesguild", "expfightersguild", "exptemple", "expmoragtong", "expimperialcult",
                "expimperiallegion", "expthievesguild",
                -- quest variables that are already set correctly without being synced
                "fargothwalk"
            },
            personal = {
                -- player state
                "pcvampire",
                -- tavern rents
                "rent_pelagiad_halfway", "rent_smora_gateway", "rent_smora_faras", "rent_ebon_six", "rent_balmora_south",
                "rent_balmora_council", "rent_balmora_lucky", "rent_aldruhn_skar", "rent_telaruhn_plot", "rent_telbran_sethan",
                "rent_telmora_covenant", "rent_vos_varo", "rent_balmora_eight", "rent_caldera_shenk", "rent_maargan_andus",
                "rent_vivec_lizard", "rent_vivec_flower", "rent_vivec_black", "rent_ghost_dusk",
                -- miscellaneous variables related to player-specific actions
                "chargenbreadstate"
            },
            quest = {
                -- main quest
                "hortatorvotes", "heartdestroyed", "destroyblight",
                -- reading of confidential documents
                "unsealededryno1", "unsealedodral1",
                -- assassination quests
                -- Note: These are related to kill counts, but they make more sense being shared across
                --       players who share quests than being shared across players who share kills
                "mt_legitkills", "mt_newcrimelevel", "mt_writdiscount",
                -- side quests for rescues
                "freedslavescounter", "madurarescued",
                -- other side quests
                "threadswebspinner", "monopolyvotes", "bone"
            },
            kills = {
                -- main quest
                "redoranmurdered", "telvannidead",
                -- side quests
                "ratskilled", "vampkills"
            },
            faction = {
                "vampclan"
            },
            worldwide = {
                -- mechanisms
                "gg_gate1_state", "gg_gate2_state",
                -- building construction
                "stronghold",
                -- whether duel arenas are occupied
                "duelactive"
            },
            unknown = {
                "ownershiphhcs", "abelmawiacounter"
            }
        }
    }

    tableHelper.merge(clientVariableScopes, addedVariableScopes, true)
end

if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Tribunal.esm") then

    local addedVariableScopes = {
        globals = {
            ignored = {
                -- player state
                "pcgold",
                -- quest variables that are already set correctly without being synced
                "mercenarynear"
            },
            personal = {
                -- tavern rent
                "rent_mh_guar",
                -- mercenary contracts
                "contractcalvusday", "contractcalvusmonth", "contract_calvus_days_left",
                -- fights started
                "kinghit"
            },
            quest = {
                -- main quest
                "dbattack", "mournholdattack", "fabattack", "shrinecleanse", "bladefix", "hasblade", "kgaveblade",
                "duelmiss", "karrodbribe", "karrodbeaten", "karrodfightstart", "karrodcheapshot",
                -- side quests
                "plaguerock", "plagueactivate", "plaguestage", "droth_var", "museumdonations", "matchmakeswitch",
                "matchmakefons", "matchmakegoval", "matchmakesunel"
            },
            kills = {
                -- main quest
                "gobchiefdead", "helsassdead"
            },
            worldwide = {
                -- weather overrides
                "mournweather"
            }
        }
    }

    tableHelper.merge(clientVariableScopes, addedVariableScopes, true)
end

if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Bloodmoon.esm") then

    local addedVariableScopes = {
        globals = {
            ignored = {
                -- player state
                "pcwerewolf",
                -- quest variables that are already set correctly without being synced
                "trackerpause"
            },
            personal = {
                -- player state
                "pcknownreset",
                -- tavern rents
                "rent_ravenrock"
            },
            quest = {
                -- main quest
                "foundbooze", "artoriachosen", "luciuschosen", "stones", "part", "aesliptalk", "skaalattack", "trackercount",
                "huntercount", "cariustalk",
                -- Raven Rock
                "colonyside", "maryndetect", "colonystock"
            },
            kills = {
                -- main quest
                "smugdead", "riekkilled", "deaddaedra", "caenlorndead", "werewolfdead", "werebdead", "huntersdead",
                "trackersdead", "trollsdead", "krishcount",
                -- side quests
                "draugrkilled", "colonynord"
            },
            worldwide = {
                -- building construction
                "colonystate",
                -- NPCs present
                "colonyservice", "carniusloc", "aferguard", "garnasguard", "gratianguard"
            }
        }
    }

    tableHelper.merge(clientVariableScopes, addedVariableScopes, true)
end

return clientVariableScopes
