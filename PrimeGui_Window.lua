--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]

--Window frame
--=====================================================================

function PrimeGui.Window_New( name, title, resizable, close )
	
	--Frame
	local f = CreateFrame( "Frame", name, UIParent );
	f:SetFrameStrata( "DIALOG" );
	f:SetToplevel( true );
	
	f:SetBackdrop(
	  {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	   edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
	   tile = true, tileSize = 32, edgeSize = 32,
	   insets = { left = 11, right = 12, top = 12, bottom = 11 }});
	   
	f:SetBackdropColor(0,0,0,0.8);
	
	--Make movable
	f:SetMovable( true );
	f:SetResizable( true );
	f:EnableMouse( true );
	f:SetScript( "OnMouseDown", PrimeGui.Window_OnDragStart );
	f:SetScript( "OnMouseUp", PrimeGui.Window_OnDragStop );
	
	if (title) then
	
		--Create the title frame
		local fTitle = CreateFrame( "Frame", name.."Title", f );
		fTitle:SetWidth( 185 );
		fTitle:SetHeight( 40 );
		fTitle:SetPoint( "TOP", 0, 15 ); 
		fTitle:SetFrameStrata( "DIALOG" );
		fTitle.frame = f;
		
		--Make the title move the whole frame
		fTitle:EnableMouse( true );
		fTitle:SetScript( "OnMouseDown", PrimeGui.Window_Title_OnDragStart );
		fTitle:SetScript( "OnMouseUp", PrimeGui.Window_Title_OnDragStop );
		
		--Create the title texture
		--(the texture is larger and has transparent space around it
		-- so we have to scale it up around the title frame)
		local texTitle = fTitle:CreateTexture( nil, "BACKGROUND" );
		texTitle:SetTexture( "Interface/DialogFrame/UI-DialogBox-Header" );
		texTitle:SetPoint( "TOPRIGHT", 57, 0 );
		texTitle:SetPoint( "BOTTOMLEFT", -58, -24 );

		--Create the title text
		local txtTitle = fTitle:CreateFontString( nil, "OVERLAY", nil );
		txtTitle:SetFont( "Fonts/MORPHEUS.ttf", 15 );
		txtTitle:SetText( title );
		txtTitle:SetWidth( 300 );
		txtTitle:SetHeight( 64 );
		txtTitle:SetPoint( "TOP", 0, 12 );
	end
	
	if (resizable) then
	
		local sizer = CreateFrame("Frame",nil,f)
		sizer:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0);
		sizer:SetWidth(25);
		sizer:SetHeight(25);
		sizer:EnableMouse( true );
		sizer:SetScript("OnMouseDown", PrimeGui.Window_Sizer_OnMouseDown);
		sizer:SetScript("OnMouseUp", PrimeGui.Window_Sizer_OnMouseUp);
		sizer.frame = f;
		f.sizer = sizer;

		local line1 = sizer:CreateTexture(nil, "BACKGROUND");
		line1:SetWidth(14);
		line1:SetHeight(14);
		line1:SetPoint("BOTTOMRIGHT", -8, 8);
		line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border");
		local x = 0.1 * 14/17;
		line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5);
		f.line1 = line1;

		local line2 = sizer:CreateTexture(nil, "BACKGROUND");
		line2:SetWidth(8);
		line2:SetHeight(8);
		line2:SetPoint("BOTTOMRIGHT", -8, 8);
		line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border");
		local x = 0.1 * 8/17;
		line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5);
		f.line2 = line2;
		
	end
	
	if (close) then

		--Close button	
		local btnClose = CreateFrame( "Button", name.."CloseBtn", f, "UIPanelCloseButton" );
		btnClose.myframe = f;
		btnClose:SetPoint( "TOPRIGHT", -5, -7 );
		btnClose:SetScript( "OnClick", function (self) self.myframe:Hide() end );
		btnClose:Show();
	
	end
	
	--Container
	local pad = 25;
	local c = CreateFrame( "Frame", name.."Container", f );
	c:SetPoint( "BOTTOMLEFT", pad, pad );
	c:SetPoint( "TOPRIGHT", -pad, -pad-15 );
	c.frame = f;
	f.container = c;
	
	--Functions
	PrimeGui.Object_New( f );
	--PrimeGui.Container_New( f );
	--f.SizeToContent  = PrimeGui.Window_SizeToContent;
	return f;
end

function PrimeGui.Window_SizeToContent( frame )
	--CB.Print( "Content height "..tostring( frame:GetContentHeight() ));
	--frame.container:SetHeight( frame:GetContentHeight() + 1 );
end

function PrimeGui.Window_OnScrollSizeChanged( scroll, width, height )
	local frame = scroll.frame;
	--frame.container:SetWidth( width );
end

function PrimeGui.Window_OnDragStart( frame )
	frame:StartMoving();
end

function PrimeGui.Window_OnDragStop( frame )
	frame:StopMovingOrSizing();
end

function PrimeGui.Window_Title_OnDragStart( title )
	title.frame:StartMoving();
end

function PrimeGui.Window_Title_OnDragStop( title )
	title.frame:StopMovingOrSizing();
end

function PrimeGui.Window_Sizer_OnMouseDown( sizer )
	sizer.frame:StartSizing("BOTTOMRIGHT");
end

function PrimeGui.Window_Sizer_OnMouseUp( sizer )
	sizer.frame:StopMovingOrSizing();
end
