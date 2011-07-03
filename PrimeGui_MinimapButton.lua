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

-- Tooltip code ripped from StatBlockCore by Funkydude
local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end


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
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	icon:SetPoint("TOPLEFT", 7, -5)
	button.icon = icon
	
	button:SetScript("OnClick", 	PrimeGui.MinimapButton_OnClick);
	button:SetScript("OnEnter", 	PrimeGui.MinimapButton_OnEnter);
	button:SetScript("OnLeave", 	PrimeGui.MinimapButton_OnLeave);
	button:SetScript("OnDragStart", PrimeGui.MinimapButton_OnDragStart);
	button:SetScript("OnDragStop", 	PrimeGui.MinimapButton_OnDragStop);
	button:SetScript("OnMouseDown", PrimeGui.MinimapButton_OnMouseDown);
	button:SetScript("OnMouseUp", 	PrimeGui.MinimapButton_OnMouseUp);
	
	--Internal vars
	button.minimapPos = 225;
	
	--Functions
	PrimeGui.Object_New( button );
	button.SetIcon 			= PrimeGui.MinimapButton_SetIcon;
	button.SetPosition 		= PrimeGui.MinimapButton_SetPosition;
	button.GetPosition 		= PrimeGui.MinimapButton_GetPosition;
	button.UpdatePosition	= PrimeGui.MinimapButton_UpdatePosition;
	
	--Init
	button:UpdatePosition();
	return button;
end

function PrimeGui.MinimapButton_SetIcon( button, path )
	button.icon:SetTexture(path);
end

function PrimeGui.MinimapButton_SetPosition( button, pos )
	button.minimapPos = pos;
	button:UpdatePosition();
end

function PrimeGui.MinimapButton_GetPosition( button )
	return button.minimapPos;
end

function PrimeGui.MinimapButton_OnClick( button, mouseButton, down )
	if (button.OnClick) then
		button.OnClick( button, mouseButton, down );
	end
end

function PrimeGui.MinimapButton_OnMouseDown( button )
	button.icon:SetTexCoord(0, 1, 0, 1);
end

function PrimeGui.MinimapButton_OnMouseUp( button )
	button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95);
end

function PrimeGui.MinimapButton_OnEnter( button )
	
	if (button.isMoving) then
		return;
	end
	
	if (button.OnTooltipShow) then
		GameTooltip:SetOwner(button, "ANCHOR_NONE");
		GameTooltip:SetPoint(getAnchors(button));
		button:OnTooltipShow(GameTooltip);
		GameTooltip:Show();
	end
end

function PrimeGui.MinimapButton_OnLeave( button )
	GameTooltip:Hide();
end

function PrimeGui.MinimapButton_OnDragStart( button )

	GameTooltip:Hide();
	button:LockHighlight();
	button.icon:SetTexCoord(0, 1, 0, 1);
	button:SetScript("OnUpdate", PrimeGui.MinimapButton_OnUpdate);
	button.isMoving = true;
end

function PrimeGui.MinimapButton_OnDragStop( button )

	button:UnlockHighlight();
	button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95);
	button:SetScript("OnUpdate", nil);
	button.isMoving = false;
end

function PrimeGui.MinimapButton_OnUpdate( button )
	
	local px, py = GetCursorPosition();
	local mx, my = Minimap:GetCenter();
	local ms = Minimap:GetEffectiveScale();
	
	px = px / ms;
	py = py / ms;
	button.minimapPos = math.deg(math.atan2(py - my, px - mx)) % 360;
	
	button:UpdatePosition();
	
	if (button.OnPositionChanged) then
		button:OnPositionChanged( button.minimapPos );
	end
end

function PrimeGui.MinimapButton_UpdatePosition( button )

	local angle = math.rad(button.minimapPos)
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
