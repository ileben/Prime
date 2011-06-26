--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]

PrimeUtil = {}

--Table manipulation
--=========================================================

function PrimeUtil.CopyTableKeys (dst, src)

  for key,value in pairs(src) do
    if (type( value ) == "table") then
      if (type( dst[key] ) ~= "table") then
        dst[key] = CopyTable( value );
      else
        CB.Util_CopyTableKeys( dst[key], value );
      end
    else
      dst[key] = value;
    end
  end
end

function PrimeUtil.MergeTables (t1, t2)
  local t = CopyTable(t1);
  CB.Util_CopyTableKeys(t,t2);
  return t;
end

function PrimeUtil.ClearTable (t)
  local len = table.getn( t );
  while len > 0 do
    table.remove( t );
    len = len - 1;
  end
end

function PrimeUtil.ClearTableKeys (t)
  for k,v in pairs(t) do
    t[ k ] = nil;
  end
end

function PrimeUtil.CountTableKeys( t )
	local count = 0;
	for k,v in pairs(t) do
		if (v ~= nil) then
			count = count + 1;
		end
	end
	return count;
end

--Capture list into table without creating a new one
--=========================================================

function PrimeUtil.CaptureList (t, ...)

  --Get first value in the list
  local i = 1;
  local v = select( i, ... );
  
  --Loop until end of list
  while v ~= nil do
  
    --Insert value at the end of the table
    table.insert( t, v );
  
    --Get next value
    i = i + 1;
    v = select( i, ... );
  end
end


--Spell icon cache
--========================================================

function PrimeUtil.GetSpellIcon (spellName)

  --Init cache table
  if (CB.iconCache == nil) then
    CB.iconCache = {};
  end
  
  --Try get it from the player's spellbook first
  local icon = GetSpellTexture( spellName );
  if (icon ~= nil) then
    CB.iconCache[ spellName ] = icon;
    return icon;
  end
  
  --Check for cached value
  local icon = CB.iconCache[ spellName ];
  if (icon ~= nil) then
    if (icon ~= "")
    then return icon;
    else return nil;
    end
  end
  
  --Search through all the spell IDs
  for i=1,100000 do
    local name,_,icon = GetSpellInfo( i );
    if (name == spellName) then
      CB.iconCache[ spellName ] = icon;
      return icon;
    end
  end
  
  --Mark not found
  CB.iconCache[ spellName ] = "";
end

--Enchant scanning from weapon tooltip
--========================================================

function PrimeUtil.GetWeaponEnchantName (inventorySlotId)

  local tt1 = CB.Util_GetTooltip(1); tt1:ClearLines();
  local tt2 = CB.Util_GetTooltip(2); tt2:ClearLines();
  
  --Set first tooltip to match inventory slot
  tt1:SetInventoryItem( "player", inventorySlotId );
  
  --Get hyperlink from first tooltip and set it to second tooltip
  local itemLink = select( 2, tt1:GetItem() );
  tt2:SetHyperlink( itemLink );
  
  --Iterate all the lines of first tooltip
  local numLines1 = tt1:NumLines();
  for l1=1,numLines1 do
  
    --Get line text and check if green color (red = 0)
    local line1 = CB.Util_GetTooltipLineLeft( tt1, l1 );
    local text1 = line1:GetText();
    if (line1:GetTextColor() == 0) then

      --Iterate all the lines of second tooltip
      local found = false;
      local numLines2 = tt2:NumLines();    
      for l2=1,numLines2 do
      
        --Get line text and check if line from first tooltip found
        local line2 = CB.Util_GetTooltipLineLeft( tt2, l2 );
        local text2 = line2:GetText();
        if (text2 == text1) then
          found = true;
          break;
        end
      end
      
      --The green line that is missing in the second tooltip is the enchant!
      if (not found) then
      
        --Get rid of the duration in brackets at the end
        local x = strfind( text1, "[(]" );
        if (x ~= nil) then x = x - 2; end
        return strsub( text1, 1, x );
      end
    end
  end
  
end

--Scannable tooltips
--========================================================

