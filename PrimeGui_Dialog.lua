--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]

--Confirm frame
--====================================================================

function PrimeGui.ShowConfirmFrame (message, acceptFunc, cancelFunc, arg)

  if (not PrimeGui.confirmFrame) then
  
    --Create new Frame which subclasses Bling.Roster
    local f = CreateFrame( "Frame", "PrimeGui.ConfirmFrame", UIParent );
    f:SetFrameStrata( "DIALOG" );
    f:SetToplevel( true );
    f:SetWidth( 300 );
    f:SetHeight( 100 );
    f:SetPoint( "CENTER", 0, 150 );
    f:EnableMouse( true );
    
    --Setup the background texture
    f:SetBackdrop(
      {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
       edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
       tile = true, tileSize = 32, edgeSize = 32,
       insets = { left = 11, right = 12, top = 12, bottom = 11 }});
    f:SetBackdropColor(0,0,0,1);
    
    --Create the text label
    local txt = f:CreateFontString( "PrimeGui.InputFrame.Label", "OVERLAY", "GameFontNormal" );
    txt:SetTextColor( 1, 1, 1, 1 );
    txt:SetPoint( "TOPLEFT", 20, -20 );
    txt:SetPoint( "TOPRIGHT", -20, -20 );
    txt:SetHeight( 40 );
    txt:SetWordWrap( true );
    txt:SetText( message );
    txt:Show();
    
    --Create the Accept button
    local btnAccept = CreateFrame( "Button", nul, f, "UIPanelButtonTemplate" );
    btnAccept.myframe = f;
    btnAccept:SetWidth( 100 );
    btnAccept:SetHeight( 20 );
    btnAccept:SetPoint( "TOPRIGHT", f, "CENTER", -10, -10 );
    btnAccept:SetText( "Accept" );
    btnAccept:SetScript( "OnClick",
      function (self)
        self.myframe:Hide();
        if (self.myframe.acceptFunc) then
          self.myframe.acceptFunc( self.myframe.arg );
        end
      end
    );
    
    --Create the Cancel button
    local btnCancel = CreateFrame( "Button", nul, f, "UIPanelButtonTemplate" );
    btnCancel.myframe = f;
    btnCancel:SetWidth( 100 );
    btnCancel:SetHeight( 20 );
    btnCancel:SetPoint( "TOPLEFT", f, "CENTER", 10, -10 );
    btnCancel:SetText( "Cancel" );
    btnCancel:SetScript( "OnClick",
      function (self)
        self.myframe:Hide();
        if (self.myframe.cancelFunc) then
          self.myframe.cancelFunc( self.myframe.arg );
        end
      end
    );
    
    f.text = txt;
    PrimeGui.confirmFrame = f;
  end
  
  --Apply current value and show
  local f = PrimeGui.confirmFrame;
  f.acceptFunc = acceptFunc;
  f.cancelFunc = cancelFunc;
  f.text:SetText( message  );
  f.arg = arg;
  f:Hide();
  f:Show();
  
end


--Input frame
--====================================================================

function PrimeGui.ShowInputFrame (message, acceptFunc, cancelFunc, arg)

  if (not PrimeGui.inputFrame) then
  
    --Create new Frame which subclasses Bling.Roster
    local f = CreateFrame( "Frame", "PrimeGui.ConfirmFrame", UIParent );
    f:SetFrameStrata( "DIALOG" );
    f:SetToplevel( true );
    f:SetWidth( 300 );
    f:SetHeight( 120 );
    f:SetPoint( "CENTER", 0, 150 );
    f:EnableMouse( true );
    
    --Setup the background texture
    f:SetBackdrop(
      {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
       edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
       tile = true, tileSize = 32, edgeSize = 32,
       insets = { left = 11, right = 12, top = 12, bottom = 11 }});
    f:SetBackdropColor(0,0,0,1);
    
    --Create the text label
    local txt = f:CreateFontString( "PrimeGui.InputFrame.Label", "OVERLAY", "GameFontNormal" );
    txt:SetTextColor( 1, 1, 1, 1 );
    txt:SetPoint( "TOPLEFT", 20, -20 );
    txt:SetPoint( "TOPRIGHT", -20, -20 );
	txt:SetJustifyH( "LEFT" );
    txt:SetHeight( 20 );
    txt:SetWordWrap( false );
    txt:SetText( message );
    txt:Show();
	
	--Create the input box
    local inp = CreateFrame( "EditBox", "PrimeGui.InpuFrame.Input", f, "InputBoxTemplate" );
	inp:SetPoint( "TOPLEFT", txt, "BOTTOMLEFT", 5,0 );
	inp:SetPoint( "TOPRIGHT", txt, "BOTTOMRIGHT", -1,0 );
	inp:SetHeight( 30 );
	inp:SetScript( "OnEnterPressed", PrimeGui.ConfirmFrame_Input_OnAcceptEvent );
	inp:SetScript( "OnEscapePressed", PrimeGui.ConfirmFrame_OnCancelEvent );
	inp.frame = f;
    
    --Create the Accept button
    local btnAccept = CreateFrame( "Button", nul, f, "UIPanelButtonTemplate" );
    btnAccept:SetWidth( 100 );
    btnAccept:SetHeight( 20 );
    btnAccept:SetPoint( "RIGHT", f, "CENTER", -10, 0 );
	btnAccept:SetPoint( "BOTTOM", f, "BOTTOM", 0, 20 );
    btnAccept:SetText( "Accept" );
    btnAccept:SetScript( "OnClick", PrimeGui.ConfirmFrame_Input_OnAcceptEvent );
    btnAccept.frame = f;
    
    --Create the Cancel button
    local btnCancel = CreateFrame( "Button", nul, f, "UIPanelButtonTemplate" );
    btnCancel:SetWidth( 100 );
    btnCancel:SetHeight( 20 );
    btnCancel:SetPoint( "LEFT", f, "CENTER", 10, 0 );
	btnCancel:SetPoint( "BOTTOM", f, "BOTTOM", 0, 20 );
    btnCancel:SetText( "Cancel" );
    btnCancel:SetScript( "OnClick", PrimeGui.ConfirmFrame_OnCancelEvent );
    btnCancel.frame = f;
    
    f.text = txt;
	f.input = inp;
    PrimeGui.inputFrame = f;
  end
  
  --Apply current value and show
  local f = PrimeGui.inputFrame;
  f.acceptFunc = acceptFunc;
  f.cancelFunc = cancelFunc;
  f.text:SetText( message  );
  f.input:SetText( "" );
  f.arg = arg;
  f:Hide();
  f:Show();
  
end

function PrimeGui.ConfirmFrame_Input_OnAcceptEvent( item )

	--Hide
	local frame = item.frame;
	frame:Hide();
	
	--Invoke accept callback
	if (frame.acceptFunc) then
		frame.acceptFunc( frame.input:GetText(), frame.arg );
	end
	
end

function PrimeGui.ConfirmFrame_OnCancelEvent( item )

	--Hide
	local frame = item.frame;
	frame:Hide();
	
	--Invoke cancel callback
	if (frame.cancelFunc) then
		frame.cancelFunc( frame.arg );
	end
end
