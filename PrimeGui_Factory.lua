--[[

====================================================
LibPrime
Author: Ivan Leben
====================================================

--]]

PrimeGui = {};

--Factory
--===========================================================================

function PrimeGui.NewObject( class )

	--Init class factory first time
	if (PrimeGui.factory == nil) then
		PrimeGui.factory = {};
	end
	
	if (PrimeGui.factory[ class ] == nil) then
		PrimeGui.factory[ class ] = {};
		PrimeGui.factory[ class ].objects = {};
		PrimeGui.factory[ class ].capacity = 0;
		PrimeGui.factory[ class ].used = 0;
	end
	
	--Get class-specific factory
	local object = nil;
	local factory = PrimeGui.factory[ class ];
	local capacity = table.getn( factory.objects );
	
	--Check if there's any unused objects left
	if (factory.used < capacity) then
		
		--Return existing object
		factory.used = factory.used + 1;
		object = factory.objects[ factory.used ];

	else

		--Create new object if capacity exhausted
		factory.used = capacity + 1;

		if     (class == "button")      then object = PrimeGui.Button_New      ( "PrimeGui.Button"      .. factory.used );
		elseif (class == "input")       then object = PrimeGui.Input_New       ( "PrimeGui.Input"       .. factory.used );
		elseif (class == "checkbox")    then object = PrimeGui.Checkbox_New    ( "PrimeGui.Checkbox"    .. factory.used );
		elseif (class == "list")		then object = PrimeGui.List_New        ( "PrimeGui.List"        .. factory.used );
		elseif (class == "dropdown")    then object = PrimeGui.Drop_New        ( "PrimeGui.Dropdown"    .. factory.used );
		elseif (class == "color")       then object = PrimeGui.ColorSwatch_New ( "PrimeGui.Color"       .. factory.used );
		elseif (class == "header")      then object = PrimeGui.Header_New      ( "PrimeGui.Header"      .. factory.used );
		elseif (class == "groupframe")  then object = PrimeGui.GroupFrame_New  ( "PrimeGui.GroupFrame"  .. factory.used );
		elseif (class == "tab")         then object = PrimeGui.Tab_New         ( "PrimeGui.Tab"         .. factory.used );
		elseif (class == "tabframe")    then object = PrimeGui.TabFrame_New    ( "PrimeGui.TabFrame"    .. factory.used );
		elseif (class == "scrollframe") then object = PrimeGui.ScrollFrame_New ( "PrimeGui.ScrollFrame" .. factory.used );
		elseif (class == "font")        then object = PrimeGui.FontDrop_New    ( "PrimeGui.FontDrop"    .. factory.used );
		elseif (class == "texture")     then object = PrimeGui.TexDrop_New     ( "PrimeGui.TexDrop"     .. factory.used );
		elseif (class == "window")      then object = PrimeGui.Window_New      ( "PrimeGui.Window"      .. factory.used );
		end

		--Add to list of objects
		object.factoryClass = class;
		object.factoryId = factory.used;
		table.insert( factory.objects, object );

	end

	--Init object
	object.factoryUsed = true;
	object:Show();
	
	--Notify object it's been inited
	if (object.Init) then
		object:Init();
	end
	
	return object;
end


function PrimeGui.FreeObject( object )

	--Object must be used
	if (object.factoryUsed == false) then
		return
	end
	
	--Swap freed object with last used object and their ids
	local factory = PrimeGui.factory[ object.factoryClass ];
	
	if (object.factoryId < factory.used) then

		local objectId = object.factoryId;
		local lastId = factory.used;
		local last = factory.objects[ lastId ];

		factory.objects[ objectId ] = last;
		factory.objects[ lastId ] = object;

		object.factoryId = lastId;
		last.factoryId = objectId;
	end

	factory.used = factory.used - 1;
	
	--Reset object
	object.factoryUsed = false;
	object:Hide();
	object:ClearAllPoints();
	object:SetParent( nil );
	
	--Notify object it's been freed
	if (object.Free) then
		object:Free();
	end
end


function PrimeGui.FreeAllObjects()

	--Factory must exist
	if (PrimeGui.factory == nil) then
		return
	end
	
	--Walk every factory
	for class,factory in pairs(PrimeGui.factory) do

		--Walk every object in factory
		for id,object in ipairs(factory.objects) do
		
			--Reset object
			object.factoryUsed = false;
			object:Hide();
			object:ClearAllPoints();
			object:SetParent( nil );
		end
		
		--Walk every object in factory
		for id,object in ipairs(factory.objects) do
		
			--Notify object it's been freed
			if (object.Free) then
				object:Free()
			end
		end
		
		factory.used = 0;
	end
end
