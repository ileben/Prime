--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]

--Global list of dropdowns
--(used to close other dropdowns when one is open)
--=====================================================================

local AllDropdowns = {};

function PrimeGui.RegisterDropdown( frame )

	table.insert( AllDropdowns, frame );
end

function PrimeGui.UnregisterDropdown( frame )

	for i,drop in ipairs(AllDropdowns) do
		if (drop == frame) then
			table.remove( AllDropdowns, i );
			break;
		end
	end
end

function PrimeGui.CloseAllDropdowns()

	for i,frame in pairs(AllDropdowns) do
		frame.box:Hide();
	end
end

--Dropdown box that allows custom item frames
--=====================================================================

function PrimeGui.Drop_New( name )

	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetScript( "OnHide", PrimeGui.Drop_OnHide );
	f:SetHeight( 40 );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 10 );
	l:SetJustifyH( "LEFT" );
	l:SetPoint( "TOPLEFT", 0,0 );
	l:SetPoint( "TOPRIGHT", 0,0 );
	l:SetHeight( 8 );
	f.label = l;
	
	--Dropdown
	local d = CreateFrame( "Frame", name.."Drop", f, "UIDropDownMenuTemplate" );
	d:SetPoint( "TOPLEFT", l, "BOTTOMLEFT", -20,-4 );
	d:SetPoint( "TOPRIGHT", l, "BOTTOMRIGHT", 0,-4 );
	d:SetScript( "OnHide", PrimeGui.Drop_Drop_OnHide );
	d.frame = f;
	f.drop = d;
	
	local btn = _G[d:GetName() .. "Button"];
	btn:SetScript( "OnClick", PrimeGui.Drop_Button_OnClick );
	btn.frame = f;
	
	local text = _G[d:GetName() .. "Text"];
	text.frame = frame;
	f.text = text;
	
	--Box
	local box = CreateFrame( "Frame", name.."Box", UIParent );
	
	box:SetBackdrop(
	  {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	   edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
	   tile = true, tileSize = 32, edgeSize = 32,
	   insets = { left = 11, right = 12, top = 12, bottom = 11 }});
	   
	box:SetBackdropColor(0,0,0,1);
	
	box:SetFrameStrata( "FULLSCREEN_DIALOG" );
	box:SetToplevel(true);
	--box:SetClampedToScreen( true );
	box:EnableMouse(true);
	box:SetWidth( 200 );
	box:SetHeight( 400 );
	box:SetPoint( "TOPRIGHT", f, "BOTTOMRIGHT", 0, 2 );
	box:EnableMouseWheel(true)
	box:SetScript("OnMouseWheel", PrimeGui.Drop_Box_OnMouseWheel)
	box:Hide();
	box.frame = f;
	f.box = box;
	
	--Box scroll frame
	local s = CreateFrame( "Slider", name.."Scroll", box, "MinimalScrollBarTemplate" );
	s:SetPoint( "TOPRIGHT", box, "TOPRIGHT", -10, -30 );
	s:SetPoint( "BOTTOMRIGHT", box, "BOTTOMRIGHT", -10, 30 );
	s:SetScript( "OnMinMaxChanged", PrimeGui.Drop_Scroll_OnMinMaxChanged );
	s:SetScript( "OnValueChanged", PrimeGui.Drop_Scroll_OnValueChanged );
	
	s.btnUp = _G[s:GetName().."ScrollUpButton"];
	s.btnUp:SetScript( "OnClick", PrimeGui.Drop_Scroll_Up_OnClick );
	s.btnUp.scroll = s;
	
	s.btnDown = _G[s:GetName().."ScrollDownButton"];
	s.btnDown:SetScript( "OnClick", PrimeGui.Drop_Scroll_Down_OnClick );
	s.btnDown.scroll = s;
	
	s.frame = f;
	f.scroll = s;
	
	--Internal vars
	f.data = {};
	f.numData = 0;
	f.selection = 0;
	
	f.scrollValue = 0;
	f.itemHeight = 0;
	f.maxVisibleItems = 15;
	
	--Functions
	PrimeGui.Object_New( f );
	
	f.Init             = PrimeGui.Drop_Init;
	f.Free             = PrimeGui.Drop_Free;
	f.AddItem          = PrimeGui.Drop_AddItem;
	f.RemoveAllItems   = PrimeGui.Drop_RemoveAllItems;
	f.SelectIndex      = PrimeGui.Drop_SelectIndex;
	f.SelectValue      = PrimeGui.Drop_SelectValue;
	f.GetSelectedIndex = PrimeGui.Drop_GetSelectedIndex;
	f.GetSelectedText  = PrimeGui.Drop_GetSelectedText;
	f.GetSelectedValue = PrimeGui.Drop_GetSelectedValue;
	f.SetLabelText     = PrimeGui.Drop_SetLabelText;
	
	--Internal Functions
	f.CreateItem       = PrimeGui.Drop_CreateItem;
	f.UpdateItem       = PrimeGui.Drop_UpdateItem;
	f.UpdateAllItems   = PrimeGui.Drop_UpdateAllItems;
	f.UpdateSelection  = PrimeGui.Drop_UpdateSelection;
	
	f:RegisterScript( "OnSizeChanged", PrimeGui.Drop_OnSizeChanged );
	
	--Init
	
	UIDropDownMenu_SetWidth( f.drop, 100 );
	UIDropDownMenu_SetButtonWidth( f.drop, 20 );
	
	return f;