function PrimeUtil.GetTooltip (index)

  --Create tooltip table if missing
  if (CB.tooltips == nil) then
    CB.tooltips = {};
  end
  
  --Create tooltip at given index if missing
  if (CB.tooltips[ index ] == nil) then
  
    --Create new tooltip frame
    local tt = CreateFrame( "GameTooltip", "Prime_Tooltip"..index );
    tt:SetOwner( UIParent, "ANCHOR_NONE" );
    CB.tooltips[ index ] = tt;
    
    --Insert custom font strings for tooltip lines
    tt.text = {}
    for l=1,30 do
      tt.text[l] = {};
      tt.text[l].left = tt:CreateFontString();
      tt.text[l].left:SetFontObject( "GameFontNormal" );
      tt.text[l].right = tt:CreateFontString();
      tt.text[l].right:SetFontObject( "GameFontNormal" );
      tt:AddFontStrings( tt.text[l].left, tt.text[l].right );
    end
    
    --Clearing all lines will make tooltip store new text into custom ones
    tt:ClearLines();
  end
  
  return CB.tooltips[ index ];
end

function PrimeUtil.GetTooltipLineLeft (tooltip, index)
  return tooltip.text[ index ].left;
end

function PrimeUtil.GetTooltopLineRight (tooltip, index)
  return tooltip.text[ index ].right;
end

--Refresh a context menu by closing and reopening it
--=======================================================

function PrimeUtil.UpdateMenu (menu)

  --Check if the current menu frame matches the given menu and is shown
	if not (UIDROPDOWNMENU_OPEN_MENU == menu and DropDownList1:IsShown()) then
    return false
  end
    
  --Store current level and close all menu levels
  local lastMenuLevel = UIDROPDOWNMENU_MENU_LEVEL;
  CloseDropDownMenus()
 
  --Reopen the first menu level at the same position
  local x = DropDownList1:GetLeft();
  local y = DropDownList1:GetBottom()
  ToggleDropDownMenu( 1, nil, menu, UIParent, x, y  );
  
  --Iterate through all menu levels
  for l = 2, lastMenuLevel do
  
    --Get the frame of this menu level
    local menuFrame = _G['DropDownList'..l];
    if (menuFrame) then
    
      --Get the parent button of this menu level
      local _, buttonFrame = menuFrame:GetPoint();
      if (buttonFrame) then
    
        --Reopen this menu level with the same button as its anchor point
        ToggleDropDownMenu( l, buttonFrame.value, nil, nil, nil, nil, nil, buttonFrame );
        
      end
    end
  end
  
  return true
end


--[[
--Obsolete, but keeping it around just in case it
--comes in handy one day
========================================================

function ChronoBars.Bar_UpdateChildBounds (bar)
  
  local l=nil; local r=nil; local b=nil; local t=nil;
  if (bar.children == nil) then bar.children = {} end;
  CB.Util_ClearTable( bar.children );
  CB.Util_CaptureList( bar.children, bar:GetRegions() );
  --CB.Util_CaptureList( bar.children, bar:GetChildren() );
  
  local numChildren = table.getn( bar.children );
  for c=1,numChildren do
    
    if (bar.children[c]:IsShown()) then
    
      local cl = bar.children[c]:GetLeft() - bar:GetLeft();
      local cr = bar.children[c]:GetRight() - bar:GetLeft();
      local ct = bar.children[c]:GetTop() - bar:GetBottom();
      local cb = bar.children[c]:GetBottom() - bar:GetBottom();
      
      if (l==nil or cl < l) then l = cl; end
      if (r==nil or cr > r) then r = cr; end
      if (b==nil or cb < b) then b = cb; end
      if (t==nil or ct > t) then t = ct; end
      
    end
  end
  
  if (l == nil) then l = 0; end
  if (r == nil) then r = 0; end
  if (b == nil) then b = 0; end
  if (t == nil) then t = 0; end
  bar.boundsL = l;
  bar.boundsR = r;
  bar.boundsB = b;
  bar.boundsT = t;
  
end
--]]
