--[[
	Key Documentation: https://developer.valvesoftware.com/wiki/Dimensions_(Half-Life_2_and_Counter-Strike:_Source)#Source_Engine_Scale_Calculations

	Demostration:

		For Mapscale:

		According to valve, 1 foot is equal to 16 units if we consider the mapscale, and in real life, 1 foot is 12 inches. So we can say:

		1 foot => 16 units
		12 inches => 16 units

		So, if we want to know how many inches is 1 unit, we can just do the following ratio:

		12 inches => 16 units
		x inches => 1 unit

		With this, we will just divide the 12 inches by the units we know.

		x = 12 / 16 = 0.75

		And, as you can see, 0.75 inches is equal to 1 unit MAPSCALE, resulting into a bigger figures from the player's perspective.

		For Playerscale:

		Now, for playerscale, 1 foot is equal to 12 units, 4 units less than mapscale. Taking into consideration that 1 foot is 12 inches, we can say:

		1 foot => 12 units
		12 inches = 12 units

		So, just analyze this ratio, did you see that 1 unit is literally one inch? Yeah, thats it. 1 inch IS 1 unit for playerscale.

]]

GRule = GRule or {}

GRule.ToolModes = GRule.ToolModes or {}
GRule.CPoints = GRule.CPoints or {}
GRule.HitNormals = GRule.HitNormals or {}
GRule.Timers = GRule.Timers or {}

-- Conversion table. All the formulas below are based FROM the inche TO [unit here]. Credits to google and its unit converter
GRule.UnitConversion = {
	["unit"] = {
		idx = 1,
		name = "Hammer Unit (unit)",
		sname = "unit",
		lname = "hammer units",
		convformula = function(value) return value end, -- no changes between playerscale and mapscale.
	},
	["inche"] = {
		idx = 2,
		name = "Inch (in)",
		sname = "in",
		lname = "inches",
		convformula = function(value) return value end, -- To tell you that inches are EQUAL TO units sources. However, not the case for map scale
	},
	["feet"] = {
		idx = 3,
		name = "Foot (ft)",
		sname = "ft",
		lname = "feet",
		convformula = function(value) return value / 12 end,
	},
	["millimeter"] = {
		idx = 4,
		name = "Millimeter (mm)",
		sname = "mm",
		lname = "millimeters",
		convformula = function(value) return value * 25.4 end,
	},
	["centimeter"] = {
		idx = 5,
		name = "Centimeter (cm)",
		sname = "cm",
		lname = "centimeters",
		convformula = function(value) return value * 2.54 end,
	},
	["decimeter"] = {
		idx = 6,
		name = "Decimeter (dm)",
		sname = "dm",
		lname = "decimeters",
		convformula = function(value) return value / 3.937 end,
	},
	["meter"] = {
		idx = 7,
		name = "Meter (m)",
		sname = "m",
		lname = "meters",
		convformula = function(value) return value / 39.37 end,
	},
	["kilometer"] = {
		idx = 8,
		name = "Kilometer (km)",
		sname = "km",
		lname = "kilometers",
		convformula = function(value) return value / 39370 end,
	},
	["megameter"] = {
		idx = 9,
		name = "Megameter (Mm)",
		sname = "Mm",
		lname = "megameters",
		convformula = function(value) return value / 39370000 end,
	},
	["gigameter"] = {
		idx = 10,
		name = "Gigameter (Gm)",
		sname = "Gm",
		lname = "gigameters",
		convformula = function(value) return value / 39370000000 end,
	},
	["terameter"] = {
		idx = 11,
		name = "Terameter (Tm)",
		sname = "Tm",
		lname = "terameters",
		convformula = function(value) return value / 39370000000000. end,
	},
	["astrounit"] = {
		idx = 12,
		name = "Astronomical Unit (AU)",
		sname = "AU",
		lname = "astronomical units",
		convformula = function(value) return value / 5890000000000 end,
	},
	["lightyear"] = {
		idx = 13,
		name = "Light-year (ly)",
		sname = "ly",
		lname = "light-year",
		convformula = function(value) return value / 372500000000000000. end,
	},
	["parsec"] = {
		idx = 14,
		name = "Parsec (pc)",
		sname = "pc",
		lname = "parsecs",
		convformula = function(value) return value / 1215000000000000000. end,
	},
	["kiloparsec"] = {
		idx = 15,
		name = "Kiloparsec (kpc)",
		sname = "kpc",
		lname = "kiloparsecs",
		convformula = function(value) return value / 1215000000000000000000 end,
	},
	["megaparsec"] = {
		idx = 16,
		name = "Megaparsec (Mpc)",
		sname = "Mpc",
		lname = "megaparsecs",
		convformula = function(value) return value / 1215000000000000000000000 end,
	},
	["gigaparsec"] = {
		idx = 17,
		name = "Gigaparsec (Gpc)",
		sname = "Gpc",
		lname = "gigaparsecs",
		convformula = function(value) return value / 1215000000000000000000000000 end,
	},--
	["teraparsec"] = {
		idx = 18,
		name = "Teraparsec (Tpc)",
		sname = "Tpc",
		lname = "teraparsecs",
		convformula = function(value) return value / 1215000000000000000000000000000 end,
	},--
	["mile"] = {
		idx = 19,
		name = "Mile (mi)",
		sname = "mi",
		lname = "Miles",
		convformula = function(value) return value / 63360 end,
	},
	["naumile"] = {
		idx = 20,
		name = "Nautic Mile (nm)",
		sname = "nm",
		lname = "Nautic Miles",
		convformula = function(value) return value / 72910 end,
	},
}
do
	local function IsReallyValidTable(tbl)
		if not istable(tbl) then return false end
		if not next(tbl) then return false end

		return true
	end

	function GRule.GetModeInfo(mode)
		local ToolModes = GRule.ToolModes
		return IsReallyValidTable(ToolModes[mode]) and ToolModes[mode] or ToolModes["basic"]
	end
