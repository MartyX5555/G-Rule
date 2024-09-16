AddCSLuaFile()

local Mode = {}

Mode.id = "enttoent"
Mode.name = "Entity to Entity"
Mode.desc = "Chosen entities are the points. Measures data are updated on the fly."
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

local function GetClientInfo(convar)
	local c = "gruletool_" .. convar
	return GetConVar(c):GetString()
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
end)

GRule.ToolModes[Mode.id] = Mode