--[[
	This is a framework showing how to create a plugin for ElvUI.
	It creates some default options and inserts a GUI table to the ElvUI Config.
	If you have questions then ask in the Tukui lua section: http://www.tukui.org/forums/forum.php?id=27
]]

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2
local AdvancedArmory = E:NewModule(addonName, 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.

--Default options
P["AdvancedArmory"] = {
	["SomeToggleOption"] = true,
	["SomeRangeOption"] = 5,
}

--Function we can call when a setting changes.
--In this case it just checks if "SomeToggleOption" is enabled. If it is it prints the value of "SomeRangeOption", otherwise it tells you that "SomeToggleOption" is disabled.
function AdvancedArmory:Update()
	local enabled = E.db.AdvancedArmory.SomeToggleOption
	local range = E.db.AdvancedArmory.SomeRangeOption
	
	if enabled then
		print(range)
	else
		print("SomeToggleOption is disabled")
	end
end

--This function inserts our GUI table into the ElvUI Config. You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function AdvancedArmory:InsertOptions()
	E.Options.args.AdvancedArmory = {
		order = 100,
		type = "group",
		name = "AdvancedArmory",
		args = {
			SomeToggleOption = {
				order = 1,
				type = "toggle",
				name = "MyToggle",
				get = function(info)
					return E.db.AdvancedArmory.SomeToggleOption
				end,
				set = function(info, value)
					E.db.AdvancedArmory.SomeToggleOption = value
					AdvancedArmory:Update() --We changed a setting, call our Update function
				end,
			},
			SomeRangeOption = {
				order = 1,
				type = "range",
				name = "MyRange",
				min = 0,
				max = 10,
				step = 1,
				get = function(info)
					return E.db.AdvancedArmory.SomeRangeOption
				end,
				set = function(info, value)
					E.db.AdvancedArmory.SomeRangeOption = value
					AdvancedArmory:Update() --We changed a setting, call our Update function
				end,
			},
		},
	}
end

function AdvancedArmory:Initialize()
	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, AdvancedArmory.InsertOptions)
end

E:RegisterModule(AdvancedArmory:GetName()) --Register the module with ElvUI. ElvUI will now call AdvancedArmory:Initialize() when ElvUI is ready to load our plugin.