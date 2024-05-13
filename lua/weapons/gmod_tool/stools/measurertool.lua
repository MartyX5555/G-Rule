
TOOL.Category = "Construction"
TOOL.Name = "#tool.measurertool.name"

TOOL.ClientConVar["mode"] = 1
TOOL.ClientConVar["unit"] = "Unit"

if SERVER then
	util.AddNetworkString("GRule_Network")
end

if CLIENT then

	TOOL.Information = {

		{ name = "left_1", icon = "gui/lmb.png",  stage = 0, op = 0 },
		{ name = "right_1", icon = "gui/rmb.png", stage = 0, op = 0 },
		{ name = "reload", icon = "gui/r.png" },

	}

	language.Add( "tool.measurertool.name", "Measurer Tool" )
	language.Add( "tool.measurertool.desc", "A tool used for measuring purposes." )
	language.Add( "tool.measurertool.left_1", "Set the Point 1" )
	language.Add( "tool.measurertool.right_1", "Set the Point 2" )
	language.Add( "tool.measurertool.reload", "Clear selection." )

end

-- Because gmod sucks.
local function GetClientValue(convar)
	local c = "measurertool_" .. convar
	return GetConVar(c):GetInt()
end
local function GetClientInfo(convar)
	local c = "measurertool_" .. convar
	return GetConVar(c):GetString()
end
local function SetClientData(convar, data)
	LocalPlayer():ConCommand("measurertool_" .. convar .. " " .. data )
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end

	local Owner = self:GetOwner()
	local CMode = self:GetClientNumber("mode")

	-- Basic measure feature. Similar to the ruler tool.
	if CMode == 1 then

		local HitPos = trace.HitPos
		net.Start("GRule_Network")
			net.WriteFloat(HitPos.x)
			net.WriteFloat(HitPos.y)
			net.WriteFloat(HitPos.z)

			net.WriteUInt(1, 2) -- tells if its the 1st or 2nd point.
			net.WriteEntity(self)
		net.Send(Owner)
	end

	return true
end

function TOOL:RightClick(trace)
	if CLIENT then return true end

	local Owner = self:GetOwner()
	local CMode = self:GetClientNumber("mode")

	-- Basic measure feature. Similar to the ruler tool.
	if CMode == 1 then

		local HitPos = trace.HitPos
		net.Start("GRule_Network")
			net.WriteFloat(HitPos.x)
			net.WriteFloat(HitPos.y)
			net.WriteFloat(HitPos.z)

			net.WriteUInt(2, 2) -- tells if its the 1st or 2nd point.
			net.WriteEntity(self)
		net.Send(Owner)
	end

	return true
end

function TOOL:Reload(trace)
	if CLIENT then return true end

	return true
end

