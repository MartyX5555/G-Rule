AddCSLuaFile()

local Mode = {}

Mode.id = "space"
Mode.name = "Space Mode"
Mode.desc = "Gets the measure either from an arbitrary position or vector origin to the player. Useful for space measurement tasks.\n\nSince traces stop working beyond a point, its recommended to setup the origin BEFORE departing at millions kilometers away."
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

local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

hook.Remove("PostDrawTranslucentRenderables", "GRule_SpaceRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_SpaceRendering", function()
	if GetClientInfo("mode") ~= Mode.id then return end

	-- Between 2 Points
	do
		local ply = LocalPlayer()

		local Point1 = GRule.CPoints[1]
		local Point2 = ply:WorldSpaceCenter()

		if InfMap and Point1 then
			local IPoint1, offset1 = InfMap.localize_vector(Point1)
			Point1 = InfMap.unlocalize_vector(IPoint1, offset1 - ply.CHUNK_OFFSET)
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