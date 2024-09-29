AddCSLuaFile()

local Mode = {}

Mode.id = "space"
Mode.name = "#tool.gruletool.space.name"
Mode.desc = "#tool.gruletool.space.desc"
Mode.operation = 3

local function SendPosition(idx, PointPos, tool)

	local data = {
		Idx = idx,
		Tool = tool,
		PosX = PointPos.x,
		PosY = PointPos.y,
		PosZ = PointPos.z,
	}

	GRule.NetworkData(Mode.id, data, tool:GetOwner())
end

function Mode.ReceivePosition(data)

	local X = data.PosX
	local Y = data.PosY
	local Z = data.PosZ
	local Idx = data.Idx

	GRule.CPoints[Idx] = Vector(X, Y, Z)
	GRule.CanPing = true
end

function Mode.LeftClick(tool, trace)
	local HitPos = trace.HitPos
	SendPosition(1, HitPos, tool)
end

function Mode.RightClick(tool, trace)
	SendPosition(1, vector_origin, tool)
end

function Mode.Reload(tool, trace)
	GRule.CPoints = {}
end

local function updatePoint(idx, ply)

	local pos = ply:WorldSpaceCenter()
	if InfMap then
		pos = InfMap.unlocalize_vector(ply:InfMap_WorldSpaceCenter(), ply.CHUNK_OFFSET)
	end

	GRule.CPoints[idx] = pos

	GRule.CanPing = true
end

function Mode.CPanelCustom(panel)

	panel:SetName("#tool.gruletool.space.subpanel.title")
	panel:Help("#tool.gruletool.space.subpanel.desc")

	local ply = LocalPlayer()
	local PointButton1 = vgui.Create("DButton", panel)
	PointButton1:SetText("#tool.gruletool.space.subpanel.button.1")
	function PointButton1:DoClick()
		updatePoint(1, ply)
	end
	panel:AddItem(PointButton1)

	local PointButton2 = vgui.Create("DButton", panel)
	PointButton2:SetText("#tool.gruletool.space.subpanel.button.2")
	function PointButton2:DoClick()
		updatePoint(2, ply)
	end
	panel:AddItem(PointButton2)

	local PlyButton1 = vgui.Create("DButton", panel)
	PlyButton1:SetText("#tool.gruletool.space.subpanel.button.follow.1")
	function PlyButton1:DoClick()
		GRule.CPoints[1] = nil
	end
	panel:AddItem(PlyButton1)

	local PlyButton2 = vgui.Create("DButton", panel)
	PlyButton2:SetText("#tool.gruletool.space.subpanel.button.follow.2")
	function PlyButton2:DoClick()
		GRule.CPoints[2] = nil
	end
	panel:AddItem(PlyButton2)

	local Spacer = vgui.Create("DLabel", panel)
	Spacer:SetSize( ScrW(), 20 ) -- CONCERN: no clue how to get controlpanel Height. Using the manual way.
	Spacer:SetText("")
	function Spacer:Paint(w, h)
		draw.RoundedBox( 5, 0, h / 2, w, 2, Color(150,150,150) )
		--draw.RoundedBox( 5, 0, 0, w, h / 2, Color(0,0,0) )
	end
	panel:AddItem(Spacer)

	local ClearButton = vgui.Create("DButton", panel)
	ClearButton:SetText("#tool.gruletool.space.subpanel.button.clear")
	ClearButton:SetIcon("icon16/cancel.png")
	function ClearButton:DoClick()
		GRule.CPoints = {}
		GRule.CPoints[2] = nil
	end
	panel:AddItem(ClearButton)

end

local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

hook.Remove("PostDrawTranslucentRenderables", "GRule_SpaceRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_SpaceRendering", function()
	if GetClientInfo("mode") ~= Mode.id then return end
	if not GRule.CPoints[1] and not GRule.CPoints[2] then return end

	-- Between 2 Points
	do
		local ply = LocalPlayer()
		local Point1 = GRule.CPoints[1] or ply:WorldSpaceCenter()
		local Point2 = GRule.CPoints[2] or ply:WorldSpaceCenter()

		if InfMap then
			if Point1 and GRule.CPoints[1] then
				local IPoint1, offset1 = InfMap.localize_vector(Point1)
				Point1 = InfMap.unlocalize_vector(IPoint1, offset1 - ply.CHUNK_OFFSET)
			end
			if Point2 and GRule.CPoints[2] then
				local IPoint2, offset2 = InfMap.localize_vector(Point2)
				Point2 = InfMap.unlocalize_vector(IPoint2, offset2 - ply.CHUNK_OFFSET)
			end
		end

		if Point1 then
			GRule.RenderCross(1, Point1, Color(0,56,111))
		end

		if Point2 then
			GRule.RenderCross(2, Point2, Color(166,97,0))
		end

		if Point1 and Point2 then
			GRule.CreateBasicRuleRect(Point1, Point2)
		end
	end
end)

GRule.ToolModes[Mode.id] = Mode