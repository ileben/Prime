--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]


--List that allows custom item frames
--=====================================================================

function PrimeGui.List_New( name )

	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetHeight( 200 );
	
	--Scroll
	local s = CreateFrame( "Slider", name.."Scroll", f, "MinimalScrollBarTemplate" );
	s:SetPoint( "TOPRIGHT", f, "TOPRIGHT", 0, -18 );
	s:SetPoint( "BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 18 );
	s:SetScript( "OnMinMaxChanged", PrimeGui.List_Scroll_OnMinMaxChanged );
	s:SetScript( "OnValueChanged", PrimeGui.List_Scroll_OnValueChanged );
	
	s.btnUp = _G[s:GetName().."ScrollUpButton"];
	s.btnUp:SetScript( "OnClick", PrimeGui.List_Scroll_Up_OnClick );
	s.btnUp.scroll = s;
	
	s.btnDown = _G[s:GetName().."ScrollDownButton"];
	s.btnDown:SetScript( "OnClick", PrimeGui.List_Scroll_Down_OnClick );
	s.btnDown.scroll = s;
	
	s.frame = f;
	f.scroll = s;
	
	--Internal vars
	f.items = {};
	f.data = {};
	f.numData = 0;
	f.numItems = 0;
	f.selection = 0;
	
	f.listHeight = nil;
	f.itemHeight = nil;
	f.scrollValue = 0;
	
	--Functions
	PrimeGui.Object_New( f );
	
	f.Init             = PrimeGui.List_Init;
	f.Free             = PrimeGui.List_Free;
	f.AddItem          = PrimeGui.List_AddItem;
	f.InsertItem       = PrimeGui.List_InsertItem;
	f.RemoveItem       = PrimeGui.List_RemoveItem;
	f.RemoveAllItems   = PrimeGui.List_RemoveAllItems;
	f.SelectIndex      = PrimeGui.List_SelectIndex;
	f.SelectValue      = PrimeGui.List_SelectValue;
	f.GetSelectedIndex = PrimeGui.List_GetSelectedIndex;
	f.GetSelectedValue = PrimeGui.List_GetSelectedValue;
	f.SetScrollOffset  = PrimeGui.List_SetScrollOffset;
	f.GetScrollOffset  = PrimeGui.List_GetScrollOffset;
	
	--Internal Functions
	f.CreateItem       = PrimeGui.List_CreateItem;
	f.UpdateItem       = PrimeGui.List_UpdateItem;
	f.UpdateAllItems   = PrimeGui.List_UpdateAllItems;
	f.UpdateSelection  = PrimeGui.List_UpdateSelection;
	
	f:RegisterScript( "OnSizeChanged", PrimeGui.List_OnSizeChanged );
	f:RegisterScript( "OnMouseWheel", PrimeGui.List_OnMouseWheel );
	
	return f;
end

function PrimeGui.List_Init( frame )
	
	PrimeGui.Object_Init( frame );

	--Reset data list
	frame.numData = 0;
	frame.numItems = 0;
	frame.selection = 0;
	
	--Reset cached height
	frame.listHeight = nil;
	frame.itemHeight = nil;
	
	--Create dummy item to get its height
	frame.dummyItem = frame:CreateItem();
	frame.itemHeight = frame.dummyItem:GetHeight();
	
	--Reset scroll position
	frame.scrollValue = 0;
	frame.scroll:SetMinMaxValues(1,1);
	frame.scroll:SetValueStep( 1 );
	frame.scroll:SetValue(1);
	
end

function PrimeGui.List_Free( frame )
	
	--Superclass
	PrimeGui.Object_Free( frame );
end

function PrimeGui.List_UpdateAllItems( frame )
	
	--Get frame height if set directly
	if (frame:GetHeight() and frame:GetHeight() > 0) then
		frame.listHeight = frame:GetHeight();
	end
	
	--Bail if we don't have a valid height
	if (frame.listHeight == nil) then
		return;
	end
	
	--Update scroll range
	frame.numItems = floor(frame.listHeight / frame.itemHeight);
	
	if (frame.numData > frame.numItems) then
		frame.scroll:SetMinMaxValues( 1, frame.numData - frame.numItems + 1 );
		frame.scroll:Show();
	else
		frame.scroll:SetValue( 1 );
		frame.scroll:Hide();
	end
	
	--Update visible items
	local prevItem = nil;
	for i=1,frame.numItems do
		
		--Create new item if missing
		if (i > table.getn(frame.items)) then
		
			--Create item frame and add to list of items
			local item = frame:CreateItem();
			table.insert( frame.items, item );
			item.frame = frame;
			
			--Cache item height
			if (frame.itemHeight == nil) then
				frame.itemHeight = item:GetHeight();
			end
			
			--Attach to previous item or top of the frame
			item:SetParent( frame );
			item:ClearAllPoints();
			
			if (prevItem) then
				item:SetPoint( "TOPLEFT", prevItem, "BOTTOMLEFT", 0,0 );
				item:SetPoint( "TOPRIGHT", prevItem, "BOTTOMRIGHT", 0,0 );
			else
				item:SetPoint( "TOPLEFT", frame, "TOPLEFT", 0,0 );
				item:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", 0,0 );
			end
			
			--Create item hover highlight
			local h = item:CreateTexture(nil, "OVERLAY");
			h:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			h:SetBlendMode("ADD");
			h:SetAllPoints( item );
			h:Hide()
			h:SetGradientAlpha( "HORIZONTAL",
			  1,1,1, 0.5,
			  1,1,1, 0.5 );
			item.highlight = h;
			
			--Create item selection highlight
			local s = item:CreateTexture(nil, "OVERLAY");
			s:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			s:SetBlendMode("ADD");
			s:SetAllPoints( item );
			s:Hide()
			s:SetGradientAlpha( "HORIZONTAL",
			  1,1,1, 1.0,
			  1,1,1, 1.0 );
			item.selection = s;
			
			--Register scripts
			item:SetScript( "OnEnter", PrimeGui.List_Item_OnEnter );
			item:SetScript( "OnLeave", PrimeGui.List_Item_OnLeave );
			item:SetScript( "OnMouseUp", PrimeGui.List_Item_OnClick );
		end
		
		--Get data offset
		local d = frame.scroll:GetValue() + i - 1;
		if (d <= frame.numData) then
		
			--Update and show items with data
			local item = frame.items[i];
			item.index = d;
			item:Show();
			frame:UpdateItem( item, frame.data[d].value, (d == frame.selection) );
			
		else
			--Hide items with no data
			local item = frame.items[i];
			item.highlight:Hide();
			item:Hide();
		end
		
		--Next item
		prevItem = frame.items[i];
	end
	
	--Hide invisible items
	for i = frame.numItems+1, table.getn(frame.items) do
		frame.items[i].highlight:Hide();
		frame.items[i]:Hide();
	end
	
	--Make space for scroller if visible
	if (frame.items[1]) then
		if (frame.scroll:IsShown())
		then frame.items[1]:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", -20, 0 );
		else frame.items[1]:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", 0, 0 );
		end
	end
end


function PrimeGui.List_AddItem( frame, value )

	--Insert at the back
	frame:InsertItem( value, frame.numData+1 );
end


function PrimeGui.List_InsertItem( frame, value, index )

	--Ensure valid index
	if (index < 1) then
		index = 1;
	end
	
	if (index > frame.numData+1) then
		index = frame.numData+1;
	end
	
	--Create new data table if missing (wrap value in a table so that inserting nil is possible)
	if (frame.numData == table.getn(frame.data)) then
		table.insert( frame.data, { value = nil } );
	end
	
	--Shift values above
	for i = frame.numData, index, -1 do
		frame.data[i+1].value = frame.data[i].value;
	end
	
	--Store value
	frame.numData = frame.numData + 1;
	frame.data[ index ].value = value;
	
	--Select first item
	if (frame.numData == 1) then
		frame:SelectIndex(1);
	end
	
	frame:UpdateAllItems();
	
end

function PrimeGui.List_RemoveItem( frame, index )

	--Check for valid index
	if (index < 1 or index > frame.numData) then
		return;
	end
	
	--Shift values above
	for i=1, i<numData-1 do
		frame.data[i].value = frame.data[i+1].value;
	end
	
	--Remove value
	frame.numData = frame.numData - 1;
	
	--Deselect if selection removed
	if (frame.selection == index) then
		frame.selection = 0;
	end
	
	frame:UpdateAllItems();
end

function PrimeGui.List_RemoveAllItems( frame )

	--Clear data and deselect
	frame.numData = 0;
	frame.selection = 0;
	
	frame:UpdateAllItems();
	
end

function PrimeGui.List_SelectIndex( frame, index )
	if (index >= 1 and index <= frame.numData) then
		frame.selection = index;
		frame:UpdateAllItems();
		frame:UpdateSelection( index );
	end
end

function PrimeGui.List_SelectValue( frame, value )
	for i,data in ipairs( frame.data ) do
		if (data.value == value) then
			frame:SelectIndex( i );
			break;
		end
	end
end

function PrimeGui.List_GetSelectedIndex( frame )
	return frame.selection;
end

function PrimeGui.List_GetSelectedValue( frame )
	if (frame.selection > 0)
	then return frame.data[ frame.selection ].value;
	else return nil;
	end
end


function PrimeGui.List_Item_OnEnter( item )
	item.highlight:Show();
end

function PrimeGui.List_Item_OnLeave( item )
	item.highlight:Hide();
end

function PrimeGui.List_Item_OnClick( item )

	local frame = item.frame;
	
	--Select clicked item
	frame:SelectIndex( item.index );
	
	--Execute script if registered
	local script = frame.OnValueChanged;
	if (script) then script( frame ); end
end

function PrimeGui.List_OnSizeChanged( frame, width, height )

	local oldHeight = frame.listHeight;
	frame.listHeight = height;
	
	if (oldHeight ~= height) then
		frame:UpdateAllItems();
	end
end

function PrimeGui.List_OnMouseWheel( frame, value )

	local scroll = frame.scroll;
	if (not scroll:IsShown()) then return end;
	
	if (value > 0)
	then scroll:SetValue( scroll:GetValue() - scroll:GetValueStep() );
	else scroll:SetValue( scroll:GetValue() + scroll:GetValueStep() );
	end
end

function PrimeGui.List_Scroll_Up_OnClick( btn )
	btn.scroll:SetValue( btn.scroll:GetValue() - btn.scroll:GetValueStep() );
end

function PrimeGui.List_Scroll_Down_OnClick( btn )
	btn.scroll:SetValue( btn.scroll:GetValue() + btn.scroll:GetValueStep() );
end

function PrimeGui.List_Scroll_OnMinMaxChanged( scroll, minValue, maxValue )

	if (scroll:GetValue() == minValue)
	then scroll.btnUp:Disable();
	else scroll.btnUp:Enable();
	end
	
	if (scroll:GetValue() == maxValue)
	then scroll.btnDown:Disable();
	else scroll.btnDown:Enable();
	end
	
end

function PrimeGui.List_Scroll_OnValueChanged( scroll, value )
	
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

function PrimeGui.List_SetScrollOffset( frame, value )

	frame.scroll:SetValue( value );
end

function PrimeGui.List_GetScrollOffset( frame, value )

	return frame.scroll:GetValue();
end

--Default textual, selectable items
--====================================================================

function PrimeGui.List_CreateItem( frame )

	--Frame
	local f = CreateFrame( "Frame", "SomeFrame" );
	f:SetHeight( 20 );
	f:SetWidth( 100 );
	f:SetParent( frame );
	
	--Label
	local l = f:CreateFontString( "SomeString", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 10 );
	l:SetTextColor( 1,1,1 );
	l:SetJustifyH( "LEFT" );
	l:SetAllPoints( f );
	f.label = l;
	
	return f;
end


function PrimeGui.List_UpdateItem( frame, item, value, selected )

	--Update item label
	if (value.text) then
		item.label:SetText( value.text );
	end
	
	--Show highlight for selected item
	if (selected)
	then item.selection:Show();
	else item.selection:Hide();
	end
end


function PrimeGui.List_UpdateSelection( frame, index )
end
