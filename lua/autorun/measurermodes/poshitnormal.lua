AddCSLuaFile()

local Mode = {}

Mode.id = "hitplane2"
Mode.name = "HitPlane - Normalized Rect"
Mode.desc = "The measure is done between point 1 and point 2, in one direction which is perpendicular to the normal of the 1st point."
Mode.operation = 2

local function SendPosition(idx, PointPos, HitNorm, tool)

	local data = {
		Idx = idx,
		Tool = tool,
		PosX = PointPos.x,
		PosY = PointPos.y,
		PosZ = PointPos.z,
		NormX = HitNorm.x,
		NormY = HitNorm.y,
		NormZ = HitNorm.z,
	}

	GRule.NetworkData(Mode.id, data, tool:GetOwner())
end

function Mode.ReceivePosition(data)

	local X = data.PosX
	local Y = data.PosY
	local Z = data.PosZ
	local NX = data.NormX
	local NY = data.NormY
	local NZ = data.NormZ

	local Idx = data.Idx

	GRule.CPoints[Idx] = Vector(X, Y, Z)
	GRule.HitNormals[Idx] = Vector(NX, NY, NZ)
	GRule.CanPing = true
end

function Mode.LeftClick(tool, trace)
	local HitPos = trace.HitPos
	SendPosition(1, HitPos, trace.HitNormal, tool)
end

function Mode.RightClick(tool, trace)
	local HitPos = trace.HitPos
	SendPosition(2, HitPos, trace.HitNormal, tool)
end

function Mode.Reload(tool, trace)
	GRule.CPoints = {}
end

local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

local mat = Material("models/wireframe")

hook.Remove("PostDrawTranslucentRenderables", "GRule_HitPlane2Rendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_HitPlane2Rendering", function()
	if GetClientInfo("mode") ~= Mode.id then return end

	-- Between 2 Points
	do
		local Point1 = GRule.CPoints[1]
		local Point2 = GRule.CPoints[2]
		local Normal1 = GRule.HitNormals[1]

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

		if Point1 and Normal1 then
			local size = Vector(50,50,0)
			render.SetMaterial( mat )
			render.DrawBox( Point1 + Normal1:GetNormalized() * 1, Normal1:Angle() + Angle(90,0,0), -size, size, Color(0,255,0) )

			GRule.RenderCross("HitPlane", Point1, Color(0,167,6))
		end

		if Point1 and Point2 then

			-- Convert the second point to local space relative to the first point
			local localVec = WorldToLocal(Point2, angle_zero, Point1, Normal1:Angle())
			local newLVec = localVec * Vector(1,0,0)

			-- Convert the local vector back to world space
			local NewPos2 = LocalToWorld(newLVec, Angle(), Point1, Normal1:Angle())

			GRule.CreateBasicRuleRect(Point1, NewPos2)
			GRule.RenderCross("End Point!", NewPos2, Color(255,0,0))
		end
	end
end)

GRule.ToolModes[Mode.id] = Mode