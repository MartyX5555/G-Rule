AddCSLuaFile()

local Mode = {}

Mode.id = "basic"
Mode.name = "#tool.gruletool.basic.name"
Mode.desc = "#tool.gruletool.basic.desc"
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

function Mode.LeftClick(tool, trace)
	local HitPos = trace.HitPos
	local Entity = trace.Entity

	-- We will send the local vector instead.
	if IsValid(Entity) and tool:GetClientNumber("posparent") > 0 then
		HitPos = Entity:WorldToLocal(HitPos)
	else
		Entity = nil
	end

	SendPosition(1, HitPos, Entity, tool)
end

function Mode.RightClick(tool, trace)
	local HitPos = trace.HitPos
	local Entity = trace.Entity

	-- We will send the local vector instead.
	if IsValid(Entity) and tool:GetClientNumber("posparent") > 0 then
		HitPos = Entity:WorldToLocal(HitPos)
	else
		Entity = nil
	end

	SendPosition(2, HitPos, Entity, tool)
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

hook.Remove("PostDrawTranslucentRenderables", "GRule_BasicRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_BasicRendering", function()
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

		-- Converts the local position to a worldspace position, if the network provided an entity.
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