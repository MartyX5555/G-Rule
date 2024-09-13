AddCSLuaFile()

local Mode = {}

Mode.id = "basic"
Mode.name = "Basic"
Mode.desc = "Performs a measure between 2 points."
Mode.operation = 10

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

		render.DrawLine(Pos1, Pos2, color_white, true )
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