AddCSLuaFile()

local Mode = {}

Mode.id = "hitplane"
Mode.name = "HitPlane - between 2 walls"
Mode.desc = "The measure is performed between the position where you did hit, and a perpendicular generated position behind of it, where did hit."
Mode.operation = 1

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

	local backtrace = util.TraceLine({
		start = HitPos,
		endpos = HitPos + trace.HitNormal * 1000000,
		filter = function(ent) if ent:GetClass() ~= "player" then return true end return false end
	})

	SendPosition(1, HitPos, tool)
	SendPosition(2, backtrace.HitPos, tool)

end

function Mode.RightClick(tool, trace)
end

function Mode.Reload(tool, trace)
	GRule.CPoints = {}
end

local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

hook.Remove("PostDrawTranslucentRenderables", "GRule_HitPlaneRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_HitPlaneRendering", function()
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
			GRule.RenderCross("HitPlane", Point1, Color(0,167,6))
		end

		if Point2 then
			GRule.RenderCross("End Point!", Point2, Color(255,0,0))
		end

		if Point1 and Point2 then
			GRule.CreateBasicRuleRect(Point1, Point2)
		end
	end
end)

GRule.ToolModes[Mode.id] = Mode