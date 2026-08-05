AddCSLuaFile()

local GRule = GRule
local Mode = {}

Mode.id = "enttoent"
Mode.name = "#tool.gruletool.enttoent.name"
Mode.desc = "#tool.gruletool.enttoent.desc"
Mode.operation = 0
Mode.position = 1

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

	if GRule.CPoints[Idx] and GRule.CPoints[Idx] ~= Entity then
		GRule.DeHighlightEntity(GRule.CPoints[Idx])
	end
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
	GRule.DeHighlightEntity(GRule.CPoints[1])
	GRule.DeHighlightEntity(GRule.CPoints[2])
	GRule.CPoints = {}
	GRule.CHighlightEnts = {}
end

-- The PostDraw. All of the 3d overlays are done here.
function Mode.Show3DOverlays()

	-- Between 2 Points
	do
		local Ent1 = GRule.CPoints[1]
		local Ent2 = GRule.CPoints[2]

		if IsValid(Ent1) then
			GRule.HighlightEntity(Ent1, Color(0,83,167))
		end

		if IsValid(Ent2) then
			GRule.HighlightEntity(Ent2, Color(255,150,0,255))
		end

		if IsValid(Ent1) and IsValid(Ent2) then
			local Point1 = Ent1:WorldSpaceCenter()
			local Point2 = Ent2:WorldSpaceCenter()

			if Point1 then
				GRule.RenderCross(1, Point1, Color(0,83,167))
			end

			if Point2 then
				GRule.RenderCross(2, Point2, Color(255,150,0,255))
			end

			if Point1 and Point2 then
				GRule.CreateBasicRuleRect(Point1, Point2)
			end
		end
	end
end

GRule.ToolModes[Mode.id] = Mode