end


if SERVER then

	local function Encode(data)
		local json = util.TableToJSON(data)
		local binary = util.Compress(json)
		return binary
	end

	function GRule.NetworkData(dest, data, ply)

		data.dest = dest
		local binary = Encode(data)
		local bytes = #binary

		net.Start("GRule_Network")
			net.WriteData(binary, bytes)
		net.Send(ply)
	end
end

if CLIENT then


	do
		local function Decode(bin)
			local json = util.Decompress(bin)
			local data = util.JSONToTable(json)
			return data
		end

		net.Receive("GRule_Network", function(len)
			local binary = net.ReadData(len)
			local data = Decode(binary)
			local modeinfo = GRule.GetModeInfo(data.dest)
			modeinfo.ReceivePosition(data)
		end)
	end

	do

		local function GetClientValue(convar)
			local c = "gruletool_" .. convar
			return GetConVar(c):GetInt()
		end

		local function GetClientInfo(convar)
			local c = "gruletool_" .. convar
			return GetConVar(c):GetString()
		end

		local function NotifyChat(txt)
			chat.AddText(Color(255,255,0), "[-GRule-] ", color_white, "Distance: " .. txt)
		end

		function GRule.FormatDistanceText(dist)
			local UnitTable   = GRule.UnitConversion
			local CUnit       = GetClientInfo("unit")
			local UnitData    = next(UnitTable) and UnitTable[CUnit] or UnitTable["unit"]
			local toUnit      = UnitData.convformula
			local roundCount  = GetClientValue("roundcount") or 0
			local Fdist 	  = math.Round(toUnit(dist), roundCount)
			local UnitName    = GetClientValue("longname") > 0 and UnitData.lname or UnitData.sname

			local txt = Fdist .. " " .. UnitName
			return txt
		end

		local Black = Color(0,0,0, 255)
		function GRule.RenderCross(Idx, Pos, C)
			local Factor = 10
			local Forward = Vector(Factor,0,0)
			local Right = Vector(0,Factor,0)
			local Up = Vector(0, 0, Factor)
			local TextScr = Pos:ToScreen()

			render.DrawLine( Pos - Forward, Pos + Forward, C or color_white, true )
			render.DrawLine( Pos - Right, Pos + Right, C or color_white, true)
			render.DrawLine( Pos - Up, Pos + Up, C or color_white, true )

			cam.Start2D()
				if TextScr.visible then
					draw.SimpleTextOutlined(Idx, "HudDefault", TextScr.x + 5, TextScr.y + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Black )
				end
			cam.End2D()
		end

		-- Create a simple rect between 2 points.
		function GRule.CreateBasicRuleRect(Pos1, Pos2)

			local factor = (GetClientValue("mapscale") > 0 and GetClientInfo("unit") ~= "unit") and 0.75 or 1
			local dir = (Pos2 - Pos1)
			local dist = dir:Length() * factor

			-- Universe like size workaround. May lose a lot of precision due to the mega distances, but better than returning an inf.
			-- The workaround is simply using the chunk value instead of unit, since 1 chunk = 10000 units wide
			-- Bro, seriously, the amount of precision loss is insane, blame lua by doing this!!
			if InfMap and dist >= 10000000000000000000000000000 then -- aproximately 15 parsecs.
				local _, c1 = InfMap.localize_vector(Pos1)
				local _, c2 = InfMap.localize_vector(Pos2)

				local big = 0.0000000000000000000000001
				local newdir = c2 - c1 
				local thing = newdir  * big
				local thing2 = thing:Length()
				dir = newdir
				dist = (thing2 / big) * InfMap.chunk_size * factor * 2
			end

			local avgPos = (Pos1 + Pos2) / 2
			local Dist2D = avgPos:ToScreen()
			local formatteddist = GRule.FormatDistanceText( dist )

			local angles = dir:Angle()
			angles:Normalize()
			local formattedang = "Angle: " .. tostring(angles)

			cam.Start2D()
				if Dist2D.visible then
					draw.SimpleTextOutlined(formatteddist, "HudDefault", Dist2D.x, Dist2D.y + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,Color(0,0,0, 255) )
					draw.SimpleTextOutlined(formattedang, "HudDefault", Dist2D.x, Dist2D.y + 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,Color(0,0,0, 255) )
				end
			cam.End2D()

			render.DrawLine(Pos1, Pos2, color_white, true )

			if GRule.CanPing then
				GRule.CanPing = nil
				NotifyChat(formatteddist)
			end
		end
	end
end

include("autorun/measurermodes/basic.lua")
include("autorun/measurermodes/basicsnap.lua")
include("autorun/measurermodes/hitnormal.lua")
include("autorun/measurermodes/poshitnormal.lua")
include("autorun/measurermodes/multiple.lua")
include("autorun/measurermodes/space.lua")
