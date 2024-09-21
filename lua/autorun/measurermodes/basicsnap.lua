AddCSLuaFile()

local Mode = {}

Mode.id = "basicsnap"
Mode.name = "Basic - Snap to prop"
Mode.desc = "Performs a measure between 2 points, using a PA like snap on props."
Mode.operation = 0
Mode.hasparentpoints = true

local function SendPosition(idx, PointPos, Entity, tool)

	local data = {
		Idx = idx,
		Tool = tool,
		PosX = PointPos.x,
		PosY = PointPos.y,
		PosZ = PointPos.z,
	}
	if IsValid(Entity) then
		data.EntIdx = Entity:EntIndex()
	end

	GRule.NetworkData(Mode.id, data, tool:GetOwner())
end

function Mode.ReceivePosition(data)

	local X = data.PosX
	local Y = data.PosY
	local Z = data.PosZ
	local Idx = data.Idx
	local Entity = ents.GetByIndex(data.EntIdx or 0)
	local valident = IsValid(Entity) and true or false

	GRule.CPoints[Idx] = { pos = Vector(X, Y, Z), ent = Entity, isvalid = valident } -- to make a difference between the normal point and the point that had a local entity.
	GRule.CanPing = true
end

-- for the god sake, please, keep away all this mess of your eyes.... its painful : /
local function GetNearestSnapPos(HitPos, Ent)

	local LPos = Ent:WorldToLocal(HitPos)
	local Phys = Ent:GetPhysicsObject()
	if IsValid(Phys) then

		local BoxCentre = Ent:OBBCenter()
		local Mins, Maxs = Phys:GetAABB()

		-- Prop is potentially makespherical. Return the center only.
		if not (Mins and Maxs) then
			return Ent:LocalToWorld(BoxCentre)
		end

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

		if tool:GetClientNumber("posparent") > 0 then
			Pos = Ent:WorldToLocal(Pos) --
		else
			Ent = nil
		end
		HitPos = Pos
	end

	SendPosition(1, HitPos, Ent, tool)
end

function Mode.RightClick(tool, trace)
	local HitPos = trace.HitPos
	local Ent = trace.Entity

	if IsValid(Ent) then
		local Pos = GetNearestSnapPos(HitPos, Ent)

		if tool:GetClientNumber("posparent") > 0 then
			Pos = Ent:WorldToLocal(Pos) --
		else
			Ent = nil
		end
		HitPos = Pos
	end

	SendPosition(2, HitPos, Ent, tool)
end

function Mode.Reload(tool, trace)
	GRule.CPoints = {}
end

local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

local function VerifyData(Point)
	if not Point then return {} end
	if not IsValid(Point.ent) and Point.isvalid then
		Point = {}
	end
	return Point
end

hook.Remove("PostDrawTranslucentRenderables", "GRule_BasicSnapRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_BasicSnapRendering", function()
	if GetClientInfo("mode") ~= Mode.id then return end

	local CPoints = GRule.CPoints

	-- Between 2 Points
	do

		local Point1 = VerifyData(CPoints[1])
		local Point2 = VerifyData(CPoints[2])

		local Pos1 = Point1.pos
		local Pos2 = Point2.pos

		-- InfMap already does the duty inside of the localtoworld functions below.
		if InfMap then
			local ply = LocalPlayer()
			if Pos1 and not Point1.isvalid then
				local IPoint1, offset1 = InfMap.localize_vector(Pos1)
				Pos1 = InfMap.unlocalize_vector(IPoint1, offset1 - ply.CHUNK_OFFSET)
			end

			if Pos2 and not Point2.isvalid then
				local IPoint2, offset2 = InfMap.localize_vector(Pos2)
				Pos2 = InfMap.unlocalize_vector(IPoint2, offset2 - ply.CHUNK_OFFSET)
			end
		end


		if Point1.isvalid then
			local Ent1 = Point1.ent
			Pos1 = Ent1:LocalToWorld(Pos1)
		end

		if Point2.isvalid then
			local Ent2 = Point2.ent
			Pos2 = Ent2:LocalToWorld(Pos2)
		end

		if Pos1 then
			GRule.RenderCross(1, Pos1, Color(0,100,255))
		end

		if Pos2 then
			GRule.RenderCross(2, Pos2, Color(255,100,0))
		end

		if Pos1 and Pos2 then
			GRule.CreateBasicRuleRect(Pos1, Pos2)
		end
	end
end)

GRule.ToolModes[Mode.id] = Mode