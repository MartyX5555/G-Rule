AddCSLuaFile()

local Mode = {}

Mode.id = "basicsnap"
Mode.name = "Basic - Snap to prop"
Mode.desc = "Performs a measure between 2 points, using a PA like snap on props."
Mode.operation = 0

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

local function GetNearestSnapPos(HitPos, Ent)

	local LPos = Ent:WorldToLocal(HitPos)
	local Phys = Ent:GetPhysicsObject()
	if IsValid(Phys) then

		local BoxCentre = Ent:OBBCenter()
		local Mins, Maxs = Phys:GetAABB()

		-- List of positions to snap to (prop corners and centers)
		local snapPoints = {
			-- Center of the bounding box
			P0 = BoxCentre,

			-- Corners of the bounding box
			P1 = Mins,  -- Bottom-back-left
			P2 = Maxs,  -- Top-front-right
			P3 = Vector(Mins.x, Mins.y, Maxs.z),  -- Top-back-left
			P4 = Vector(Mins.x, Maxs.y, Mins.z),  -- Bottom-front-left
			P5 = Vector(Maxs.x, Mins.y, Maxs.z),  -- Top-back-right
			P6 = Vector(Maxs.x, Mins.y, Mins.z),  -- Bottom-back-right
			P7 = Vector(Maxs.x, Maxs.y, Mins.z),  -- Bottom-front-right
			P8 = Vector(Mins.x, Maxs.y, Maxs.z),  -- Top-front-left

			-- Centers of faces
			P9 = Vector(BoxCentre.x, BoxCentre.y, Maxs.z),  -- Center of top face
			P10 = Vector(BoxCentre.x, Maxs.y, BoxCentre.z),  -- Center of front face
			P11 = Vector(Maxs.x, BoxCentre.y, BoxCentre.z),  -- Center of right face

			P12 = Vector(BoxCentre.x, BoxCentre.y, Mins.z),  -- Center of bottom face
			P13 = Vector(BoxCentre.x, Mins.y, BoxCentre.z),  -- Center of back face
			P14 = Vector(Mins.x, BoxCentre.y, BoxCentre.z),  -- Center of left face

			-- Additional edge centers
			P15 = Vector(Mins.x, Mins.y, BoxCentre.z),  -- Center of back-bottom-left edge
			P16 = Vector(Mins.x, Maxs.y, BoxCentre.z),  -- Center of front-bottom-left edge
			P17 = Vector(Maxs.x, Mins.y, BoxCentre.z),  -- Center of back-bottom-right edge
			P18 = Vector(Maxs.x, Maxs.y, BoxCentre.z),  -- Center of front-bottom-right edge

			-- Bottom edge centers
			P19 = Vector(Mins.x, BoxCentre.y, Mins.z),  -- Center of left-bottom edge
			P20 = Vector(Maxs.x, BoxCentre.y, Mins.z),  -- Center of right-bottom edge
			P21 = Vector(BoxCentre.x, Mins.y, Mins.z),  -- Center of back-bottom edge
			P22 = Vector(BoxCentre.x, Maxs.y, Mins.z),  -- Center of front-bottom edge

			-- Top edge centers
			P23 = Vector(Mins.x, BoxCentre.y, Maxs.z),  -- Center of left-top edge
			P24 = Vector(Maxs.x, BoxCentre.y, Maxs.z),  -- Center of right-top edge
			P25 = Vector(BoxCentre.x, Mins.y, Maxs.z),  -- Center of back-top edge
			P26 = Vector(BoxCentre.x, Maxs.y, Maxs.z)   -- Center of front-top edge
		}
		local index
		local lowest = math.huge
		for k, Point in pairs(snapPoints) do

			--debugoverlay.Cross(Ent:LocalToWorld(Point), 10, 5, Color(0,255,0), true)

			local sqrtdist = (LPos - Point):LengthSqr()
			if sqrtdist < lowest then
				lowest = sqrtdist
				index = k
			end
		end

		return Ent:LocalToWorld(snapPoints[index])
	end
end


function Mode.LeftClick(tool, trace)
	local HitPos = trace.HitPos
	local Ent = trace.Entity

	if IsValid(Ent) then
		local Pos = GetNearestSnapPos(HitPos, Ent)
		HitPos = Pos
	end

	SendPosition(1, HitPos, tool)
end

function Mode.RightClick(tool, trace)
	local HitPos = trace.HitPos
	local Ent = trace.Entity

	if IsValid(Ent) then
		local Pos = GetNearestSnapPos(HitPos, Ent)
		HitPos = Pos
	end

	SendPosition(2, HitPos, tool)
end

function Mode.Reload(tool, trace)
	GRule.CPoints = {}
end

function Mode.CPanelConfig(panel)

end

local function GetClientValue(convar)
	local c = "measurertool_" .. convar
	return GetConVar(c):GetInt()
end

local function GetClientInfo(convar)
	local c = "measurertool_" .. convar
	return GetConVar(c):GetString()
end

local Black = Color(0,0,0, 255)
local function RenderCross(Idx, Pos, C)
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

local function NotifyChat(txt)
	chat.AddText(Color(255,255,0), "[-GRule-] ", color_white, "Distance: " .. txt)
end

-- Create a simple rect between 2 points.
local function CreateBasicRuleRect(Pos1, Pos2)

	local factor = (GetClientValue("mapscale") > 0 and GetClientInfo("unit") ~= "unit") and 0.75 or 1
	local dist = (Pos2 - Pos1):Length() * factor
	local avgPos = (Pos1 + Pos2) / 2
	local Dist2D = avgPos:ToScreen()
	local formatteddist = GRule.FormatDistanceText( dist )

	cam.Start2D()
		if Dist2D.visible then
			draw.SimpleTextOutlined(formatteddist, "HudDefault", Dist2D.x, Dist2D.y + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,Color(0,0,0, 255) )
		end
	cam.End2D()

	render.DrawLine(Pos1, Pos2, color_white, true )

	if GRule.CanPing then
		GRule.CanPing = nil
		NotifyChat(formatteddist)
	end
end

hook.Remove("PostDrawTranslucentRenderables", "GRule_BasicSnapRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_BasicSnapRendering", function()
	if GetClientInfo("mode") ~= Mode.id then return end

	-- Between 2 Points
	do
		local Point1 = GRule.CPoints[1]
		local Point2 = GRule.CPoints[2]

		if InfMap then
			local ply = LocalPlayer()
			if Point1 then
				local IPoint1, offset1 = InfMap.localize_vector(Point1)
				Point1 = InfMap.unlocalize_vector(IPoint1, offset1 - ply.CHUNK_OFFSET)
			end

			if Point2 then
				local IPoint2, offset2 = InfMap.localize_vector(Point2)
				Point2 = InfMap.unlocalize_vector(IPoint2, offset2 - ply.CHUNK_OFFSET)
			end
		end

		if Point1 then
			RenderCross(1, Point1, Color(0,56,111))
		end

		if Point2 then
			RenderCross(2, Point2, Color(166,97,0))
		end

		if Point1 and Point2 then
			CreateBasicRuleRect(Point1, Point2)
		end
	end
end)


GRule.ToolModes[Mode.id] = Mode