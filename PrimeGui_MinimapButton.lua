--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]

--Minimap Button (code ripped from LibDBIcon-1.0)
--====================================================================

local minimapShapes =
{
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {false, false, false, true},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
	["SIDE-LEFT"] = {true, true, false, false},
	["SIDE-RIGHT"] = {false, false, true, true},
	["SIDE-TOP"] = {true, false, true, false},
	["SIDE-BOTTOM"] = {false, true, false, true},
	["TRICORNER-TOPLEFT"] = {false, true, true, true},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

function PrimeGui.MinimapButton_New( name )

	local button = CreateFrame("Button", name, Minimap)
	button:SetFrameStrata("MEDIUM")
	button:SetWidth(31);
	button:SetHeight(31);
	button:SetFrameLevel(8);
	button:RegisterForClicks("anyUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	
	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetWidth(53); overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT")
	
	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetWidth(20); background:SetHeight(20)
	background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	background:SetPoint("TOPLEFT", 7, -5)
	
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetWidth(20); icon:SetHeight(20)
	--icon:SetTexture(object.icon)
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	icon:SetPoint("TOPLEFT", 7, -5)
	button.icon = icon
	
	button:SetScript("OnEnter", 	PrimeGui.MinimapButton_OnEnter)
	button:SetScript("OnLeave", 	PrimeGui.MinimapButton_OnLeave)
	button:SetScript("OnClick", 	PrimeGui.MinimapButton_OnClick)
	button:SetScript("OnDragStart", PrimeGui.MinimapButton_OnDragStart)
	button:SetScript("OnDragStop", 	PrimeGui.MinimapButton_OnDragStop)
	button:SetScript("OnMouseDown", PrimeGui.MinimapButton_OnMouseDown)
	button:SetScript("OnMouseUp", 	PrimeGui.MinimapButton_OnMouseUp)
	
	--Functions
	PrimeGui.Object_New( button );
	button.UpdatePosition = PrimeGui.MinimapButton_UpdatePosition;
	
	--Init
	button:UpdatePosition();
	return button;
end

function PrimeGui.MinimapButton_OnDragStart( button )
	--button:LockHighlight()
	--button.icon:SetTexCoord(0, 1, 0, 1)
	--button.isMoving = true
	--GameTooltip:Hide()
	button:SetScript("OnUpdate", PrimeGui.MinimapButton_OnUpdate)
end

function PrimeGui.MinimapButton_OnDragStop( button )
	--self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	--self:UnlockHighlight()
	--self.isMoving = nil
	button:SetScript("OnUpdate", nil)
end

function PrimeGui.MinimapButton_OnUpdate( button )
	
	local px, py = GetCursorPosition();
	local mx, my = Minimap:GetCenter();
	local ms = Minimap:GetEffectiveScale();
	
	px = px / ms;
	py = py / ms;
	button.minimapPos = math.deg(math.atan2(py - my, px - mx)) % 360;
	
	button:UpdatePosition();
end

function PrimeGui.MinimapButton_UpdatePosition( button )

	local angle = math.rad(button.minimapPos or 225)
	local x, y, q = math.cos(angle), math.sin(angle), 1
	if x < 0 then q = q + 1 end
	if y > 0 then q = q + 2 end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]
	if quadTable[q] then
		x, y = x*80, y*80
	else
		local diagRadius = 103.13708498985 --math.sqrt(2*(80)^2)-10
		x = math.max(-80, math.min(x*diagRadius, 80))
		y = math.max(-80, math.min(y*diagRadius, 80))
	end
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end