do

	GRULE = GRULE or {}
	GRULE.UnitConversion = {
		["Unit"] = {
			idx = 1,
			name = "Source Unit (u)",
			sname = "unit",
			lname = "unit",
			convformula = function(value) return value end,
		},
		["Inche"] = {
			idx = 2,
			name = "Inche (inch)",
			sname = "inch",
			lname = "inch",
			convformula = function(value) return value end, -- To tell you that inches are EQUAL TO units sources
		},
		["Millimeter"] = {
			idx = 3,
			name = "Millimeter (mm)",
			sname = "mm",
			lname = "millimeters",
			convformula = function(value) return value * 25.4 end,
		},
		["Centimeter"] = {
			idx = 4,
			name = "Centimeter (cm)",
			sname = "cm",
			lname = "centimeters",
			convformula = function(value) return value * 2.54 end,
		},
		["Decimeter"] = {
			idx = 5,
			name = "Decimeter (dm)",
			sname = "dm",
			lname = "decimeters",
			convformula = function(value) return value / 3.937 end,
		},
		["Meter"] = {
			idx = 6,
			name = "Meter (m)",
			sname = "m",
			lname = "meters",
			convformula = function(value) return value / 39.37 end,
		},
		["Kilometer"] = {
			idx = 7,
			name = "Kilometer (km)",
			sname = "km",
			lname = "kilometers",
			convformula = function(value) return value / 39370 end,
		},
		["Megameter"] = {
			idx = 8,
			name = "Megameter (Mm)",
			sname = "Mm",
			lname = "megameters",
			convformula = function(value) return value / 39370000 end,
		},
		["Gigameter"] = {
			idx = 9,
			name = "Gigameter (Gm)",
			sname = "Gm",
			lname = "gigameters",
			convformula = function(value) return value / 39370000000 end,
		},
		["Terameter"] = {
			idx = 10,
			name = "Terameter (Tm)",
			sname = "Tm",
			lname = "terameters",
			convformula = function(value) return value / 39370000000000. end,
		},
	}
	GRULE.CPoints = {}

	-- We cannot rely on client trace detection. Thats why we are getting the hits from the serverside, then sent to client. Sad.
	net.Receive("GRule_Network", function()

		local CMode = GetClientValue("Mode")
		if CMode == 1 then

			print("received")

			local X = net.ReadFloat()
			local Y = net.ReadFloat()
			local Z = net.ReadFloat()

			local Idx = net.ReadUInt(2)

			GRULE.CPoints[Idx] = Vector(X, Y, Z)
		end
	end)

	function TOOL.BuildCPanel(panel)
		panel:Help("#tool.measurertool.desc")

		-- Unit Measurement ComboBox
		local combo = vgui.Create( "DComboBox" )
		combo:SetSortItems( false )
		panel:AddItem(combo)

		-- Create an array to hold the sorted elements
		local sortedArray = {}

		-- Populate the array with elements containing both key and value pairs
		for id, content in pairs(GRULE.UnitConversion) do
			table.insert(sortedArray, { id = id, content = content })
		end

		-- Sort the array based on the 'idx' field
		table.sort(sortedArray, function(a, b) return a.content.idx < b.content.idx end)

		for _, v in ipairs(sortedArray) do
			combo:AddChoice( v.content.name, v.id )
		end
		function combo:OnSelect( _, name, data )
			SetClientData("Unit", data)
		end
	end

	local function RenderCross(Pos, Color)
		local Factor = 10
		local Forward = Vector(Factor,0,0)
		local Right = Vector(0,Factor,0)
		local Up = Vector(0, 0, Factor)

		render.DrawLine( Pos - Forward, Pos + Forward, Color or color_white, true )
		render.DrawLine( Pos - Right, Pos + Right, Color or color_white, true)
		render.DrawLine( Pos - Up, Pos + Up, Color or color_white, true )
	end

	local function FormatDistaceText( dist )
		local UnitTable = GRULE.UnitConversion
		local CUnit = GetClientInfo("unit")
		local UnitData = UnitTable[CUnit]
		if not next(UnitData) then UnitData = UnitTable["Unit"] end
		local toUnit = UnitData.convformula
		local UnitName = UnitData.sname
		local txt = toUnit(dist) .. " " .. UnitName

		return txt
	end

	-- Create a simple rect between 2 points.
	local function CreateBasicRuleRect(Pos1, Pos2)

			local dist = (Pos2 - Pos1):Length()
			local avgPos = (Pos1 + Pos2) / 2
			local Dist2D = avgPos:ToScreen()

			cam.Start2D()
				if Dist2D.visible then
					draw.SimpleTextOutlined(FormatDistaceText( dist ), "HudDefault", Dist2D.x, Dist2D.y + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,Color(0,0,0, 255) )
				end
			cam.End2D()

			render.DrawLine(Pos1, Pos2, color_white, true )
			RenderCross(Pos1, Color(0,83,167))
			RenderCross(Pos2, Color(255,150,0,255))
	end

	hook.Remove("PostDrawTranslucentRenderables", "GRule_renders")
	hook.Add("PostDrawTranslucentRenderables", "GRule_renders", function()

		-- Between 2 Points
		do
			local Point1 = GRULE.CPoints[1]
			local Point2 = GRULE.CPoints[2]

			if Point1 and Point2 then
				CreateBasicRuleRect(Point1, Point2)
			end
		end
	end)

end



