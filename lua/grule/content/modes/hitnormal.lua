AddCSLuaFile()

local GRule = GRule
local Mode = {}

Mode.id = "hitplane"
Mode.name = "#tool.gruletool.hitplane.name"
Mode.desc = "#tool.gruletool.hitplane.desc"
Mode.operation = 1
Mode.position = 2

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
	local OriginalHitPos = trace.HitPos
	local HitPos = GRule.GetPreciseHitPos(trace)

	local backtrace = util.TraceLine({
		start = OriginalHitPos,
		endpos = HitPos + trace.HitNormal * 1000000,
		filter = function(ent) if ent:GetClass() ~= "player" then return true end return false end
	})

	SendPosition(1, HitPos, tool)
	SendPosition(2, GRule.GetPreciseHitPos(backtrace), tool)

end

function Mode.RightClick(tool, trace)
end

function Mode.Reload(tool, trace)
	GRule.CPoints = {}
end

-- The PostDraw. All of the 3d overlays are done here.
function Mode.Show3DOverlays()

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
			GRule.RenderCross("#tool.gruletool.overlay.hitplane", Point1, Color(0,167,6))
		end

		if Point2 then
			GRule.RenderCross("#tool.gruletool.overlay.endpoint", Point2, Color(255,0,0))
		end

		if Point1 and Point2 then
			GRule.CreateBasicRuleRect(Point1, Point2)
		end
	end
end

GRule.ToolModes[Mode.id] = Mode