end

function PrimeGui.Drop_Init( frame )
	
	PrimeGui.Object_Init( frame );
	
	--Create frames for visible items first time
	if (frame.items == nil) then
		frame.items = {};
		
		local prevItem = nil;
		for i=1,frame.maxVisibleItems do
		
			--Create item frame and add to list of items
			local item = frame:CreateItem();
			table.insert( frame.items, item );
			item.frame = frame;
			frame.itemHeight = item:GetHeight();
			
			--Attach to previous item or top of the dropdown box
			item:SetParent( frame.box );
			item:ClearAllPoints();
			
			if (prevItem) then
				item:SetPoint( "TOPLEFT", prevItem, "BOTTOMLEFT", 0,0 );
				item:SetPoint( "TOPRIGHT", prevItem, "BOTTOMRIGHT", 0,0 );
			else
				item:SetPoint( "TOPLEFT", frame.box, "TOPLEFT", 30,-15 );
				item:SetPoint( "TOPRIGHT", frame.box, "TOPRIGHT", -20,-15 );
			end
			
			--Create item highlight
			local h = item:CreateTexture(nil, "OVERLAY")
			h:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			h:SetBlendMode("ADD")
			h:SetAllPoints( item );
			h:Hide()
			item.highlight = h;
			
			--Create item check
			local c = item:CreateTexture(nil,"OVERLAY");
			c:SetTexture("Interface\\Buttons\\UI-CheckBox-Check");
			c:SetPoint("RIGHT", item, "LEFT");
			c:SetWidth( 20 );
			c:SetHeight( 20 );
			c:Hide();
			item.check = c;
			
			--Register scripts
			item:SetScript( "OnEnter", PrimeGui.Drop_Item_OnEnter );
			item:SetScript( "OnLeave", PrimeGui.Drop_Item_OnLeave );
			item:SetScript( "OnMouseUp", PrimeGui.Drop_Item_OnClick );
			
			prevItem = item;
		end
	end
	
	--Clear contents
	frame:RemoveAllItems();
	
	--Add to global list of dropdowns
	PrimeGui.RegisterDropdown( frame );
end

function PrimeGui.Drop_UpdateAllItems( frame )
	
	--Size dropdown box to number of visible items
	if (frame.numData > frame.maxVisibleItems)
	then frame.box:SetHeight( frame.maxVisibleItems * frame.itemHeight + 30 );
	else frame.box:SetHeight( frame.numData * frame.itemHeight + 30 );
	end
	
	--Update scroll range
	if (frame.numData > frame.maxVisibleItems) then
		frame.scroll:SetMinMaxValues( 1, frame.numData - frame.maxVisibleItems );
		frame.scroll:SetValueStep( 1 );
		frame.scroll:Show();
	else
		frame.scroll:Hide();
	end
	
	--Make space for scroller if visible
	if (frame.scroll:IsShown())
	then frame.items[1]:SetPoint( "TOPRIGHT", frame.box, "TOPRIGHT", -30, -15 );
	else frame.items[1]:SetPoint( "TOPRIGHT", frame.box, "TOPRIGHT", -20, -15 );
	end
	
	--Update item contents
	local offset = frame.scroll:GetValue();
	for i=1,frame.maxVisibleItems do
	
		local item = frame.items[i];
		if (offset <= frame.numData) then
		
			--Update and show used items
			item.index = offset;
			frame:UpdateItem( item, frame.data[offset].text, frame.data[offset].value );
			item:Show();
			
			--Show check for selected item
			if (offset == frame.selection)
			then item.check:Show();
			else item.check:Hide();
			end
			
		else
		
			--Hide unused items
			item.highlight:Hide();
			item:Hide();
		end
		
		offset = offset + 1;
	end
end

function PrimeGui.Drop_AddItem( frame, text, value )

	--Create new data if missing
	if (frame.numData == table.getn(frame.data)) then
		table.insert( frame.data, { text="", value=nil } );
	end
	
	--Store text and value
	frame.numData = frame.numData + 1;
	frame.data[ frame.numData ].text = text;
	frame.data[ frame.numData ].value = value;
	
	--Select first item
	if (frame.numData == 1) then
		frame:SelectIndex(1);
	end
end

function PrimeGui.Drop_RemoveAllItems( frame )

	--Reset data list
	frame.numData = 0;
	frame.selection = 0;
	
	--Reset scroll position
	frame.scrollValue = 0;
	frame.scroll:SetMinMaxValues(1,1);
	frame.scroll:SetValue(1);
	
