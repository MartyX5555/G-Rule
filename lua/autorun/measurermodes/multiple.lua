AddCSLuaFile()

local Mode = {}

Mode.id = "enttoent"
Mode.name = "Entity to Entity"
Mode.desc = "Entities are the points. Measures data are updated on the fly."
Mode.operation = 0

local function SendPosition(idx, Entity, tool)

	local data = {
		Idx = idx,
		Tool = tool,
		EntIdx = Entity:EntIndex(),
	}

	GRule.NetworkData(Mode.id, data, tool:GetOwner())
end

function Mode.ReceivePosition(data)

	local Idx = data.Idx
	local Entity = ents.GetByIndex(data.EntIdx)

	GRule.CPoints[Idx] = Entity
	GRule.CanPing = true
end

function Mode.LeftClick(tool, trace)

	local Ent = trace.Entity
	if IsValid(Ent) then
		SendPosition(1, Ent, tool)
	end
end

function Mode.RightClick(tool, trace)

	local Ent = trace.Entity
	if IsValid(Ent) then
		SendPosition(2, Ent, tool)
	end
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
	RenderCross(Pos1, Color(0,83,167))
	RenderCross(Pos2, Color(255,150,0,255))

	if GRule.CanPing then
		GRule.CanPing = nil
		NotifyChat(formatteddist)
	end
end

hook.Remove("PostDrawTranslucentRenderables", "GRule_MultipleRendering")
hook.Add("PostDrawTranslucentRenderables", "GRule_MultipleRendering", function()
	if GetClientInfo("mode") ~= Mode.id then return end

	-- Between 2 Points
	do
		local Ent1 = GRule.CPoints[1]
		local Ent2 = GRule.CPoints[2]

		if IsValid(Ent1) and IsValid(Ent2) then
			local Point1 = Ent1:WorldSpaceCenter()
			local Point2 = Ent2:WorldSpaceCenter()

			if Point1 and Point2 then
				CreateBasicRuleRect(Point1, Point2)
			end
		end
	end
end)


GRule.ToolModes[Mode.id] = Mode