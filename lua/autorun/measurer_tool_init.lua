GRule = {}

GRule.ToolModes = {}
GRule.CPoints = {}

GRule.UnitConversion = {
	["unit"] = {
		idx = 1,
		name = "Source Unit (u)",
		sname = "unit",
		lname = "source units",
		convformula = function(value) return value end,
	},
	["inche"] = {
		idx = 2,
		name = "Inche (inch)",
		sname = "inch",
		lname = "inches",
		convformula = function(value) return value end, -- To tell you that inches are EQUAL TO units sources
	},
	["millimeter"] = {
		idx = 3,
		name = "Millimeter (mm)",
		sname = "mm",
		lname = "millimeters",
		convformula = function(value) return value * 25.4 end,
	},
	["centimeter"] = {
		idx = 4,
		name = "Centimeter (cm)",
		sname = "cm",
		lname = "centimeters",
		convformula = function(value) return value * 2.54 end,
	},
	["decimeter"] = {
		idx = 5,
		name = "Decimeter (dm)",
		sname = "dm",
		lname = "decimeters",
		convformula = function(value) return value / 3.937 end,
	},
	["meter"] = {
		idx = 6,
		name = "Meter (m)",
		sname = "m",
		lname = "meters",
		convformula = function(value) return value / 39.37 end,
	},
	["kilometer"] = {
		idx = 7,
		name = "Kilometer (km)",
		sname = "km",
		lname = "kilometers",
		convformula = function(value) return value / 39370 end,
	},
	["megameter"] = {
		idx = 8,
		name = "Megameter (Mm)",
		sname = "Mm",
		lname = "megameters",
		convformula = function(value) return value / 39370000 end,
	},
	["gigameter"] = {
		idx = 9,
		name = "Gigameter (Gm)",
		sname = "Gm",
		lname = "gigameters",
		convformula = function(value) return value / 39370000000 end,
	},
	["terameter"] = {
		idx = 10,
		name = "Terameter (Tm)",
		sname = "Tm",
		lname = "terameters",
		convformula = function(value) return value / 39370000000000. end,
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

include("autorun/measurermodes/basic.lua")
include("autorun/measurermodes/hitnormal.lua")




