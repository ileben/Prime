--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]


--Object
--=============================================================

function PrimeGui.Object_New( o )

	o.Init                  = PrimeGui.Object_Init;
	o.Free                  = PrimeGui.Object_Free;
	o.RegisterScript        = PrimeGui.Object_RegisterScript;
	o.UnregisterScript      = PrimeGui.Object_UnregisterScript;
	o.UnregisterAllScripts  = PrimeGui.Object_UnregisterAllScripts;
	o.InvokeScript          = PrimeGui.Object_InvokeScript;
	
	return o;
end

function PrimeGui.Object_Init( o )
end

function PrimeGui.Object_Free( o )
end

function PrimeGui.Object_RegisterScript( object, script, func )

	--Create callback table if missing
	if (object.callbacks == nil) then
		object.callbacks = {};
	end
	
	if (object.callbacks[ script ] == nil) then
		object.callbacks[ script ] = {};
	end
	
	--Check if function already registered
	local callbacks = object.callbacks[ script ];
	for i,f in ipairs( callbacks ) do
		if (f == func) then
			return
		end
	end
	
	--Add to callback table
	table.insert( callbacks, func );
	
	--Check for missing script handler
	if (object:GetScript( script ) == nil) then
	
		--Closure passes script name to invoke function along with other arguments
		local scriptClosure = function( object, ... )
			PrimeGui.Object_InvokeScript( object, script, ... );
		end
		
		--Set closure as script handler
		object:SetScript( script, scriptClosure );
	end
end

function PrimeGui.Object_UnregisterScript( object, script, func )

	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
	
	if (object.callbacks[ script ] == nil) then
		return
	end
	
	--Search for registered function
	local callbacks = object.callbacks[ script ];
	for i,f in ipairs( callbacks ) do
		if (f == func) then
		
			--Remove from callback table
			table.remove( callbacks, i );
		end
	end
end

function PrimeGui.Object_UnregisterAllScripts( object )

	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
		
	--Remove all callbacks from every callback tables
	for script,callbacks in pairs(object.callbacks) do
		PrimeUtil.ClearTable( callbacks );
	end
end

function PrimeGui.Object_InvokeScript( object, script, ... )
	
	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
	
	--Invoke all the callback functions
	local callbacks = object.callbacks[ script ];
	for i,func in ipairs( callbacks ) do
		func( object, ... );
	end
end
