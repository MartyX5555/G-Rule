--[[
	Key Documentation: https://developer.valvesoftware.com/wiki/Dimensions_(Half-Life_2_and_Counter-Strike:_Source)#Source_Engine_Scale_Calculations

	Demostration:

		For Mapscale:

		According to valve, 1 foot is equal to 16 units if we consider the mapscale, and in real life, 1 foot is 12 inches. So we can say:

		1 foot => 16 units
		12 inches => 16 units

		So, if we want to know how many inches is 1 unit, we can just do the following ratio:

		12 inches => 16 units
		x inches => 1 unit

		With this, we will just divide the 12 inches by the units we know.

		x = 12 / 16 = 0.75

		And, as you can see, 0.75 inches is equal to 1 unit MAPSCALE, resulting into a bigger figures from the player's perspective.

		For Playerscale:

		Now, for playerscale, 1 foot is equal to 12 units, 4 units less than mapscale. Taking into consideration that 1 foot is 12 inches, we can say:

		1 foot => 12 units
		12 inches = 12 units

		So, just analyze this ratio, did you see that 1 unit is literally one inch? Yeah, thats it. 1 inch IS 1 unit for playerscale.

]]

local GRule = GRule

GRule.ToolModes = GRule.ToolModes or {}
GRule.CPoints = GRule.CPoints or {}
GRule.CHighlightEnts = GRule.CHighlightEnts or {}
GRule.HitNormals = GRule.HitNormals or {}
GRule.Timers = GRule.Timers or {}
GRule.UnitConversion = GRule.UnitConversion or {}

do
	local function IsReallyValidTable(tbl)
		if not istable(tbl) then return false end
		if not next(tbl) then return false end

		return true
	end

	function GRule.GetModeInfo(mode)
		local ToolModes = GRule.ToolModes
		if not IsReallyValidTable(ToolModes[mode]) then
			if CLIENT then
				local localizedtext = language.GetPhrase("#tool.gruletool.error.mode")
				MsgC(Color(255, 0, 0), "\n[-GRule-] - " .. string.format(localizedtext, mode) .. "\n")
			end
			return ToolModes["basic"]
		end

		return ToolModes[mode]
	end

	function GRule.GetUnitInfo(unit)
		local Units = GRule.UnitConversion
		if not IsReallyValidTable(Units[unit]) then
			if CLIENT then
				local localizedtext = language.GetPhrase("#tool.gruletool.error.unit")
				MsgC(Color(255, 0, 0), "\n[-GRule-] - " .. string.format(localizedtext, unit) .. "\n")
			end
			return Units["unit"]
		end
		return Units[unit]
	end

	--[[
		Traces add a few units (0.03125 to be exact) on top of the hit position, causing small but not negligible errors, especially when we are measuring small distances.
		To mitigate this issue, we will do a small ray-plane intersection to get the precise hit position on the surface, this way we can get rid of the trace's precision issues and get a more accurate measurement.
	]]
	function GRule.GetPreciseHitPos(trace)
		local HitPos = trace.HitPos
		local HitNormal = trace.HitNormal

		local ToSurface = HitNormal * 0.03125
		local StartSurface = HitPos - ToSurface

		-- The plane will represent the surface of the hit, and we will intersect it with a ray that starts from the hitpos and goes in the direction of the normal, this way we can get a more precise hitpos that is not affected by the trace's precision issues.
		HitPos = util.IntersectRayWithPlane( HitPos, -HitNormal * 10, StartSurface, HitNormal ) or HitPos -- if the intersection fails for some reason, we will just return the original hitpos, but it should not happen.
		return HitPos
	end

end


if SERVER then

	local function Encode(data)
		local json = util.TableToJSON(data)
		local binary = util.Compress(json)
		return binary
	end

	function GRule.NetworkData(dest, data, ply)

		data.dest = dest
		local binary = Encode(data)
		local bytes = #binary

		net.Start("GRule_Network")
			net.WriteData(binary, bytes)
		net.Send(ply)
	end
end