end

function PrimeGui.Drop_Free( frame )
	
	--Remove from global list of dropdowns
	PrimeGui.UnregisterDropdown( frame );
	
	--Superclass
	PrimeGui.Object_Free( frame );
end


function PrimeGui.Drop_CreateItem( frame )

	--Frame
	local f = CreateFrame( "Frame", "SomeFrame" );
	f:SetHeight( 20 );
	f:SetWidth( 100 );
	f:SetParent( frame.box );
	
	--Label
	local l = f:CreateFontString( "SomeString", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 10 );
	l:SetTextColor( 1,1,1 );
	l:SetJustifyH( "LEFT" );
	l:SetAllPoints( f );
	f.label = l;
	
	return f;
end

function PrimeGui.Drop_UpdateItem( frame, item, text, value )
	item.label:SetText( text );
end

function PrimeGui.Drop_UpdateSelection( frame, index )
	frame.text:SetText( frame.data[index].text );
end

function PrimeGui.Drop_SetLabelText( frame, text )
	frame.label:SetText( text );
end

function PrimeGui.Drop_SelectIndex( frame, index )
	if (index >= 1 and index <= frame.numData) then
		frame.selection = index;
		frame:UpdateSelection( index );
	end
end

function PrimeGui.Drop_SelectValue( frame, value )
	for i,data in ipairs( frame.data ) do
		if (data.value == value) then
			frame:SelectIndex( i );
			break;
		end
	end
end

function PrimeGui.Drop_GetSelectedIndex( frame )
	return frame.selection;
end

function PrimeGui.Drop_GetSelectedText( frame )
	if (frame.selection > 0)
	then return frame.data[ frame.selection ].text;
	else return nil;
	end
end

function PrimeGui.Drop_GetSelectedValue( frame )
	if (frame.selection > 0)
	then return frame.data[ frame.selection ].value;
	else return nil;
	end
end

function PrimeGui.Drop_OnSizeChanged( frame, width, height )
	UIDropDownMenu_SetWidth( frame.drop, width-15 );
	frame.box:SetWidth( width + 5 );
end

function PrimeGui.Drop_Button_OnClick( btn )

	local frame = btn.frame;
	
	--Toggle box display
	if (frame.box:IsShown()) then
		frame.box:Hide();
	else
	
		--Close all other standard menus
		CloseDropDownMenus();
		
		--Close all dropdowns
		PrimeGui.CloseAllDropdowns();
		
		--Show this dropdown
		frame:UpdateAllItems();
		frame.box:Show();
	end
end

function PrimeGui.Drop_OnHide( frame )
	frame.box:Hide();
end

function PrimeGui.Drop_Drop_OnHide( drop )
	drop.frame.box:Hide();
end

function PrimeGui.Drop_Item_OnEnter( item )
	item.highlight:Show();
end

function PrimeGui.Drop_Item_OnLeave( item )
	item.highlight:Hide();
end

function PrimeGui.Drop_Item_OnClick( item )

	local frame = item.frame;
	
	--Close box
	frame.box:Hide();
	
	--Select clicked item
	local frame = item.frame;
	frame:SelectIndex( item.index );
	
	--Execute script if registered
	local script = frame.OnValueChanged;
	if (script) then script( frame ); end
end

function PrimeGui.Drop_Box_OnMouseWheel( box, value )

	local scroll = box.frame.scroll;
	if (not scroll:IsShown()) then return end;
	
	if (value > 0)
	then scroll:SetValue( scroll:GetValue() - scroll:GetValueStep() );
	else scroll:SetValue( scroll:GetValue() + scroll:GetValueStep() );
	end
end

function PrimeGui.Drop_Scroll_Up_OnClick( btn )
	btn.scroll:SetValue( btn.scroll:GetValue() - btn.scroll:GetValueStep() );
end

function PrimeGui.Drop_Scroll_Down_OnClick( btn )
	btn.scroll:SetValue( btn.scroll:GetValue() + btn.scroll:GetValueStep() );
end

function PrimeGui.Drop_Scroll_OnMinMaxChanged( scroll, minValue, maxValue )

	if (scroll:GetValue() == minValue)
	then scroll.btnUp:Disable();
	else scroll.btnUp:Enable();
	end
	
	if (scroll:GetValue() == maxValue)
	then scroll.btnDown:Disable();
	else scroll.btnDown:Enable();
	end
	
end

function PrimeGui.Drop_Scroll_OnValueChanged( scroll, value )
	
	local minValue,maxValue = scroll:GetMinMaxValues();
	
	if (value == minValue)
	then scroll.btnUp:Disable();
	else scroll.btnUp:Enable();
	end
	
	if (value == maxValue)
	then scroll.btnDown:Disable();
	else scroll.btnDown:Enable();
	end

	local frame = scroll.frame;
	if (frame.scrollValue ~= value) then
		frame.scrollValue = value;
		frame:UpdateAllItems();
	end
end
