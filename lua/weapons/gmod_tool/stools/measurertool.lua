
TOOL.Category = "Construction"
TOOL.Name = "#tool.measurertool.name"

TOOL.ClientConVar["mode"] = "basic"
TOOL.ClientConVar["unit"] = "unit"
TOOL.ClientConVar["rounded"] = 1
TOOL.ClientConVar["longname"] = 0
TOOL.ClientConVar["mapscale"] = 0

if SERVER then
	util.AddNetworkString("GRule_Network")
end

if CLIENT then

	TOOL.Information = {

		-- Honestly, i have no idea how this could go inside of the mode files.
		-- Basic
		{ name = "left_1", icon = "gui/lmb.png",  op = 0, stage = 0 },
		{ name = "right_1", icon = "gui/rmb.png", op = 0, stage = 0 },

		--HitPlane
		{ name = "left_2", icon = "gui/lmb.png",  op = 1, stage = 0 },

		--HitPlane2
		{ name = "left_3", icon = "gui/lmb.png",  op = 2, stage = 0 },
		{ name = "right_3", icon = "gui/rmb.png", op = 2, stage = 0 },


		{ name = "reload", icon = "gui/r.png" },

	}

	language.Add( "tool.measurertool.name", "Measurer Tool" )
	language.Add( "tool.measurertool.desc", "A tool used for measuring purposes." )

	language.Add( "tool.measurertool.left_1", "Set the Point 1" )
	language.Add( "tool.measurertool.right_1", "Set the Point 2" )

	language.Add( "tool.measurertool.left_2", "Set the Point to start the backtrace." )

	language.Add( "tool.measurertool.left_3", "Set the Point 1 and the Normal where the direction will be perpendicular to" )
	language.Add( "tool.measurertool.right_3", "Set the Point 2 and Magnitude" )


	language.Add( "tool.measurertool.reload", "Clear selection." )

end

-- Because gmod sucks.
local function GetClientInfo(convar)
	local c = "measurertool_" .. convar
	return GetConVar(c):GetString()
end

local function SetClientData(convar, data)
	LocalPlayer():ConCommand("measurertool_" .. convar .. " " .. data )
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end

	local CMode = self:GetClientInfo("mode")
	local modedata = GRule.GetModeInfo(CMode)
	modedata.LeftClick(self, trace)

	return true
end

function TOOL:RightClick(trace)
	if CLIENT then return true end

	local CMode = self:GetClientInfo("mode")
	local modedata = GRule.GetModeInfo(CMode)
	modedata.RightClick(self, trace)

	return true
end

function TOOL:Reload(trace)
	if SERVER then return true end

	local CMode = GetClientInfo("mode")
	local modedata = GRule.GetModeInfo(CMode)
	modedata.Reload(self, trace)

	return true
end

function TOOL:Think()
	if CLIENT then return end

	local CMode = self:GetClientInfo("mode")
	local modedata = GRule.GetModeInfo(CMode)

	if modedata.operation ~= self:GetOperation() then
		self:SetOperation(modedata.operation)
	end
end

do

	function TOOL.BuildCPanel(panel)

		local UnitConversion = GRule.UnitConversion
		local ToolModes = GRule.ToolModes

		panel:Help("#tool.measurertool.desc")

		panel:CheckBox("Round measures", "measurertool_rounded")
		panel:ControlHelp( "Rounds the distances to whole numbers." )

		panel:CheckBox("Map Scale", "measurertool_mapscale")
		panel:ControlHelp( "Uses the Architecture scale factor (1 unit = 0.75 inch)")

		panel:CheckBox("Full name", "measurertool_longname")
		panel:ControlHelp( "Should the measure unit be fully displayed or not?")

		do
			-- Unit Measurement ComboBox
			local combo = vgui.Create( "DComboBox" )
			combo:SetSortItems( false )
			panel:AddItem(combo)

			-- Create an array to hold the sorted elements
			local sortedArray = {}

			-- Populate the array with elements containing both key and value pairs
			for id, content in pairs(UnitConversion) do
				table.insert(sortedArray, { id = id, content = content })
			end

			-- Sort the array based on the 'idx' field
			table.sort(sortedArray, function(a, b) return a.content.idx < b.content.idx end)

			for _, v in ipairs(sortedArray) do
				combo:AddChoice( v.content.name, v.id )
			end
			function combo:OnSelect( _, name, data )
				SetClientData("unit", data)
			end
			combo:SetValue(UnitConversion[GetClientInfo("unit")].name)

		end
		do

			-- Rule Mode ComboBox
			local modecombo = vgui.Create( "DComboBox" )
			panel:AddItem(modecombo)

			-- Populate the array with elements containing both key and value pairs
			for id, data in pairs(ToolModes) do
				modecombo:AddChoice( data.name, id )
			end
			function modecombo:OnSelect( _, name, data )
				GRule.CPoints = {}
				SetClientData("mode", data)
			end
			modecombo:SetValue(ToolModes[GetClientInfo("mode")].name)

		end
	end
end



