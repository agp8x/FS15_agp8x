--
-- add fruit types to straw blower
--
-- @author  agp8x <ls@agp8x.org>
-- @date  06.04.16
--
ExtendedStrawBlower = {}
print("EXTENED BLOWER")
function ExtendedStrawBlower:load(xmlFile)
	for _,v in pairs(StrawBlower.ExtendedStrawBlower) do
	print(v,", ", Fillable.fillTypeNameToInt[v],", ", self.fillTypes[Fillable.fillTypeNameToInt[v]])
		self.fillTypes[Fillable.fillTypeNameToInt[v]] = true;
	end;
	return BaseMission.VEHICLE_LOAD_OK;
end;

if not StrawBlower.ExtendedStrawBlower then
	print("REGISTER")
	StrawBlower.ExtendedStrawBlower = {"chaff", "silage"}
	
	--[[local StrawBlowerLoad = StrawBlower.load;
	StrawBlower.load = function(self, xmlFile)
		return StrawBlowerLoad(self, xmlFile) and ExtendedStrawBlower.load(self, xmlFile);
	end;]]
	StrawBlower.load = Utils.appendedFunction(StrawBlower.load, ExtendedStrawBlower.load);
else
	print("dont register :(")
end;