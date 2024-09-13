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

function Mode.CPanelConfig(panel)
end

local function GetClientValue(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetInt()
end

local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
end

local function RenderCross(Pos, Color)
	local Factor = 10
	local Forward = Vector(Factor,0,0)
	local Right = Vector(0,Factor,0)
	local Up = Vector(0, 0, Factor)

	render.DrawLine( Pos - Forward, Pos + Forward, Color or color_white, true )
	render.DrawLine( Pos - Right, Pos + Right, Color or color_white, true)
	render.DrawLine( Pos - Up, Pos + Up, Color or color_white, true )
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
	RenderCross(Pos1, Color(0,167,6))
	RenderCross(Pos2, Color(255,0,0))

	if GRule.CanPing then
		GRule.CanPing = nil
		NotifyChat(formatteddist)
	end
end

hook.Remove("PostDrawTranslucentRenderables", "GRule_HitPlaneRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_HitPlaneRendering", function()
	if GetClientInfo("mode") ~= Mode.id then return end

	-- Between 2 Points
	do
		local Point1 = GRule.CPoints[1]
		local Point2 = GRule.CPoints[2]

		if Point1 and Point2 then

			if InfMap then
				local ply = LocalPlayer()
				local IPoint1, offset1 = InfMap.localize_vector(Point1)
				local IPoint2, offset2 = InfMap.localize_vector(Point2)

				Point1 = InfMap.unlocalize_vector(IPoint1, offset1 - ply.CHUNK_OFFSET)
				Point2 = InfMap.unlocalize_vector(IPoint2, offset2 - ply.CHUNK_OFFSET)
			end

			CreateBasicRuleRect(Point1, Point2)
		end
	end
end)


GRule.ToolModes[Mode.id] = Mode