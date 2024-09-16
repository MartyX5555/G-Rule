AddCSLuaFile()

local Mode = {}

Mode.id = "basic"
Mode.name = "Basic"
Mode.desc = "Performs a measure between 2 points. Becomes very useful if paired with smartsnap"
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

function Mode.LeftClick(tool, trace)
	local HitPos = trace.HitPos
	SendPosition(1, HitPos, tool)
end

function Mode.RightClick(tool, trace)
	local HitPos = trace.HitPos
	SendPosition(2, HitPos, tool)
end

function Mode.Reload(tool, trace)
	GRule.CPoints = {}
end

local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

hook.Remove("PostDrawTranslucentRenderables", "GRule_BasicRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_BasicRendering", function()
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