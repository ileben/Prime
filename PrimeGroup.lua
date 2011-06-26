--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]

PrimeGroup = {};

function PrimeGroup.GetMembers()

  local members = {};
  
  if (UnitInRaid( "player" )) then

    --Walk the list of raid members
    local numMembers = GetNumRaidMembers();
    for m=1,numMembers do
    
      --Add to name list
      local name = GetRaidRosterInfo( m );
      table.insert( members, name );
    end

  else
  
    --Insert player's name
    local player = UnitName( "player" );
    table.insert( members, player );
    
    --Walk the list of party members
    local numMembers = GetNumPartyMembers();
    for m=1,numMembers do
    
      --Add to name list
      local name = UnitName ( "party"..m );
      table.insert( members, name );
    end
    
  end
  
  return members;
end

function PrimeGroup.GetLeader()

  if (UnitInRaid( "player" )) then

    --Find the name of the raid leader
    local numMembers = GetNumRaidMembers();
    for m=1,numMembers do
      local name, rank = GetRaidRosterInfo( m );
      if (rank == 2) then return name end
    end
    
    --Report error if not found
    AC:debug( "Failed finding raid leader!" );
    return nil;
    
  elseif (GetNumPartyMembers() > 0) then

    --Find the name of the party leader
    local leaderId = GetPartyLeaderIndex();
    if (leaderId == 0) then return UnitName( "player" );
    else return UnitName( "party"..leaderId );
    end
    
  else
    
    --Return player name if not in group
    return UnitName( "player" );
    
  end
end

function PrimeGroup.GetLootMaster()

	local method, partyMaster, raidMaster = GetLootMethod();
	
	--Looting must be set to Master Looter
	if (method ~= "master") then
		return nil;
	end
	
	--Check if in raid
	if (raidMaster ~= nil) then
		return UnitName( "raid"..raidMaster );
	end
	
	--Check if in party
	if (partyMaster ~= nil) then
		return UnitName( "party"..partyMaster );
	end
	
	--Doesn't exist
	return nil;
end

function PrimeGroup.GetClassColor( unitName )
	
	local class, classFile = UnitClass( unitName );
	if (classFile == nil) then
		return { r=1, g=1, b=1, a=1 };
	end
	
	--if (classFile == nil) then return "|cffffffff" end;
  
	local color = RAID_CLASS_COLORS[ classFile ];
	if (color == nil) then
		return { r=1, g=1, b=1, a=1 };
	end
	
	--if (color == nil) then return "|cffffffff" end;

	return color;
	
	--return string.format( "|cff%.2x%.2x%.2x", (color.r*255), (color.g*255), (color.b*255) );

end
