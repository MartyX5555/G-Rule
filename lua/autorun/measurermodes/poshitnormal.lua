AddCSLuaFile()

local Mode = {}

Mode.id = "hitplane2"
Mode.name = "HitPlane - Rect"
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

local function RenderCross(Pos, Color)
	local Factor = 20
	local Forward = Vector(Factor,0,0)
	local Right = Vector(0,Factor,0)
	local Up = Vector(0, 0, Factor)

	render.DrawLine( Pos - Forward, Pos + Forward, Color or color_white, true )
	render.DrawLine( Pos - Right, Pos + Right, Color or color_white, true)
	render.DrawLine( Pos - Up, Pos + Up, Color or color_white, true )
end

local function FormatDistaceText( dist )
	local UnitTable   = GRule.UnitConversion
	local CUnit       = GetClientInfo("unit")
	local UnitData    = next(UnitTable) and UnitTable[CUnit] or UnitTable["unit"]
	local toUnit      = UnitData.convformula
	local Fdist 	  = GetClientValue("rounded") > 0 and math.Round(toUnit(dist)) or toUnit(dist)
	local UnitName    = GetClientValue("longname") > 0 and UnitData.lname or UnitData.sname

	local txt = Fdist .. " " .. UnitName
	return txt
end

-- Create a simple rect between 2 points.
local function CreateBasicRuleRect(Pos1, Pos2)

		local factor = (GetClientValue("mapscale") > 0 and GetClientInfo("unit") ~= "unit") and 0.75 or 1
		local dist = (Pos2 - Pos1):Length() * factor
		local avgPos = (Pos1 + Pos2) / 2
		local Dist2D = avgPos:ToScreen()

		cam.Start2D()
			if Dist2D.visible then
				draw.SimpleTextOutlined(FormatDistaceText( dist ), "HudDefault", Dist2D.x, Dist2D.y + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,Color(0,0,0, 255) )
			end
		cam.End2D()

		render.DrawLine(Pos1, Pos2, color_white )
		RenderCross(Pos1, Color(0,167,6))
		RenderCross(Pos2, Color(255,0,0))
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

		if Point1 and Normal1 then
			local size = Vector(50,50,0)
			render.SetMaterial( mat )
			render.DrawBox( Point1 + Normal1:GetNormalized() * 1, Normal1:Angle() + Angle(90,0,0), -size, size, Color(0,255,0) )
		end

		if Point1 and Point2 and Normal1 then
			-- Convert the second point to local space relative to the first point
			local localVec = WorldToLocal(Point2, Angle(), Point1, Normal1:Angle())
			local newLVec = localVec * Vector(1,0,0)

			-- Convert the local vector back to world space
			local NewPos2 = LocalToWorld(newLVec, Angle(), Point1, Normal1:Angle())

			CreateBasicRuleRect(Point1, NewPos2)
		end
	end
end)


GRule.ToolModes[Mode.id] = Mode