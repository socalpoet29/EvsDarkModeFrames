-- Author: Evan, Ketho (EU-Boulderfist)
-- License: Public Domain

local NAME = ...

local defaults = {

	debugMessage = false,
	hpIrTex = 'Interface\\AddOns\\EvsDarkModeFrames\\Media\\lightgrad.tga',
	damIrTex = 'Interface\\AddOns\\EvsDarkModeFrames\\Media\\darkgrad.tga',
	hpIrVer = 0.07,
	hpOorTex = 'Interface\\AddOns\\EvsDarkModeFrames\\Media\\darkgradup.tga',
	damOorTex = 'Interface\\AddOns\\EvsDarkModeFrames\\Media\\stripes.tga',
	hpOorVer = 0.47,
	damOorVer = 0.31,
	hpAnchor = "TOPLEFT",
	damAnchor = "RIGHT",
	frameAlpha = 1,  -- frame range fading override
	highAlpha = 1,  -- hp frame default
	medAlpha = 0.5,  -- dam frame default
	lowAlpha = 0.4, -- dam oor
	minAlpha = 0.1,  -- dam dead/offline

}

-- Which frames to include (i.e. ignore nameplates)
local group = {

	part = true, -- party
	raid = true,
	play = true, -- player

}

local f = CreateFrame("Frame")

function f:OnEvent(event, addon)

	if addon ~= NAME then return end
	
	-- Remaining Health frames
	local hp = {}

	-- Lost Health (Damage) frames
	local dam = {}

	-- Frame is loaded
	local i = {}

	local debugEventCount = 0

	-- Initialize frames, or refresh when change is detected
	hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", function(frame)
		
		local du = frame.displayedUnit

		-- Prevent nil errors
		if (du == nil) then return end

		if (UnitGUID(du) == nil) then return end

		-- Ignore nameplates
		if not checkgroup(du) then return end

		-- If the frame already exists, hide the old one and set to false
		if (hp[du] ~= nil) then 

			hp[du]:Hide()

			dam[du]:Hide()

			i[du] = false

			-- Since there is no true init function that I'm aware of, log how many times this runs is fired to track performance
			if defaults.debugMessage then

				debugEventCount = debugEventCount + 1

				print("Dark mode frames updated count is ", debugEventCount)

			end

		end

		-- Create the texture if it doesn't exist or we hid the old one
		if (i[du] ~= true) then

			-- Debug logging
			if defaults.debugMessage then

				print("generating dark mode for " .. du .. ",", UnitGUID(du))

			end

			-- Start Health Bar --

			hp[du] = frame:CreateTexture()

			hp[du]:SetTexture(defaults.hpIrTex)

			hp[du]:ClearAllPoints()

			hp[du]:SetPoint(defaults.hpAnchor, hp[du]:GetParent())

			hp[du]:SetHeight(hp[du]:GetParent():GetHeight())

			hp[du]:SetWidth(currenthp(hp, du))

			-- Default color

			hp[du]:SetVertexColor(defaults.hpIrVer, defaults.hpIrVer, defaults.hpIrVer, defaults.highAlpha)

			-- End Health Bar --

			-- Start Damage Bar --

			dam[du] = frame:CreateTexture()

			dam[du]:SetTexture(defaults.damIrTex)

			dam[du]:ClearAllPoints()

			dam[du]:SetPoint(defaults.damAnchor, dam[du]:GetParent())

			dam[du]:SetHeight(dam[du]:GetParent():GetHeight())
			
			dam[du]:SetWidth(currentdam(dam, du))
			
			--Class color
			local r, g, b = classcolor(du)
			
			dam[du]:SetVertexColor(r, g, b, defaults.medAlpha)

			-- End Damage Bar --

			-- Set enabled
			i[frame.displayedUnit] = true

		end

	end)

	-- Update out of range units
	hooksecurefunc("CompactUnitFrame_UpdateInRange", function(frame)

		local du = frame.displayedUnit
		
		if not checkgroup(du) then return end

		if (i[du] == true) then

			-- Check range
			local inRange, checkedRange = UnitInRange(du)

			-- Out of range
			if checkedRange and not inRange then

				-- Update colors
				hp[du]:SetVertexColor(defaults.hpOorVer, defaults.hpOorVer, defaults.hpOorVer, defaults.highAlpha)

				dam[du]:SetVertexColor(defaults.damOorVer, defaults.damOorVer, defaults.damOorVer, defaults.lowAlpha)

				-- Set textures
				hp[du]:SetTexture(defaults.hpOorTex)

				dam[du]:SetTexture(defaults.damOorTex)

				-- Override default behavoir
				frame:SetAlpha(defaults.frameAlpha)

			-- In range / not checked
			else

				-- Update Colors
				hp[du]:SetVertexColor(defaults.hpIrVer, defaults.hpIrVer, defaults.hpIrVer, defaults.highAlpha)
				
				-- Only set color for alive unit
				if (not UnitIsDeadOrGhost(du)) then
				
					-- Class color
					local r, g, b = classcolor(du)
					
					dam[du]:SetVertexColor(r, g, b, defaults.medAlpha)
				
				end
				
				-- Set textures
				hp[du]:SetTexture(defaults.hpIrTex)
				
				dam[du]:SetTexture(defaults.damIrTex)

				-- Override default behavoir
				frame:SetAlpha(defaults.frameAlpha)

			end

		end

	end)

	-- Set the widths of our frames to cover our health, health lost, and space in betwen for incoming heals/absorbs to show thru
	hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", function(frame)

		local du = frame.displayedUnit

		if not checkgroup(du) then return end

		if (i[du] == true) then

			-- Health bar
			hp[du]:SetWidth(currenthp(hp, du))

			-- Damage bar
			dam[du]:ClearAllPoints()

			local damw = currentdam(dam, du)

			dam[du]:SetPoint(defaults.damAnchor, dam[du]:GetParent(), damw, 0)

			dam[du]:SetWidth(damw)

		end

	end)

	-- Hide aggro highlight since it clashes with theme
	hooksecurefunc("CompactUnitFrame_UpdateAggroHighlight", function(frame)

		local du = frame.displayedUnit

		-- Ignore nameplates
		if not checkgroup(du) then return end

		if (i[du] == true) then

			frame.aggroHighlight:Hide()

		end

	end)

	self:UnregisterEvent(event)

end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

-- Returns class color for unit
function classcolor(du)
	
	local className, classFilename, classId = UnitClass(du)
			
	local r, g, b, hex = GetClassColor(classFilename)

	return r, g, b

end

-- Returns current hp bar width relative to frame width
function currenthp(hp, du)

	if (checkdead(du)) then
	
		return 1

	end

	return UnitHealth(du) / UnitHealthMax(du) * hp[du]:GetParent():GetWidth()

end

-- Returns current damage bar width relative to frame width
function currentdam(dam, du)

	local inc = 0

	-- This comes back nil sometimes when someone joins the group
	if ( UnitGetIncomingHeals(du) ~= nil) then

		inc = UnitGetIncomingHeals(du)

	end

	if (checkdead(du)) then
	
		return 1

	end

	return 1 - ( math.max(1, UnitHealthMax(du) - UnitHealth(du) - inc )) / UnitHealthMax(du) * dam[du]:GetParent():GetWidth()

end

-- Checks if frame is in our whitelist of frames to show (i.e. to ignore nameplates)
function checkgroup(du)

	return group[strsub(du, 1, 4)]

end

function checkdead(du) 

	return (not UnitIsConnected(du) or UnitIsDeadOrGhost(du))

end
