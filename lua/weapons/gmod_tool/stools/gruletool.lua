TOOL.Category = "Construction"
TOOL.Name = "#tool.gruletool.name"

TOOL.ClientConVar["mode"] = "basic"
TOOL.ClientConVar["unit"] = "unit"
TOOL.ClientConVar["roundcount"] = 2

TOOL.ClientConVar["longname"] = 0
TOOL.ClientConVar["mapscale"] = 0
TOOL.ClientConVar["posparent"] = 0

if SERVER then
	util.AddNetworkString("GRule_Network")
	util.AddNetworkString("GRule_ClientFix")
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

		--space
		{ name = "left_4", icon = "gui/lmb.png",  op = 3, stage = 0 },
		{ name = "right_4", icon = "gui/rmb.png", op = 3, stage = 0 },

		{ name = "reload", icon = "gui/r.png" },

	}

	language.Add( "tool.gruletool.name", "G-Rule" )
	language.Add( "tool.gruletool.desc", "A tool used for measuring purposes." )

	language.Add( "tool.gruletool.left_1", "Set the Point 1" )
	language.Add( "tool.gruletool.right_1", "Set the Point 2" )

	language.Add( "tool.gruletool.left_2", "Set the Point to start the backtrace." )

	language.Add( "tool.gruletool.left_3", "Set the Point 1 and the Normal where the direction will be perpendicular to" )
	language.Add( "tool.gruletool.right_3", "Set the Point 2 and Magnitude" )

	language.Add( "tool.gruletool.left_4", "Sets the Point at a specific position" )
	language.Add( "tool.gruletool.right_4", "Sets the Point at origin vector." )

	language.Add( "tool.gruletool.reload", "Clear selection." )

end

-- Because gmod sucks.
local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

local function SetClientData(convar, data)
	LocalPlayer():ConCommand("gruletool_" .. convar .. " " .. data )
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

--dealing with the singleplayer no client realms...
local function DoReload(tool, trace)
	local CMode = GetClientInfo("mode")
	local modedata = GRule.GetModeInfo(CMode)
	modedata.Reload(tool, trace)
end

function TOOL:Reload(trace)
	if game.SinglePlayer() then
		net.Start("GRule_ClientFix")
			net.WriteEntity(self)
		net.Send(self:GetOwner())
	elseif CLIENT then
		DoReload(self, trace)
	end

	return true
end

--dealing with the singleplayer no client realms...
local toolmask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )

net.Receive("GRule_ClientFix", function()

	local tool = net.ReadEntity()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	tr.mask = toolmask
	tr.mins = vector_origin
	local trace = util.TraceLine( tr )

	DoReload(tool, trace)
end)

function TOOL:Think()
	if CLIENT then return end

	local CMode = self:GetClientInfo("mode")
	local modedata = GRule.GetModeInfo(CMode)

	if modedata.operation ~= self:GetOperation() then
		self:SetOperation(modedata.operation)
	end
end

do

	local function CreateSpacer(panel)
		local Spacer = vgui.Create("DLabel", panel)
		Spacer:SetSize( ScrW(), 20 ) -- CONCERN: no clue how to get controlpanel Height. Using the manual way.
		Spacer:SetText("")
		function Spacer:Paint(w, h)
			draw.RoundedBox( 5, 0, h / 2, w, 2, Color(150,150,150) )
		end
		panel:AddItem(Spacer)
	end

	local function createSubPanel(panel, CMode)

		panel.subpanel:Clear()
		panel.subpanel:Hide()

		if CMode.CPanelCustom then
			panel.subpanel:Show()
			CMode.CPanelCustom(panel.subpanel)
		end
	end

	function TOOL.BuildCPanel(panel)

		local UnitConversion = GRule.UnitConversion
		local ToolModes = GRule.ToolModes

		panel:Help("#tool.gruletool.desc")

		panel:NumSlider( "Decimal count", "gruletool_roundcount", 0, 11, 0)
		panel:ControlHelp( "Rounds the distances according to the decimal count." )

		panel:CheckBox("Map Scale", "gruletool_mapscale")
		panel:ControlHelp( "Uses the Architecture scale factor (1 unit = 0.75 inch)")

		panel:CheckBox("Full name", "gruletool_longname")
		panel:ControlHelp( "Should the measure unit be fully displayed or not?")

		local parentcheck = panel:CheckBox("Attach points to props", "gruletool_posparent")
		panel:ControlHelp( "If applied on a prop, the point will be attached.")

		CreateSpacer(panel)

		do
			-- Unit Measurement ComboBox
			local combo = vgui.Create( "DComboBox" )
			combo:SetTooltip( "Choose the unit. Hammer Units are not affected by the current unit scale." )
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
				timer.Simple(0.05, function()
					GRule.CanPing = true
				end)
			end
			combo:SetValue(UnitConversion[GetClientInfo("unit")].name)

		end
		do

			local Mode = ToolModes[GetClientInfo("mode")]
			-- Rule Mode ComboBox
			local modecombo = vgui.Create( "DComboBox" )
			modecombo:SetTooltip( "Choose the mode this tool will operate." )
			panel:AddItem(modecombo)

			-- Populate the array with elements containing both key and value pairs
			for id, data in pairs(ToolModes) do
				modecombo:AddChoice( data.name, id )
			end

			modecombo:SetValue(Mode.name)
			local desc = panel:Help(Mode.desc)
			function modecombo:OnSelect( _, name, data )
				GRule.CPoints = {}

				SetClientData("mode", data)

				-- For some reason, setting it to 0 causes the panel to not be correctly built
				timer.Simple(0.05,function()
					local CMode = ToolModes[GetClientInfo("mode")]
					desc:SetText(CMode.desc)
					parentcheck:SetEnabled( CMode.hasparentpoints )

					createSubPanel(panel, CMode)

					panel:GetParent():InvalidateChildren( true )
				end)

			end
			parentcheck:SetEnabled( Mode.hasparentpoints )

			panel.subpanel = vgui.Create("DForm", panel)
			panel:AddItem(panel.subpanel)

			createSubPanel(panel, Mode)
		end

		CreateSpacer(panel)

		panel:Help("Documentation about this tool can be found here.")
		local HelpButton = vgui.Create("DButton", panel)
		HelpButton:SetText("See documentation")
		HelpButton:SetIcon("icon16/book_open.png")
		function HelpButton:DoClick()
			gui.OpenURL("https://github.com/MartyX5555/G-Rule/wiki")
		end
		panel:AddItem(HelpButton)

	end

end



