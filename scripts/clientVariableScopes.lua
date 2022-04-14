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
-- * "factionRanks" is where you place variables that should be synchronized and shared across
--   players based on the value of config.shareFactionRanks
-- * "factionExpulsion" is where you place variables that should be synchronized and shared across
--   players based on the value of config.shareFactionExpulsion
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
                -- quest variables that are already set correctly without being synced
                "fargothwalk",
                -- not actually used at all
                "abelmawiacounter"
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
                "threadswebspinner", "monopolyvotes", "bone", "ownershiphhcs"
            },
            kills = {
                -- main quest
                "redoranmurdered", "telvannidead",
                -- side quests
                "ratskilled", "vampkills"
            },
            factionRanks = {
                -- membership in mini-factions
                "vampclan"
            },
            factionExpulsion = {
                -- faction expulsion forgiveness and timers
                "expredoran", "expmagesguild", "expfightersguild", "exptemple", "expmoragtong", "expimperialcult",
                "expimperiallegion", "expthievesguild"
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

if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Tamriel_Data.ESM") then

    local addedVariableScopes = {
        globals = {
            ignored = {
                -- game state
                "TR_MapPos", "TR_CellX", "TR_CellY", "TR_Test", "PC_NoLore", "T_Glob_cleanup_x", "T_Glob_cleanup_y", 
                "T_Glob_cleanup_z", "T_Glob_cleanup_state", "T_Glob_DWelk_cleanup", "T_Glb_GetTeleportingDisabled", 
                "T_Glob_PassTimeHours", "T_Glob_GetTeleportingDisabled", "T_Glob_Speech_Debug", "T_Glob_Speech_Sway", 
                "T_Glob_Speech_Haggle", "T_Glob_Speech_Debate", 
                
                -- card game
                "T_Glob_CardHortX", "T_Glob_CardHortY",    "T_Glob_CardHortZ", "T_Glob_CardHortReshapeX", "T_Glob_CardHortReshapeY",
                "T_Glob_CardHortCol1Len", "T_Glob_CardHortCol2Len", "T_Glob_CardHortCol3Len", "T_Glob_CardHortCol4Len",
                "T_Glob_CardHortCol5Len", "T_Glob_CardHortCol6Len", "T_Glob_CardHortCol1Lock", "T_Glob_CardHortCol2Lock", 
                "T_Glob_CardHortCol3Lock", "T_Glob_CardHortCol4Lock", "T_Glob_CardHortCol5Lock", "T_Glob_CardHortCol6Lock",
                "T_Glob_CardHortCol1Lock2", "T_Glob_CardHortCol2Lock2", "T_Glob_CardHortCol3Lock2", "T_Glob_CardHortCol4Lock2", 
                "T_Glob_CardHortCol5Lock2", "T_Glob_CardHortCol6Lock2", "T_Glob_CardHortSaveLoad", "T_Glob_CardHortActiveLen",
                "T_Glob_CardHortTop", "T_Glob_CardHortDummy", "T_Glob_CardHortState", "T_Glob_CardHortTracker", "T_Glob_CardHortRow",
                "T_Glob_CardHortRot", "T_Glob_CardHortRank", "T_Glob_CardHortCol", "T_Glob_CardHortHouse"
                
            },
            personal = {
                -- player state
                "T_Glob_PorphyricInfected", "T_Glob_WereInfected",
                
                -- Bank accounts
                "T_Glob_Bank_All_CurrentBank", "T_Glob_Bank_Bri_AcctAmount", "T_Glob_Bank_Bri_LoanAmount",
                "T_Glob_Bank_Bri_LoanDate", "T_Glob_Bank_Bri_LoanFail", "T_Glob_Bank_Hla_LoanFail", "T_Glob_Bank_Hla_AcctAmount",
                "T_Glob_Bank_Hla_LoanAmount", "T_Glob_Bank_Hla_LoanDate",
                
            },
            quest = {
                -- reputation
                "T_Glob_Rep_Sky_Pr", "T_Glob_Rep_Sky_Re"
            },
            kills = {
            
            },
            factionRanks = {
                
            },
            factionExpulsion = {
                
            },
            worldwide = {
                -- mechanisms
                "T_Glob_SutchElevDir", "T_Glob_SutchElevRest", "T_Glob_SutchElevUpDownCounter",
                -- objects
                "T_Glob_KingOrgCoffer_Uses",
                -- news
                "T_Glob_News_Bellman_Pick1", "T_Glob_News_Bellman_Pick2", "T_Glob_News_Bellman_Tracker1", "T_Glob_News_Bellman_Tracker2"                
            },
            unknown = {
                
            }
        }
    }
    
    tableHelper.merge(clientVariableScopes, addedVariableScopes, true)
end

if tableHelper.containsCaseInsensitiveString(clientDataFiles, "TR_Mainland.ESM") then

    local addedVariableScopes = {
        globals = {
            ignored = {
                -- game state
                "TR_m3_q_Kha_BellTarget", "TR_m3_q_Kha_BellTracker", "TR_m3_OE_TarhielHaybale", "TR_m3_OE_customsfine",
                "TR_m3_OE_customsfine", "TR_m3_OE_customsnote", "TR_m3_OE_resettlement", "TR_m3_OE_esoldereward", "TR_m4_HH_ScribPie_Baker",
                -- player state
                "TR_m3_OE_armisticetheft", "TR_m3_OE_truearmistice", "tr_m3_bloodstone_help_T", "tr_m3_bloodstone_help_E", "tr_m3_bloodstone_help_T",
                "tr_m3_bloodstone_help_O", "tr_m3_bloodstone_help_B", "tr_m3_bloodstone_help_N", "tr_m3_bloodstone_help_L",
                -- player equipment
                "TR_m3_OE_MG_wearingrobe", "TR_m3_TT_FS_helm_on", "TR_m3_TT_InqMantle",
                -- quest variables that are already set correctly without being synced
                "TR_m3_bloodstonecheck"
            },
            personal = {
                -- player state
                "TR_m2_q_35_PCVampire",
                -- tavern rents
                "TR_m3_Rent_Bosmora_Starlight", "TR_m3_Rent_ED_Velk", "TR_m3_Rent_Gorne_EmeraldHaven",
                "TR_m2_Rent_Hlersis_Spore", "TR_m2_Rent_Akamora_Gob", "TR_m2_Rent_InnBetween", "TR_m2_Rent_Necrom_Hostel",
                "TR_m3_Rent_Meralag_Glade", "TR_m3_Rent_Darnim_Windbrk", "TR_Rent_HuntedHound", "TR_m1_Rent_Avenue",
                "TR_m2_Rent_Helnim_Drake", "TR_m2_Rent_Helnim_Flower", "TR_m2_Rent_Helnim_Racer", "TR_m2_Rent_Mothrivra_Goblet",
                "TR_m1_Rent_Black_Ogre", "TR_m1_Rent_Dancing_Jug", "TR_m1_Rent_Howling_Noose", "TR_m1_Rent_Queens_Cutlass", 
                "TR_m1_Rent_Waters_Shadow", "TR_m3_Rent_Sailen_Toiling", "TR_m3_Rent_Moth_and_Tiger", "TR_m3_Rent_Empress_Katariah", 
                "TR_m3_Rent_Salty_Futtocks", "TR_m3_Rent_Vhul_Hound", "TR_m3_Rent_Aimrah_Inn", "TR_m3_Rent_AT_HC", "TR_m3_Rent_AT_LS",
                "TR_m3_Rent_AT_TS",
                -- miscellaneous variables related to player-specific actions
                "TR_m3_Kha_Fountain_Cooldown", "TR_m3_Sa_PearlCurseTimer", "TR_m2_445_BlessingA", "TR_m2_445_BlessingS", "TR_m2_445_BlessingV"
            },
            quest = {
                -- main quest
                "TR_m2_445_KeyATracker", "TR_m2_445_KeySTracker", "TR_m2_445_KeyVTracker",
                -- reading of confidential documents
                "TR_m3_q_AT_recipe_sealed", "TR_m3_TT_IduraUnseal",
                -- assassination quests
                -- Note: These are related to kill counts, but they make more sense being shared across
                --       players who share quests than being shared across players who share kills
                "TR_m3_Zanammu_LichDead", "TR_m2_q_27_guardkilled", "TR_m2_q_35_dead", "TR_m3_q_4_dead", "TR_m3_OE_TG_AntioDead",
                "TR_m3_TT_CalitiaPreKilled", "TR_m3_TT_Lloris5IndCount", "TR_m4_VysAssaDead", "TR_m3_KH_kraskiradead",
                -- other side quests
                "TR_m3_q_3_thieving", "TR_Pilgrimages", "TR_m3_q_4_info", "TR_m3_q_3_info", "TR_m3_q_3_infoKiseen", "TR_m3_q_3_infoElegel", 
                "TR_m3_q_3_infoTemple", "TR_m3_q_3_infoFarys", "TR_m3_q_3_infoFarysWife", "TR_m2_q_38_sabotage", "TR_m2_q_38_talkedto", 
                "TR_m2_q_38_status", "TR_m2_q_A8_6_rushNPC", "TR_m3_q_3_rumour", "TR_m3_Bosvau_stolen", "TR_m3_Bosvau_stolenvalue", 
                "TR_m3_q_3_guardsGone", "TR_m2_MG_Aka_seeds", "TR_m2_MG_Aka_Francine1", "TR_m2_MG_Aka_karma", "TR_m2_MG_Aka_Polodie1reward",
                "TR_m2_MG_Aka_tarry", "TR_m3_q_5_Journal_Read", "TR_m3_q_5_distantJulie", "TR_m3_q_5_Journal_Read", "TR_m3_q_5_distantJulie", 
                "TR_m3_q_OE_MG_GCount", "TR_m3_OE_smuggleeggsfound", "TR_m3_OE_maesabunsale", "TR_m3_OE_FG_q_FledFromVermai", "TR_m3_OE_FG_q_AureCTalk", 
                "TR_m3_q_givebartsword", "TR_m3_q_fiendbladegot", "TR_m3_q_fienddisappear", "TR_m3_q_treasurebladestolen", "TR_m3_OE_RumaGlobal", "TR_m3_q_NelynFathisTimer",
                "TR_m3_AT_SilentNight_stage", "TR_m3_AT_SilentNight_Rat", "TR_m3_q_TheRiftDral", "TR_m3_q_TheRiftTilresi", "TR_m3_OE_MG_HallOpen", "TR_m3_Aim_ShipSneak", 
                "TR_m3_TT_ProverbCounter", "TR_m3_TT_Lloris4Indoril", "TR_m3_TT_Lloris4Hlaalu", "TR_m3_VysAssanudCheck", "TR_m3_TT_LatestRumorATGlobal", 
                "TR_m3_Kha_SY_convinced", "TR_m3_Kha_SY_final", "TR_m3_TT_RIP_garvs_heresy", "TR_m3_TT_RIP_refusecount", "TR_m4_TJ_Court_State", "TR_m2_NisirelConfronted",
                "TR_m3_q_A3_Seen_Basement", "TR_m3_OE_elysanadiamondstole", "TR_m3_OE_KtD_Tur", "TR_m3_OE_KtD_Gul", "TR_m3_OE_KtD_Mur", "TR_m3_OE_KtD_Ema",
                
            },
            kills = {

            },
            factionRanks = {
                
            },
            factionExpulsion = {
                -- faction expulsion forgiveness and timers
                "TR_Kick_FG", "TR_Kick_TG", "TR_Kick_TT", "TR_Kick_IC", "TR_Kick_MG"
            },
            worldwide = {
                -- mechanisms
                "TR_Necrom_StairsState", "TR_Necrom_MachineState", "TR_Necrom_VaultPortR", "TR_Necrom_VaultPortL",
                "TR_Necrom_DoorState", "TR_m2_445_grindertimer", "TR_m2_445_grinderangle1", "TR_m3_Aim_GilaWallBreak", 
                "TR_m3_Aim_LighthouseSecretDoor", "TR_m3_OE_pitgate", "TR_m3_OE_CuriaVaultGate2", "TR_m3_OE_sewergate", 
                "TR_m3_OE_MainGate", "TR_m3_OE_MainGMove", "TR_m2_kmlz_Chef_WaterLevel", "TR_m3_OE_ETCensusBlockDoor", 
                "TR_m3_OE_CuriaVaultGate", "set TR_m3_OE_CuriaVaultGlobal", "TR_m3_OE_TG_waterlevel", "TR_m3_OE_chapelsewerdoor",
                "TR_m3_OE_raathim_sarcophagus", "TR_m3_Aim_GilaWallBreak", "TR_m3_q_OE_UrienChest_glb", "TR_Necrom_AllowVaultEntry",
                -- building construction
                "TR_m7_NVA_BuildStage", "TR_m3_OE_ETCensus_RepairState", "TR_m3_OE_ETCensus_Stanchion",
                -- objects
                "TR_m3_MaesabunMummyAwake", "TR_m3_AT_LatikaPitcher", "TR_m3_vontuswalk",
                -- people
                "TR_m2_WM_Rethrathi", "TR_m2_q_29_shambaludridrea", "TR_m4_TJ_OgrimStatus", "TR_m3_TT_Illene1_ChaseGlobal",
                -- both
                "TR_m3_OE_EECq1solve", "TR_m3_OE_EECq2solve",
                -- events
                "TR_m3_OE_StendarrIdolsOutlawed", "TR_Thirr_Conflict_Score", "TR_Thirr_Conflict_Heat", "TR_m3_TT_g_ritstart"
            },
            unknown = {
                
            }
        }
    }

    tableHelper.merge(clientVariableScopes, addedVariableScopes, true)
end

if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Cyrodiil_Main.esm") then

    local addedVariableScopes = {
        globals = {
            ignored = {
                -- not actually used at all
                "PC_Q1_2_State", "PC_Q1_4_State", "PC_Q1_5_Travel"
            },
            personal = {
                -- tavern rents
                "PC_Rent_Stirk_Sloads_Tale", "PC_Rent_Stirk_Safe_Harbor"
            },
            quest = {
                
            },
            kills = {

            },
            factionRanks = {
                
            },
            factionExpulsion = {

            },
            worldwide = {
                -- mechanisms
                "PC_i1_51_Gate_State"
            },
            unknown = {
                
            }
        }
    }

    tableHelper.merge(clientVariableScopes, addedVariableScopes, true)
end

if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Sky_Main.esm") then

    local addedVariableScopes = {
        globals = {
            ignored = {
                -- game state
                "Sky_qRe_KG1_global", "Sky_TempVar_glb",
                -- quest variables that are already set correctly without being synced
                "Sky_qRe_DSW04_BreadCounter_glb",
                -- not actually used at all
                "Sky_iRe_DH99_Wine_glb", "sky_qRe_KG4_AmbCount", "sky_qRe_KG4_Day",
                "sky_qRe_KG4_Day2"
            },
            personal = {
                -- player state
                "Sky_qRe_KG4_Transformed_glb",
                -- tavern rents
                "Sky_Rent_DSE_Shadowkey", "Sky_Rent_DSW_DragonFountain", "Sky_Rent_DSW_NukraTikil", 
                "Sky_Rent_HA_Jhorcian", "Sky_Rent_KW_Dancing_Saber", "Sky_Rent_KW_Ruby_Drake",
                "Sky_Rent_LH_Daracam", "Sky_Rent_MER_Rhuma", "Sky_Rent_VF_EvenOddsInn",
                -- mercenary contracts
                "Sky_Merc_Rismund_DaysLeft",
                -- miscellaneous variables related to player-specific actions
                "Sky_qRe_BM04_Door_glb", "Sky_qRe_KW01_Book1_glb", "Sky_qRe_KW01_Book2_glb", 
                "Sky_qRe_KW01_Book3_glb", "Sky_qRe_KW01_Book4_glb"
            },
            quest = {

                -- other side quests
                "Sky_qRe-Vornd1_GLOBAL1", "Sky_qRe-Vornd1_GLOBAL2", "Sky_qRe_DSE01_Donation_glb", 
                "Sky_qRe_DSTG03_Informants_glb", "Sky_qRe_DSTG07_MoveCael_glb", "Sky_qRe_DSW01_CacheFound_glb",
                "Sky_qRe_DSW01_Dagger_glb", "Sky_qRe_DSW01_Scimitar_glb", "Sky_qRe_DSW01_Saber_glb", 
                "Sky_qRe_DSW02_Auth_glb", "Sky_qRe_KG5_SViir_glb", "Sky_qRe_KWFG04_Owner_glb", 
                "Sky_qRE_KWTG07_Glb_QuestDone", "Sky_qRe_MAI04_Counter_glb", "Sky_qRe_NAR01_Investigate_glb"
                
            },
            kills = {
                -- main quest
                "Sky_qRe_DSMQ_AlaktolDead", "Sky_qRe_DSMQ_JonaDead",
                -- side quests
                "Sky_qRe_Ald1_global", "Sky_qRe_DS_B01_AlreadyDead_glb", "Sky_qRe_DS_B02_AlreadyDead_glb", 
                "Sky_qRe_DS_B05_Counter_glb", "Sky_qRe_DSW01_MesaraDead_glb", "Sky_qRe_BM_FhegainDead_glb",
                "Sky_qRe_HA1_glb_KillCheck", "Sky_qRe_HA1_RilorDead_glb", "Sky_qRe_KG2_Counter_glb",
                "Sky_qRe_KG4_Counter", "Sky_qRe_KW_B01_glb_Counter", "Sky_qRe_KW_B02_AlreadyDead",
                "Sky_qRe_KW_B04_glb_Counter", "Sky_qRe_KW_B06_glb_Counter", "Sky_qRe_KW_B08_glb_Counter",
                "Sky_qRe_KW_B09_glb_Counter", "Sky_qRe_KW_B10_AlreadyDead", "Sky_qRe_KW_B10_glb_Counter",
                "Sky_qRe_KW_MG06_GhostsKilled", "sky_qRe_KWFG02_Counter", "sky_qRe_KWFG03_Counter",
                "Sky_qRe_MAI03_Counter_glb", "Sky_qRe_MAI04_Dead_glb", "Sky_qRE_VF3_Killed_glb",
                -- arena kill counts
                "Sky_qRe_DSE04_Count02_glb", "Sky_qRe_DSE04_Count03_glb", "Sky_qRe_DSE04_Count05_glb", 
                "Sky_qRe_DSE04_Count07_glb"
            },
            factionRanks = {
                -- faction reputation
                "Sky_qRe_DSMG_Rep_Glb", "Sky_Rep_FireHand_glb",
                -- membership in mini-factions
                "Sky_qRe_DSE04_Owner_glb"
            },
            factionExpulsion = {
                -- faction expulsion forgiveness and timers
                "Sky_Glb_ExpFightersGuild", "Sky_qRe_KWTG_Expelled_glb"
            },
            worldwide = {
                -- mechanisms
                "Sky_iRe_KW_RPVault_glb", "Sky_qRe_KW_MG06_PenumbraState", "Sky_qRe_KWTG06_Button_glb",
                -- objects
                "Sky_qRe_DSW01_LetterState_glb",
                -- npc behavior
                "Sky_qRe_HA1_CultistState_glb", "Sky_qRe_HA3_Sick_glb", "Sky_qRe_KW_MG04_Returned_glb",
                -- arena State
                "Sky_qRe_DSE_ArenaFight_glb"
            },
            unknown = {
                
            }
        }
    }

    tableHelper.merge(clientVariableScopes, addedVariableScopes, true)
end

return clientVariableScopes