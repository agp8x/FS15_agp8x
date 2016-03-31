SpecializationUtil.registerSpecialization("SowingCounter", "SowingCounter", g_currentModDirectory.."SowingCounter.lua")

SowingCounter_Register = {};

function SowingCounter_Register:loadMap(name)
	if self.firstRun == nil then
		self.firstRun = false;
		
		print("-- registering Sowing counter specialization by agp8x (based on work of Manuel Leithner (SFM-Modding))");
		
		for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
			if v ~= nil then
				local allowInsertion = true;
				for i = 1, table.maxn(v.specializations) do
					local vs = v.specializations[i];
					if vs ~= nil and vs == SpecializationUtil.getSpecialization("sowingMachine") then
						local v_name_string = v.name 
						local point_location = string.find(v_name_string, ".", nil, true)
						if point_location ~= nil then
							local _name = string.sub(v_name_string, 1, point_location-1);
							if rawget(SpecializationUtil.specializations, string.format("%s.SowingCounter", _name)) ~= nil then
								allowInsertion = false;
								--print(tostring(v.name)..": Specialization SowingCounter is present! SowingCounter was not inserted!");
							end;
						end;
						if allowInsertion then
							print("adding SowingCounter to "..tostring(v.name));
							table.insert(v.specializations, SpecializationUtil.getSpecialization("SowingCounter"));
						end;
					end;
				end;
			end;	
		end;
	end;
end;

function SowingCounter_Register:deleteMap()
  
end;

function SowingCounter_Register:keyEvent(unicode, sym, modifier, isDown)

end;

function SowingCounter_Register:mouseEvent(posX, posY, isDown, isUp, button)

end;

function SowingCounter_Register:update(dt)
	
end;

function SowingCounter_Register:draw()
  
end;

addModEventListener(SowingCounter_Register);