if CLIENT then


	do
		local function Decode(bin)
			local json = util.Decompress(bin)
			local data = util.JSONToTable(json)
			return data
		end

		net.Receive("GRule_Network", function(len)
			local binary = net.ReadData(len)
			local data = Decode(binary)
			local modeinfo = GRule.GetModeInfo(data.dest)
			modeinfo.ReceivePosition(data)
		end)
	end

	do

		local function GetClientValue(convar)
			local c = "gruletool_" .. convar
			return GetConVar(c):GetInt()
		end

		local function GetClientInfo(convar)
			local c = "gruletool_" .. convar
			return GetConVar(c):GetString()
		end

		local function NotifyChat(txt)
			chat.AddText(Color( 255, 128, 0), "[-GRule-] ", color_white, language.GetPhrase("#tool.gruletool.distancenotify") .. ": " .. txt)
		end

		local function GetSelectedUnitData()
			return GRule.GetUnitInfo(GetClientInfo("unit"))
		end

		function GRule.FormatDistanceText(dist)
			local UnitData    = GetSelectedUnitData()
			local toUnit      = UnitData.convformula
			local roundCount  = GetClientValue("roundcount") or 0
			local toUnitDist   = toUnit(dist)
			toUnitDist = math.IsNearlyEqual(toUnitDist,math.Round(toUnitDist),1e-4) and math.Round(toUnitDist) or toUnitDist
			local Fdist 	  = math.Round(toUnitDist, roundCount)
			local UnitName    = GetClientValue("longname") > 0 and UnitData.lname or UnitData.sname

			local txt = Fdist .. " " .. language.GetPhrase(UnitName)
			return txt
		end

		local Black = Color(0,0,0, 255)
		function GRule.RenderCross(Idx, Pos, C)
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

		-- Create a simple rect between 2 points.
		function GRule.CreateBasicRuleRect(Pos1, Pos2)

			local UnitData = GetSelectedUnitData()
			local factor = (GetClientValue("mapscale") > 0 and not UnitData.noscale) and 0.75 or 1
			local dir = (Pos2 - Pos1)
			local dist = dir:Length() * factor

			-- Universe like size workaround. May lose a lot of precision due to the mega distances, but better than returning an inf.
			-- The workaround is simply using the chunk value instead of unit, since 1 chunk = 10000 units wide
			-- Bro, seriously, the amount of precision loss is insane, blame lua by doing this!!
			if InfMap and dist >= 10000000000000000000000000000 then -- aproximately 15 parsecs.
				local _, c1 = InfMap.localize_vector(Pos1)
				local _, c2 = InfMap.localize_vector(Pos2)

				local big = 0.0000000000000000000000001
				local newdir = c2 - c1
				local thing = newdir  * big
				local thing2 = thing:Length()
				dir = newdir -- reinforce the break but still breaks anyways.
				dist = (thing2 / big) * InfMap.chunk_size * factor * 2
			end

			local avgPos = (Pos1 + Pos2) / 2
			local Dist2D = avgPos:ToScreen()
			local formatteddist = GRule.FormatDistanceText( dist )

			local angles = dir:GetNormalized():Angle()
			angles:Normalize()
			local formattedang = language.GetPhrase("#tool.gruletool.overlay.angle") .. ": " .. tostring(angles) -- We will just use the default tostring for angles, since it is already formatted nicely.

			cam.Start2D()
				if Dist2D.visible then
					draw.SimpleTextOutlined(formatteddist, "HudDefault", Dist2D.x, Dist2D.y + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,Color(0,0,0, 255) )
					draw.SimpleTextOutlined(formattedang, "HudDefault", Dist2D.x, Dist2D.y + 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,Color(0,0,0, 255) )
				end
			cam.End2D()

			render.DrawLine(Pos1, Pos2, Color(255,100,0), false )
			render.DrawLine(Pos1, Pos2, color_white, true )

			if GRule.CanPing then
				GRule.CanPing = nil
				NotifyChat(formatteddist)
			end

			GRule.FormatedDistance = formatteddist
			GRule.Angles = string.format("%s, %s, %s", math.Round(tonumber(angles.p),3), math.Round(tonumber(angles.y),3), math.Round(tonumber(angles.r),3))
		end

		-- Highlight the entity with a specified color, this is used to highlight the entity that is being measured.
		function GRule.HighlightEntity(ent, color)
			if not GRule.CHighlightEnts[ent] then
				local entdata = {
					realcolor = ent:GetColor(),
					realmaterial = ent:GetMaterial(),
				}
				GRule.CHighlightEnts[ent] = entdata
				ent:CallOnRemove("GRule_DelightOnRemove", function()
					GRule.CHighlightEnts[ent] = nil
				end)
			end
			-- We are client. Once the player leaves the map boundaries, these are reseted, so we need to reapply the highlight to the entity.
			ent:SetColor(color)
			ent:SetMaterial("models/debug/debugwhite")

		end

		function GRule.DeHighlightAllEnts()
			for ent, _ in pairs(GRule.CHighlightEnts) do
				GRule.DeHighlightEntity(ent)
			end
			GRule.CHighlightEnts = {}
		end

		-- DeHighlight an entity that was previously highlighted, this is used to dehighlight the entity that is no longer being measured.
		function GRule.DeHighlightEntity(ent)
			--TrimInvalidHighlightEnts()
			if IsValid(ent) then
				ent:SetColor(GRule.CHighlightEnts[ent].realcolor)
				ent:SetMaterial(GRule.CHighlightEnts[ent].realmaterial)
				ent:RemoveCallOnRemove("GRule_DelightOnRemove")
				GRule.CHighlightEnts[ent] = nil
			end
		end

		-- UI related stuff.
		function GRule.CreateUISpacer(panel)
			local Spacer = vgui.Create("DLabel", panel)
			Spacer:SetSize( ScrW(), 20 ) -- CONCERN: no clue how to get controlpanel Height. Using the manual way.
			Spacer:SetText("")
			function Spacer:Paint(w, h)
				draw.RoundedBox( 5, 0, h / 2, w, 2, Color(150,150,150) )
			end
			panel:AddItem(Spacer)
		end
	end
end