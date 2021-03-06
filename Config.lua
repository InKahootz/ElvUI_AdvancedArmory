if  (select(2, GetAddOnInfo('ElvUI_KnightFrame')) and IsAddOnLoaded('ElvUI_KnightFrame')) or
	(select(2, GetAddOnInfo('ElvUI_SLE')) and IsAddOnLoaded('ElvUI_SLE')) then 
	return 
end

local E, L, V, P, G = unpack(ElvUI)
local KF, Info, Timer = unpack(ElvUI_AdvancedArmory)
--GLOBALS: AA_ArmoryDB, AceGUIWidgetLSMlists, PaperDollFrame_UpdateStats
local _G = _G
-- local PaperDollFrame_UpdateStats = PaperDollFrame_UpdateStats
local UnitPowerType = UnitPowerType

local MAX_NUM_SOCKETS = MAX_NUM_SOCKETS
local ALTERNATE_RESOURCE_TEXT, DAMAGE, ATTACK_POWER, ATTACK_SPEED, STAT_SPELLPOWER, STAT_ENERGY_REGEN, STAT_RUNE_REGEN, STAT_FOCUS_REGEN, STAT_SPEED, DURABILITY, HIDE = ALTERNATE_RESOURCE_TEXT, DAMAGE, ATTACK_POWER, ATTACK_SPEED, STAT_SPELLPOWER, STAT_ENERGY_REGEN, STAT_RUNE_REGEN, STAT_FOCUS_REGEN, STAT_SPEED, DURABILITY, HIDE
local FACTION_ALLIANCE, FACTION_HORDE, ARENA, NONE, STAT_CATEGORY_ATTRIBUTES, STAT_CATEGORY_ATTRIBUTES = FACTION_ALLIANCE, FACTION_HORDE, ARENA, NONE, STAT_CATEGORY_ATTRIBUTES, STAT_CATEGORY_ATTRIBUTES
local ADD, DELETE, HEALTH = ADD, DELETE, HEALTH
local CUSTOM = CUSTOM

--if not (KF and KF.Modules and (KF.Modules.CharacterArmory or KF.Modules.InspectArmory)) then return end

local function Color(TrueColor, FalseColor)
	return (E.db.kfAA.Armory.Character.Enable ~= false or E.db.kfAA.Armory.Inspect.Enable ~= false) and (TrueColor == '' and '' or TrueColor and '|c'..TrueColor or KF:Color_Value()) or FalseColor and '|c'..FalseColor or ''
end

local EnchantStringName, EnchantString_Old, EnchantString_New = '', '', ''
local SelectedEnchantString

