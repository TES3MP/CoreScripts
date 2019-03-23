local speechCollections = {}

if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Morrowind.esm") then

    speechCollections["argonian"] = {
        default = {
            folderPath = "a",
            malePrefix = "AM",
            femalePrefix = "AF",
            maleFiles = {
                attack = { count = 15 },
                flee = { count = 5 },
                follower = { count = 3 },
                hello = { count = 139 },
                hit = { count = 16, skip = { 11 } },
                idle = { count = 8 },
                intruder = { count = 9, skip = { 7 }, indexPrefixOverride = "OP" },
                service = { count = 12 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 17, skip = { 11, 15, 16 } },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 139 },
                hit = { count = 16 },
                idle = { count = 8 },
                oppose = { count = 8 },
                service = { count = 12 },
                thief = { count = 5 }
            }
        }
    }
    speechCollections["breton"] = {
        default = {
            folderPath = "b",
            malePrefix = "BM",
            femalePrefix = "BF",
            maleFiles = {
                attack = { count = 15, skip = { 11 } },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138, skip = { 126 } },
                hit = { count = 15 },
                idle = { count = 8 },
                intruder = { count = 9, skip = { 7 }, indexPrefixOverride = "OP" },
                service = { count = 12 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 15, skip = { 11 } },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138 },
                hit = { count = 15 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 15 },
                thief = { count = 5 }
            }
        }
    }
    speechCollections["dark elf"] = {
        default = {
            folderPath = "d",
            malePrefix = "DM",
            femalePrefix = "DF",
            maleFiles = {
                attack = { count = 14 },
                flee = { count = 6 },
                follower = { count = 4 },
                hello = { count = 233 },
                hit = { count = 14 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 52 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 13 },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 233 },
                hit = { count = 14, skip = { 7 } },
                idle = { count = 9, skip = { 7, 8 } },
                oppose = { count = 8 },
                service = { count = 51 },
                thief = { count = 3, skip = { 1, 2 } }
            }
        },
        ord = {
            folderPath = "ord",
            malePrefix = "ORM",
            maleFiles = {
                attack = { count = 5 },
                hello = { count = 20 },
                idle = { count = 4 },
                intruder = { count = 2 }
            }
        }
    }
    speechCollections["high elf"] = {
        default = {
            folderPath = "h",
            malePrefix = "HM",
            femalePrefix = "HF",
            maleFiles = {
                attack = { count = 15 },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138 },
                hit = { count = 15, skip = { 14 } },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 25 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 15 },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138 },
                hit = { count = 15 },
                idle = { count = 8 },
                oppose = { count = 8 },
                service = { count = 18 },
                thief = { count = 5 }
            }
        }
    }
    speechCollections["imperial"] = {
        default = {
            folderPath = "i",
            malePrefix = "IM",
            femalePrefix = "IF",
            maleFiles = {
                attack = { count = 14 },
                flee = { count = 4 },
                follower = { count = 3 },
                hello = { count = 179, skip = { 1, 27, 47, 69, 70, 71, 72, 80, 81, 82, 83, 84, 85, 86,
                    100, 101, 102, 103, 104, 105, 106, 107, 128, 129, 143, 144, 145, 171, 173, 174, 176 } },
                hit = { count = 10 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 34 },
                thief = { count = 5 },
                uniform = { count = 7 }
            },
            femaleFiles = {
                attack = { count = 15, skip = { 11 } },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 173, skip = { 159, 163 } },
                hit = { count = 15 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 21 },
                thief = { count = 5 }
            }
        }
    }
    speechCollections["khajiit"] = {
        default = {
            folderPath = "k",
            malePrefix = "KM",
            femalePrefix = "KF",
            maleFiles = {
                attack = { count = 15, skip = { 11 } },
                flee = { count = 5 },
                follower = { count = 3 },
                hello = { count = 139 },
                hit = { count = 16 },
                idle = { count = 9 },
                intruder = { count = 9, skip = { 7 }, indexPrefixOverride = "OP" },
                service = { count = 9 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 15, skip = { 11 } },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 139 },
                hit = { count = 16 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 12 },
                thief = { count = 5 }
            }
        }
    }
    speechCollections["nord"] = {
        default = {
            folderPath = "n",
            malePrefix = "NM",
            femalePrefix = "NF",
            maleFiles = {
                attack = { count = 20, skip = { 14, 15, 16, 17, 18, 19 } },
                flee = { count = 5 },
                follower = { count = 4 },
                hello = { count = 138 },
                hit = { count = 14 },
                idle = { count = 9 },
                intruder = { count = 9, skip = { 7 }, indexPrefixOverride = "OP" },
                service = { count = 6 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 15, skip = { 11 } },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138 },
                hit = { count = 15 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 11 },
                thief = { count = 5 }
            }
        }
    }
    speechCollections["orc"] = {
        default = {
            folderPath = "o",
            malePrefix = "OM",
            femalePrefix = "OF",
            maleFiles = {
                attack = { count = 15 },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138 },
                hit = { count = 15 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 12 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 15 },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138 },
                hit = { count = 21 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 3 },
                thief = { count = 5 }
            }
        }
    }
    speechCollections["redguard"] = {
        default = {
            folderPath = "r",
            malePrefix = "RM",
            femalePrefix = "RF",
            maleFiles = {
                attack = { count = 18 },
                flee = { count = 5 },
                follower = { count = 3 },
                hello = { count = 138 },
                hit = { count = 15 },
                idle = { count = 9 },
                intruder = { count = 9, skip = { 7 }, indexPrefixOverride = "OP" },
                service = { count = 12 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 15, skip = { 1, 11 } },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138 },
                hit = { count = 14 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 6 },
                thief = { count = 5 }
            }
        }
    }
    speechCollections["wood elf"] = {
        default = {
            folderPath = "w",
            malePrefix = "WM",
            femalePrefix = "WF",
            maleFiles = {
                attack = { count = 18, skip = { 14, 15, 16, 17 } },
                flee = { count = 5 },
                follower = { count = 3 },
                hello = { count = 138 },
                hit = { count = 15 },
                idle = { count = 9 },
                intruder = { count = 9, skip = { 7 }, indexPrefixOverride = "OP" },
                service = { count = 6 },
                thief = { count = 5 }
            },
            femaleFiles = {
                attack = { count = 14 },
                flee = { count = 5 },
                follower = { count = 6 },
                hello = { count = 138 },
                hit = { count = 15 },
                idle = { count = 9 },
                oppose = { count = 8 },
                service = { count = 9 },
                thief = { count = 5 }
            }
        }
    }

    if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Tribunal.esm") then

        speechCollections["dark elf"]["tb"] = {
            folderPath = "d",
            malePrefix = "DM",
            femalePrefix = "DF",
            maleFiles = {
                hello = { count = 200, filePrefixOverride = "tHlo" },
                idle = { count = 24, filePrefixOverride = "tIdl" }
            },
            femaleFiles = {
                hello = { count = 173, filePrefixOverride = "tHlo" },
                idle = { count = 17, filePrefixOverride = "tIdl"  }
            }
        }

        speechCollections["imperial"]["tb"] = {
            folderPath = "i",
            malePrefix = "IM",
            femalePrefix = "IF",
            maleFiles = {
                hello = { count = 116, filePrefixOverride = "tHlo" },
                idle = { count = 13, filePrefixOverride = "tIdl" }
            },
            femaleFiles = {
                hello = { count = 112, filePrefixOverride = "tHlo" },
                idle = { count = 13, filePrefixOverride = "tIdl" }
            }
        }
    end

    if tableHelper.containsCaseInsensitiveString(clientDataFiles, "Bloodmoon.esm") then

        speechCollections["dark elf"]["bm"] = {
            folderPath = "d",
            malePrefix = "DM",
            femalePrefix = "DF",
            maleFiles = {
                attack = { count = 6, filePrefixOverride = "bAtk" },
                flee = { count = 4, filePrefixOverride = "bFle" },
                hello = { count = 7, filePrefixOverride = "bHlo" },
                idle = { count = 14, skip = { 1 }, filePrefixOverride = "bIdl" }
            },
            femaleFiles = {
                attack = { count = 6, filePrefixOverride = "bAtk" },
                flee = { count = 4, filePrefixOverride = "bFle" },
                hello = { count = 1, filePrefixOverride = "bHlo" },
                idle = { count = 15, skip = { 7, 8 }, filePrefixOverride = "bIdl" }
            }
        }

        speechCollections["imperial"]["bm"] = {
            folderPath = "i",
            malePrefix = "IM",
            femalePrefix = "IF",
            maleFiles = {
                attack = { count = 9, filePrefixOverride = "bAtk" },
                flee = { count = 4, filePrefixOverride = "bFle" },
                hello = { count = 52, filePrefixOverride = "bHlo" },
                idle = { count = 41, skip = { 16 }, filePrefixOverride = "bIdl" }
            },
            femaleFiles = {
                attack = { count = 8, filePrefixOverride = "bAtk" },
                flee = { count = 4, filePrefixOverride = "bFle" },
                hello = { count = 17, skip = { 8, 9, 10 }, filePrefixOverride = "bHlo" },
                idle = { count = 13, filePrefixOverride = "bIdl" }
            }
        }

        speechCollections["nord"]["bm"] = {
            folderPath = "n",
            malePrefix = "NM",
            femalePrefix = "NF",
            maleFiles = {
                attack = { count = 9, filePrefixOverride = "bAtk" },
                flee = { count = 4, filePrefixOverride = "bFle" },
                hello = { count = 75, filePrefixOverride = "bHlo" },
                idle = { count = 37, filePrefixOverride = "bIdl" }
            },
            femaleFiles = {
                attack = { count = 9, filePrefixOverride = "bAtk" },
                flee = { count = 4, filePrefixOverride = "bFle" },
                hello = { count = 21, skip = { 8, 9 }, filePrefixOverride = "bHlo" },
                idle = { count = 23, skip = { 21 }, filePrefixOverride = "bIdl" }
            }
        }
    end
end

return speechCollections
