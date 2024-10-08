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

	surface.CreateFont( "GRule_ToolScreenTitle", { font = "HudDefault", size = 40, weight = 1000 } )
	surface.CreateFont( "GRule_ToolScreenUnit", { font = "HudHintTextLarge", size = 25, weight = 750 } )

end

-- Because gmod sucks.
local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

local function GetClientValue(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetInt()
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

		panel:NumSlider("#tool.gruletool.roundslider", "gruletool_roundcount", 0, 11, 0)
		panel:ControlHelp("#tool.gruletool.roundtip" )

		panel:CheckBox("#tool.gruletool.mapscalebox", "gruletool_mapscale")
		panel:ControlHelp("#tool.gruletool.mapscaleboxtip")

		panel:CheckBox("#tool.gruletool.fullnamebox", "gruletool_longname")
		panel:ControlHelp("#tool.gruletool.fullnameboxtip")

		local parentcheck = panel:CheckBox("#tool.gruletool.posparentbox", "gruletool_posparent")
		panel:ControlHelp("#tool.gruletool.posparentboxtip")

		CreateSpacer(panel)

		do
			-- Unit Measurement ComboBox
			local combo = vgui.Create( "DComboBox" )
			combo:SetTooltip( "#tool.gruletool.unitcombotip" )
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
			modecombo:SetTooltip( "#tool.gruletool.modecombotip" )
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

		panel:Help("#tool.gruletool.documentation")
		local HelpButton = vgui.Create("DButton", panel)
		HelpButton:SetText("#tool.gruletool.documentation.button")
		HelpButton:SetIcon("icon16/book_open.png")
		function HelpButton:DoClick()
			gui.OpenURL("https://github.com/MartyX5555/G-Rule/wiki")
		end
		panel:AddItem(HelpButton)

	end

	local blockmargin = 10
	local TopColor = Color( 255, 128, 0)
	local TitleColor = Color( 255, 255, 255)
	local BackGroundCol = Color( 50, 50, 50 )
	local BackGroundPanelCol = Color(35,35,35)

	-- Taken and modified from: https://github.com/Facepunch/garrysmod/blob/70bd0e3970b816df2de6449ec2f4c43f7a9a328e/garrysmod/gamemodes/sandbox/entities/weapons/gmod_tool/cl_viewscreen.lua#L16
	local function DrawScrollingText( text, y, texwide )

		local w, _ = surface.GetTextSize( text )
		w = w + 256

		local x = RealTime() * 125 % w * -1

		while ( x < texwide ) do
			draw.SimpleText( text, "GRule_ToolScreenTitle", x, y, TitleColor, nil, TEXT_ALIGN_CENTER)

			x = x + w

		end
	end

	function TOOL:DrawToolScreen( width, height )

		local CMode = GetClientInfo("mode")
		local modedata = GRule.GetModeInfo(CMode)

		local CUnit = GetClientInfo("unit")
		local unitdata = GRule.GetUnitInfo(CUnit)

		local currentmode = language.GetPhrase( "#tool.gruletool.currentmode" )
		local realName = language.GetPhrase( modedata.name ) -- otherwise, we have the raw placeholder string instead.

		-- Draw black background
		surface.SetDrawColor( BackGroundCol )
		surface.DrawRect( 0, 0, width, height )

		do
			-- Draw Top border + Title
			surface.SetDrawColor( Color(0,0,0) )
			surface.DrawRect( 0, 0, width, 48 )

			surface.SetDrawColor( TopColor )
			surface.DrawRect( 0, 0, width, 45 )

			-- Draw white text in middle
			draw.SimpleText( "#tool.gruletool.name", "GRule_ToolScreenTitle", width / 2, 45 / 2, TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		do

			-- expand the black background.
			if #realName > 13 then
				surface.SetDrawColor( BackGroundPanelCol )
				surface.DrawRect( 0, 60, width, 80 )
				draw.SimpleText( currentmode, "HudDefault", width / 2, 70, TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			else
				draw.RoundedBox( 14, blockmargin, 60, width - (blockmargin * 2), 80, BackGroundPanelCol )
				draw.SimpleText( currentmode, "HudDefault", width / 2, 70, TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

			-- start scrolling the text if its longer than specified
			if #realName > 14 then
				DrawScrollingText( realName, 110, 256 )
			else
				draw.SimpleText( realName, "GRule_ToolScreenTitle", width / 2, 110, TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
		do
			draw.RoundedBox( 14, blockmargin, 145, width - (blockmargin * 2), 50, BackGroundPanelCol )
			draw.SimpleText( unitdata.name, "GRule_ToolScreenUnit", width / 2, 170, TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end
		do

			local scale = GetClientValue("mapscale") > 0 and language.GetPhrase("#tool.gruletool.signalmap") or language.GetPhrase("#tool.gruletool.signalplayer")
			if CUnit == "unit" then
				scale = language.GetPhrase("#tool.gruletool.signalnoscale")
			end

			local scaletxt = language.GetPhrase("#tool.gruletool.currentscale") .. ": " .. scale
			draw.RoundedBox( 14, blockmargin, 200, width - (blockmargin * 2), 50, BackGroundPanelCol )
			draw.SimpleText( scaletxt , "GRule_ToolScreenUnit", width / 2, 225, TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end


	end

end