function KF:InsertConfigTables()

	E.Options.args.kfAA = {
		type = "group",
		name = "|cff9482c9Advanced Armory|r",
		desc = L["Standalone plugin ported to |cff1784d1ElvUI|r by\nInKahootz."],
		order = 50,
		childGroups = 'tab',
		args = {
			header = {
				order = 1,
				type = "header",
				name = KF.Credit,
			},
			EnchantString = {
				type = 'group',
				name = L["Enchant String"],
				order = 700,
				args = {
					Space = {
						type = 'description',
						name = ' ',
						order = 1
					},
					ConfigSpace = {
						type = 'group',
						name = L["String Replacement"],
						order = 2,
						guiInline = true,
						args = {
							CreateString = {
								order = 1,
								name = L["Create Filter"],
								type = 'input',
								width = "full",
								get = function() return EnchantStringName end,
								set = function(_, value)
									EnchantStringName = value
								end,
								disabled = function() return E.db.kfAA.Armory.Character.Enable == false and E.db.kfAA.Armory.Inspect.Enable == false end
							},
							AddButton = {
								type = 'execute',
								name = ADD,
								order = 3,
								desc = '',
								func = function()
									if EnchantStringName ~= '' and not AA_ArmoryDB.EnchantString[EnchantStringName] then
										AA_ArmoryDB.EnchantString[EnchantStringName] = {}
										SelectedEnchantString = EnchantStringName
										EnchantStringName = ""
									end
								end,
								disabled = function()
									return (E.db.kfAA.Armory.Character.Enable == false and E.db.kfAA.Armory.Inspect.Enable == false) or EnchantStringName == ''
								end
							},
							List = {
								type = 'select',
								name = L["List of Strings"],
								order = 4,
								get = function() return SelectedEnchantString end,
								set = function(_, value)
									SelectedEnchantString = value
									E.Options.args.kfAA.args.EnchantString.args.ConfigSpace.args.StringGroup.name = L["List of Strings"]..":  "..value
								end,
								values = function()
									local List = {}
									List[""] = NONE
									for Name, _ in pairs(AA_ArmoryDB.EnchantString) do
										List[Name] = Name
									end
									if not SelectedEnchantString then
											SelectedEnchantString = ''
										end
									return List
								end,
								disabled = function() return E.db.kfAA.Armory.Character.Enable == false and E.db.kfAA.Armory.Inspect.Enable == false end
							},
							Space2 = {
								type = 'description',
								name = ' ',
								order = 5,
								width = 'half'
							},
							StringGroup = {
								type = 'group',
								name = "",
								order = 8,
								guiInline = true,
								hidden = function()
									return SelectedEnchantString == ''
								end,
								args = {
									TargetString = {
										type = 'input',
										name = L["Original String"],
										order = 1,
										desc = '',
										width = "full",
										get = function() return AA_ArmoryDB.EnchantString[SelectedEnchantString]["original"] end,
										set = function(_, value)
											AA_ArmoryDB.EnchantString[SelectedEnchantString]["original"] = value
											
											if _G["CharacterArmory"] then
												_G["CharacterArmory"]:Update_Gear()
											end
											
											if _G["InspectArmory"] and _G["InspectArmory"].LastDataSetting then
												_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
											end
										end,
										disabled = function() return E.db.kfAA.Armory.Character.Enable == false and E.db.kfAA.Armory.Inspect.Enable == false end
									},
									NewString = {
										type = 'input',
										name = L["New String"],
										order = 2,
										desc = '',
										width = "full",
										get = function() return AA_ArmoryDB.EnchantString[SelectedEnchantString]["new"] end,
										set = function(_, value)
											AA_ArmoryDB.EnchantString[SelectedEnchantString]["new"] = value
											
											if _G["CharacterArmory"] then
												_G["CharacterArmory"]:Update_Gear()
											end
											
											if _G["InspectArmory"] and _G["InspectArmory"].LastDataSetting then
												_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
											end
										end,
										disabled = function() return E.db.kfAA.Armory.Character.Enable == false and E.db.kfAA.Armory.Inspect.Enable == false end
									},
									DeleteButton = {
										type = 'execute',
										name = DELETE,
										order = 8,
										desc = '',
										func = function()
											if AA_ArmoryDB.EnchantString[SelectedEnchantString] then
												AA_ArmoryDB.EnchantString[SelectedEnchantString] = nil
												SelectedEnchantString = ''
												
												if _G["CharacterArmory"] then
													_G["CharacterArmory"]:Update_Gear()
												end
												
												if _G["InspectArmory"] and _G["InspectArmory"].LastDataSetting then
													_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
												end
											end
										end,
										disabled = function() return E.db.kfAA.Armory.Character.Enable == false and E.db.kfAA.Armory.Inspect.Enable == false end,	
									},
								},
							},
						},
					},
					Space2 = {
						type = 'description',
						name = ' ',
						order = 3
					},
					CreditSpace = {
						type = 'description',
						name = ' ',
						order = 998
					},
					Credit = {
						type = 'header',
						name = KF.Credit,
						order = 999
					}
				}
			},
			header = {
				order = -1,
				type = "header",
				name = KF.Credit,
			},
		},
	}


	local BackdropKeyTable = {
		["0"] = 'HIDE',
		["1"] = 'CUSTOM',
		["2"] = 'Space',
		["3"] = 'TheEmpire',
		["4"] = 'Castle',
		["5"] = 'Alliance-text',
		["6"] = 'Horde-text',
		["7"] = 'Alliance-bliz',
		["8"] = 'Horde-bliz',
		["9"] = 'Arena-bliz'
	}

	local BackgroundList = {
		["0"] = HIDE,
		["1"] = CUSTOM,
		["2"] = "Space",
		["3"] = "The Empire",
		["4"] = "Castle",
		["5"] = FACTION_ALLIANCE,
		["6"] = FACTION_HORDE,
		["7"] = FACTION_ALLIANCE..' 2',
		["8"] = FACTION_HORDE..' 2',
		["9"] = ARENA
	}

	local DisplayMethodList = {
		Always = L["Always Display"],
		MouseoverOnly = L["Mouseover"],
		Hide = HIDE
	}

	local FontStyleList = {
		NONE = NONE,
		OUTLINE = 'OUTLINE',
		
		MONOCHROMEOUTLINE = 'MONOCROMEOUTLINE',
		THICKOUTLINE = 'THICKOUTLINE'
	}

	if KF.Modules.CharacterArmory then
		local function CA_Color(TrueColor, FalseColor)
			return E.db.kfAA.Armory.Character.Enable ~= false and (TrueColor == '' and '' or TrueColor and '|c'..TrueColor or KF:Color_Value()) or FalseColor and '|c'..FalseColor or ''
		end
		
		E.Options.args.kfAA.args.CAEnable = {
			type = 'toggle',
			name = L["Character Armory"],
			order = 2,
			desc = '',
			get = function() return E.db.kfAA.Armory.Character.Enable end,
			set = function(_, value) E.db.kfAA.Armory.Character.Enable = value; KF.Modules.CharacterArmory() end
		}
		
		local SelectedCABG
		E.Options.args.kfAA.args.Character = {
			type = 'group',
			name = L["Character Armory"],
			order = 400,
			args = {
				NoticeMissing = {
					type = 'toggle',
					name = L["Show Missing Enchants or Gems"],
					order = 1,
					get = function() return E.db.kfAA.Armory.Character.NoticeMissing end,
					set = function(_, value) E.db.kfAA.Armory.Character.NoticeMissing = value; _G["CharacterArmory"]:UpdateSettings("gear") end,
					disabled = function() return not E.db.kfAA.Armory.Character.Enable end,
				},
				MissingIcon = {
					type = 'toggle',
					name = L["Show Warning Icon"],
					order = 2,
					get = function() return E.db.kfAA.Armory.Character.MissingIcon end,
					set = function(_, value) E.db.kfAA.Armory.Character.MissingIcon = value; _G["CharacterArmory"]:UpdateSettings("gear") end,
					disabled = function() return not E.db.kfAA.Armory.Character.Enable or not E.db.kfAA.Armory.Character.NoticeMissing end,
				},
				Stats = {
					type = 'group',
					name = STAT_CATEGORY_ATTRIBUTES,
					order = 3,
					disabled = function() return KF._Compatibility["DejaCharacterStats"] end,
					get = function(info) return E.db.kfAA.Armory.Character.Stats[ info[#info] ] end,
					set = function(info, value) E.db.kfAA.Armory.Character.Stats[ info[#info] ] = value; PaperDollFrame_UpdateStats() end,
					args = {
						IlvlFull = {
							order = 1,
							type = "toggle",
							name = L["Full Item Level"],
							desc = L["Show both equipped and average item levels."],
						},
						IlvlColor = {
							order = 2,
							type = "toggle",
							name = L["Item Level Coloring"],
							desc = L["Color code item levels values. Equipped will be gradient, avarage - selected color."],
							disabled = function() return KF._Compatibility["DejaCharacterStats"] or not E.db.kfAA.Armory.Character.Stats.IlvlFull end,
						},
						AverageColor = {
							type = 'color',
							order = 3,
							name = L["Color of Average"],
							desc = L["Sets the color of avarage item level."],
							hasAlpha = false,
							disabled = function() return KF._Compatibility["DejaCharacterStats"] or not E.db.kfAA.Armory.Character.Stats.IlvlFull end,
							get = function(info)
								local t = E.db.kfAA.Armory.Character.Stats[ info[#info] ]
								local d = P.kfAA.Armory.Character.Stats[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								E.db.kfAA.Armory.Character.Stats[ info[#info] ] = {}
								local t = E.db.kfAA.Armory.Character.Stats[ info[#info] ]
								t.r, t.g, t.b, t.a = r, g, b, a
								PaperDollFrame_UpdateStats()
							end,
						},
						OnlyPrimary = {
							order = 4,
							type = "toggle",
							name = L["Only Relevant Stats"],
							desc = L["Show only those primary stats relevant to your spec."],
						},
						IlvlFont = {
							type = 'group',
							name = L["Item Level"],
							order = 5,
							guiInline = true,
							get = function(info) return E.db.kfAA.Armory.Character.Stats.ItemLevel[ info[#info] ] end,
							set = function(info, value) E.db.kfAA.Armory.Character.Stats.ItemLevel[ info[#info] ] = value; _G["CharacterArmory"]:UpdateIlvlFont() end,
							args = {
								font = {
									type = 'select', dialogControl = 'LSM30_Font',
									name = L["Font"],
									order = 1,
									values = function()
										return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {}
									end,
								},
								size = {
									type = 'range',
									name = L["Font Size"],
									order = 2,
									min = 6,max = 22,step = 1,
								},
								outline = {
									type = 'select',
									name = L["Font Outline"],
									order = 3,
									values = FontStyleList,
								},
							},
						},
						Stats = {
							type = 'group',
							name = STAT_CATEGORY_ATTRIBUTES,
							order = 6,
							guiInline = true,
							get = function(info) return E.db.kfAA.Armory.Character.Stats.List[ info[#info] ] end,
							set = function(info, value) E.db.kfAA.Armory.Character.Stats.List[ info[#info] ] = value; _G["CharacterArmory"]:ToggleStats() end,
							args = {
								HEALTH = { order = 1,type = "toggle",name = HEALTH,},
								POWER = { order = 2,type = "toggle",name = _G[select(2, UnitPowerType("player"))],},
								ALTERNATEMANA = { order = 3,type = "toggle",name = ALTERNATE_RESOURCE_TEXT,},
								ATTACK_DAMAGE = { order = 4,type = "toggle",name = DAMAGE,},
								ATTACK_AP = { order = 5,type = "toggle",name = ATTACK_POWER,},
								ATTACK_ATTACKSPEED = { order = 6,type = "toggle",name = ATTACK_SPEED,},
								SPELLPOWER = { order = 7,type = "toggle",name = STAT_SPELLPOWER,},
								ENERGY_REGEN = { order = 8,type = "toggle",name = STAT_ENERGY_REGEN,},
								RUNE_REGEN = { order = 9,type = "toggle",name = STAT_RUNE_REGEN,},
								FOCUS_REGEN = { order = 10,type = "toggle",name = STAT_FOCUS_REGEN,},
								MOVESPEED = { order = 11,type = "toggle",name = STAT_SPEED,},
							},
						},
					},
				},
				Backdrop = {
					type = 'group',
					name = L["Backdrop"],
					order = 3,
					args = {
						SelectedBG = {
							type = 'select',
							name = L["Select Image"],
							order = 1,
							get = function()
								for Index, Key in pairs(BackdropKeyTable) do
									if Key == E.db.kfAA.Armory.Character.Backdrop.SelectedBG then
										return Index
									end
								end
								return '1'
							end,
							set = function(_, value) E.db.kfAA.Armory.Character.Backdrop.SelectedBG = BackdropKeyTable[value]; _G["CharacterArmory"]:UpdateSettings("bg") end,
							values = function() return BackgroundList end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						CustomAddress = {
							type = 'input',
							name = L["Custom Image Path"],
							order = 2,
							get = function() return E.db.kfAA.Armory.Character.Backdrop.CustomAddress end,
							set = function(_, value) E.db.kfAA.Armory.Character.Backdrop.CustomAddress = value; _G["CharacterArmory"]:UpdateSettings("bg") end,
							width = 'double',
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end,
							hidden = function() return E.db.kfAA.Armory.Character.Backdrop.SelectedBG ~= 'CUSTOM' end
						},
						Overlay = {
							type = "toggle",
							order = 3,
							name = L["Overlay"],
							desc = L["Show ElvUI skin's backdrop overlay"],
							get = function() return E.db.kfAA.Armory.Character.Backdrop.Overlay end,
							set = function(_, value) E.db.kfAA.Armory.Character.Backdrop.Overlay = value; _G["CharacterArmory"]:ElvOverlayToggle() end
						},
					}
				},
				Gradation = {
					type = 'group',
					name = L["Gradient"],
					order = 5,
					args = {
						Display = {
							type = 'toggle',
							name = L["Enable"],
							order = 1,
							get = function() return E.db.kfAA.Armory.Character.Gradation.Display end,
							set = function(_, value) E.db.kfAA.Armory.Character.Gradation.Display = value; _G["CharacterArmory"]:Update_Gear() end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						Color = {
							type = 'color',
							name = L["Gradient Texture Color"],
							order = 2,
							get = function() 
								return E.db.kfAA.Armory.Character.Gradation.Color[1],
									   E.db.kfAA.Armory.Character.Gradation.Color[2],
									   E.db.kfAA.Armory.Character.Gradation.Color[3],
									   E.db.kfAA.Armory.Character.Gradation.Color[4]
							end,
							set = function(Info, r, g, b, a) E.db.kfAA.Armory.Character.Gradation.Color = { r, g, b, a }; _G["CharacterArmory"]:Update_Gear() end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false or E.db.kfAA.Armory.Character.Gradation.Display == false end
						},
					}
				},
				Level = {
					type = 'group',
					name = L["Item Level"],
					order = 7,
					get = function(info) return E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] end,
					set = function(info, value) E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] = value; _G["CharacterArmory"]:UpdateSettings("ilvl") end,
					args = {
						Display = {
							type = 'select',
							name = L["Visibility"],
							order = 1,
							set = function(info, value) E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] = value;  _G["CharacterArmory"]:UpdateSettings("gear") end,
							values = DisplayMethodList,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						ShowUpgradeLevel = {
							type = 'toggle',
							name = L["Upgrade Level"],
							order = 2,
							set = function(_, value) E.db.kfAA.Armory.Character.Level.ShowUpgradeLevel = value; _G["CharacterArmory"]:Update_Gear() end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						Space = {
							type = 'description',
							name = '',
							order = 3
						},
						Font = {
							type = 'select', dialogControl = 'LSM30_Font',
							name = L["Font"],
							order = 4,
							values = function() return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {} end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						FontSize = {
							type = 'range',
							name = L["Font Size"],
							order = 5,
							min = 6, max = 22, step = 1,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						FontStyle = {
							type = 'select',
							name = L["Font Outline"],
							order = 6,
							values = FontStyleList,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						}
					}
				},
				Enchant = {
					type = 'group',
					name = L["Enchant String"],
					order = 9,
					get = function(info) return E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] end,
					set = function(info, value) E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] = value;  _G["CharacterArmory"]:UpdateSettings("ench") end,
					args = {
						Display = {
							type = 'select',
							name = L["Visibility"],
							order = 1,
							values = DisplayMethodList,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						WarningSize = {
							type = 'range',
							name = L["Warning Size"],
							order = 2,
							min = 6, max = 50, step = 1,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						WarningIconOnly = {
							type = 'toggle',
							name = L["Warning Only As Icons"],
							order = 3,
							set = function(_, value) E.db.kfAA.Armory.Character.Enchant.WarningIconOnly = value; _G["CharacterArmory"]:Update_Gear() end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end,
						},
						Space = {
							type = 'description',
							name = '',
							order = 4
						},
						Font = {
							type = 'select', dialogControl = 'LSM30_Font',
							name = L["Font"],
							order = 5,
							values = function() return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {} end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						FontSize = {
							type = 'range',
							name = L["Font Size"],
							order = 6,
							min = 6, max = 22, step = 1,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						FontStyle = {
							type = 'select',
							name = L["Font Outline"],
							order = 7,
							values = FontStyleList,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						}
					}
				},
				Durability = {
					type = 'group',
					name = DURABILITY,
					order = 11,
					get = function(info) return E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] end,
					set = function(info, value) E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] = value; _G["CharacterArmory"]:UpdateSettings("dur") end,
					args = {
						Display = {
							type = 'select',
							name = L["Visibility"],
							order = 1,
							set = function(info, value) E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] = value; _G["CharacterArmory"]:UpdateSettings("gear") end,
							values = {
								Always = L["Always Display"],
								DamagedOnly = L["Only Damaged"],
								MouseoverOnly = L["Mouseover"],
								Hide = HIDE
							},
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						Space = {
							type = 'description',
							name = '',
							order = 2
						},
						Font = {
							type = 'select', dialogControl = 'LSM30_Font',
							name = L["Font"],
							order = 3,
							values = function() return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {} end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						FontSize = {
							type = 'range',
							name = L["Font Size"],
							order = 4,
							min = 6, max = 22, step = 1,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						FontStyle = {
							type = 'select',
							name = L["Font Outline"],
							order = 5,
							values = FontStyleList,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						}
					}
				},
				Gem = {
					type = 'group',
					name = L["Gem Sockets"],
					order = 13,
					get = function(Info) return E.db.kfAA.Armory.Character[(Info[#Info - 1])][(Info[#Info])] end,
					args = {
						Display = {
							type = 'select',
							name = L["Visibility"],
							order = 1,
							set = function(Info, value) E.db.kfAA.Armory.Character[(Info[#Info - 1])][(Info[#Info])] = value; _G["CharacterArmory"]:UpdateSettings("gem") end,
							values = DisplayMethodList,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						SocketSize = {
							type = 'range',
							name = L["Socket Size"],
							order = 2,
							set = function(_, value) E.db.kfAA.Armory.Character.Gem.SocketSize = value; _G["CharacterArmory"]:UpdateSettings("gem") end,
							min = 6, max = 50, step = 1,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
						WarningSize = {
							type = 'range',
							name = L["Warning Size"],
							order = 3,
							min = 6,max = 50,step = 1,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false end
						},
					}
				},
				Artifact = {
					type = 'group',
					order = 14,
					name = ITEM_QUALITY6_DESC,
					get = function(info) return E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] end,
					set = function(info, value) E.db.kfAA.Armory.Character[(info[#info - 1])][(info[#info])] = value; _G["CharacterArmory"]:UpdateSettings("art") end,
					args = {
						Enable = {
							type = "toggle",
							order = 1,
							name = L["Enable"],
							get = function(info) return E.private.kfAA.Armory.UseArtMonitor end,
							set = function(info, value) E.private.kfAA.Armory.UseArtMonitor = value; E:StaticPopup_Show("PRIVATE_RL") end,
						},
						Font = {
							type = 'select', dialogControl = 'LSM30_Font',
							name = L["Font"],
							order = 2,
							values = function() return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {} end,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false or E.private.kfAA.Armory.UseArtMonitor == false end,
						},
						FontSize = {
							type = 'range',
							name = L["Font Size"],
							order = 3,
							min = 6, max = 22, step = 1,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false or E.private.kfAA.Armory.UseArtMonitor == false end,
						},
						FontStyle = {
							type = 'select',
							name = L["Font Outline"],
							order = 4,
							values = FontStyleList,
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false or E.private.kfAA.Armory.UseArtMonitor == false end,
						},
						ShortValues = {
							order = 5,
							type = "toggle",
							name = L["Short text"],
							disabled = function() return E.db.kfAA.Armory.Character.Enable == false or E.private.kfAA.Armory.UseArtMonitor == false end,
						},
					},
				},
			}
		}
	end


	if KF.Modules.InspectArmory then
		local function IA_Color(TrueColor, FalseColor)
			return E.db.kfAA.Armory.Inspect.Enable ~= false and (TrueColor == '' and '' or TrueColor and '|c'..TrueColor or KF:Color_Value()) or FalseColor and '|c'..FalseColor or ''
		end
		
		E.Options.args.kfAA.args.Armory.args.IAEnable = {
			type = 'toggle',
			name = L["Inspect Armory"],
			order = 3,
			get = function() return E.db.kfAA.Armory.Inspect.Enable end,
			set = function(_, value) E.db.kfAA.Armory.Inspect.Enable = value; KF.Modules.InspectArmory() end
		}
		
		E.Options.args.kfAA.args.Armory.args.Inspect = {
			type = 'group',
			name = L["Inspect Armory"],
			order = 500,
			args = {
				NoticeMissing = {
					type = 'toggle',
					name = L["Show Missing Enchants or Gems"],
					order = 1,
					get = function() return E.db.kfAA.Armory.Inspect.NoticeMissing end,
					set = function(_, value)
						E.db.kfAA.Armory.Inspect.NoticeMissing = value
						
						if _G["InspectArmory"].LastDataSetting then
							_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
						end
						_G["InspectArmory"]:Update_Display(true)
					end,
					disabled = function() return not E.db.kfAA.Armory.Inspect.Enable end,
				},
				MissingIcon = {
					type = 'toggle',
					name = L["Show Warning Icon"],
					order = 2,
					get = function() return E.db.kfAA.Armory.Inspect.MissingIcon end,
					set = function(_, value)
						E.db.kfAA.Armory.Inspect.MissingIcon = value
						
						if _G["InspectArmory"].LastDataSetting then
							_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
						end
						_G["InspectArmory"]:Update_Display(true)
					end,
					disabled = function() return not E.db.kfAA.Armory.Inspect.Enable or not E.db.kfAA.Armory.Inspect.NoticeMissing end,
				},
				Backdrop = {
					type = 'group',
					name = L["Backdrop"],
					order = 3,
					args = {
						SelectedBG = {
							type = 'select',
							name = L["Select Image"],
							order = 1,
							get = function()
								for Index, Key in pairs(BackdropKeyTable) do
									if Key == E.db.kfAA.Armory.Inspect.Backdrop.SelectedBG then
										return Index
									end
								end
								return '1'
							end,
							set = function(_, value)
								E.db.kfAA.Armory.Inspect.Backdrop.SelectedBG = BackdropKeyTable[value]
								
								_G["InspectArmory"]:Update_BG()
							end,
							values = function() return BackgroundList end,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						CustomAddress = {
							type = 'input',
							name = L["Custom Image Path"],
							order = 2,
							get = function() return E.db.kfAA.Armory.Inspect.Backdrop.CustomAddress end,
							set = function(_, value)
								E.db.kfAA.Armory.Inspect.Backdrop.CustomAddress = value
								
								_G["InspectArmory"]:Update_BG()
							end,
							width = 'double',
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end,
							hidden = function() return E.db.kfAA.Armory.Inspect.Backdrop.SelectedBG ~= 'CUSTOM' end
						},
					}
				},
				Gradation = {
					type = 'group',
					name = L["Gradient"],
					order = 5,
					args = {
						Display = {
							type = 'toggle',
							name = L["Enable"],
							order = 1,
							get = function() return E.db.kfAA.Armory.Inspect.Gradation.Display end,
							set = function(_, value)
								E.db.kfAA.Armory.Inspect.Gradation.Display = value
								
								if _G["InspectArmory"] and _G["InspectArmory"].LastDataSetting then
									_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
								end
							end,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						CurrentClassColor = {
							type = 'toggle',
							name = L["Use Inspected Unit Class Color"],
							order = 2,
							get = function() return E.db.kfAA.Armory.Inspect.Gradation.CurrentClassColor end,
							set = function(_, value)
								E.db.kfAA.Armory.Inspect.Gradation.CurrentClassColor = value
								
								if _G["InspectArmory"] and _G["InspectArmory"].LastDataSetting then
									_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
								end
							end,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						Color = {
							type = 'color',
							name = L["Gradient Texture Color"],
							order = 3,
							get = function() 
								return E.db.kfAA.Armory.Inspect.Gradation.Color[1],
									   E.db.kfAA.Armory.Inspect.Gradation.Color[2],
									   E.db.kfAA.Armory.Inspect.Gradation.Color[3],
									   E.db.kfAA.Armory.Inspect.Gradation.Color[4]
							end,
							set = function(Info, r, g, b, a)
								E.db.kfAA.Armory.Inspect.Gradation.Color = { r, g, b, a }
								
								if _G["InspectArmory"].LastDataSetting then
									_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
								end
							end,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false or E.db.kfAA.Armory.Inspect.Gradation.Display == false or E.db.kfAA.Armory.Inspect.Gradation.CurrentClassColor == true end
						},
					}
				},
				Level = {
					type = 'group',
					name = L["Item Level"],
					order = 7,
					get = function(info) return E.db.kfAA.Armory.Inspect[(info[#info - 1])][(info[#info])] end,
					set = function(info, value) E.db.kfAA.Armory.Inspect[(info[#info - 1])][(info[#info])] = value; _G["InspectArmory"]:UpdateSettings("ilvl") end,
					args = {
						Display = {
							type = 'select',
							name = L["Visibility"],
							order = 1,
							set = function(info, value)
								E.db.kfAA.Armory.Inspect[(info[#info - 1])][(info[#info])] = value
								
								if _G["InspectArmory"].LastDataSetting then
									_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
								end
								_G["InspectArmory"]:Update_Display(true)
							end,
							values = DisplayMethodList,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						ShowUpgradeLevel = {
							type = 'toggle',
							name = L["Upgrade Level"],
							order = 2,
							set = function(_, value)
								E.db.kfAA.Armory.Inspect.Level.ShowUpgradeLevel = value
								
								if _G["InspectArmory"].LastDataSetting then
									_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
								end
							end,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						Space = {
							type = 'description',
							name = '',
							order = 3
						},
						Font = {
							type = 'select', dialogControl = 'LSM30_Font',
							name = L["Font"],
							order = 4,
							values = function()
								return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {}
							end,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						FontSize = {
							type = 'range',
							name = L["Font Size"],
							order = 5,
							min = 6,max = 22,step = 1,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						FontStyle = {
							type = 'select',
							name = L["Font Outline"],
							order = 6,
							values = FontStyleList,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						}
					}
				},
				Enchant = {
					type = 'group',
					name = L["Enchant String"],
					order = 9,
					get = function(info) return E.db.kfAA.Armory.Inspect[(info[#info - 1])][(info[#info])] end,
					set = function(info, value) E.db.kfAA.Armory.Inspect[(info[#info - 1])][(info[#info])] = value; _G["InspectArmory"]:UpdateSettings("ench") end,
					args = {
						Display = {
							type = 'select',
							name = L["Visibility"],
							order = 1,
							set = function(info, value)
								E.db.kfAA.Armory.Inspect[(info[#info - 1])][(info[#info])] = value
								
								if _G["InspectArmory"].LastDataSetting then
									_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
								end
								_G["InspectArmory"]:Update_Display(true)
							end,
							values = DisplayMethodList,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						WarningSize = {
							type = 'range',
							name = L["Warning Size"],
							order = 2,
							min = 6, max = 50, step = 1,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						WarningIconOnly = {
							type = 'toggle',
							name = L["Warning Only As Icons"],
							order = 3,
							set = function(_, value)
								E.db.kfAA.Armory.Inspect.Enchant.WarningIconOnly = value
								if _G["InspectArmory"].LastDataSetting then
									_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
								end
							end,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end,
						},
						Space = {
							type = 'description',
							name = '',
							order = 4
						},
						Font = {
							type = 'select', dialogControl = 'LSM30_Font',
							name = L["Font"],
							order = 5,
							values = function()
								return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {}
							end,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						FontSize = {
							type = 'range',
							name = L["Font Size"],
							order = 6,
							min = 6, max = 22, step = 1,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						FontStyle = {
							type = 'select',
							name = L["Font Outline"],
							order = 7,
							values = FontStyleList,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						}
					}
				},
				Gem = {
					type = 'group',
					name = L["Gem Sockets"],
					order = 11,
					get = function(Info) return E.db.kfAA.Armory.Inspect[(Info[#Info - 1])][(Info[#Info])] end,
					set = function(info, value) E.db.kfAA.Armory.Inspect[(info[#info - 1])][(info[#info])] = value; _G["InspectArmory"]:UpdateSettings("gem") end,
					args = {
						Display = {
							type = 'select',
							name = L["Visibility"],
							order = 1,
							set = function(Info, value)
								E.db.kfAA.Armory.Inspect[(Info[#Info - 1])][(Info[#Info])] = value
								if _G["InspectArmory"].LastDataSetting then
									_G["InspectArmory"]:InspectFrame_DataSetting(_G["InspectArmory"].CurrentInspectData)
								end
								_G["InspectArmory"]:Update_Display(true)
							end,
							values = DisplayMethodList,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						SocketSize = {
							type = 'range',
							name = L["Socket Size"],
							order = 2,
							min = 6,max = 50,step = 1,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
						WarningSize = {
							type = 'range',
							name = L["Warning Size"],
							order = 3,
							min = 6,max = 50,step = 1,
							disabled = function() return E.db.kfAA.Armory.Inspect.Enable == false end
						},
					}
				},
			}
		}
	end
end