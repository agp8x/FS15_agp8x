--
-- extend Fruit Conversions of Combines to allow windrowed fruits
--
-- @author  agp8x <ls@agp8x.org>
-- @date  19.06.16
--
--[[
<xtendedConversion>
	<convert input="grass" output="grass_windrow" />
</xtendedConversion>
]]

function xtendedChoppaLoad(superFunc, self, xmlFile)
	superFunc(self, xmlFile);
	if hasXMLProperty(xmlFile, "vehicle.convertedFruits") and Combine.xtendedChoppa ~=nil then
		for _,v in pairs(Combine.xtendedChoppa) do
			self.convertedFruits[v.input] = v.output;
		end;
	end;
end;

if not Combine.xtendedChoppa19062016 then
	--Combine.load = Utils.overwrittenFunction(Combine.load, xtendedChoppaLoad);
	local combineLoad = Combine.load;
	Combine.load = function(self, xmlFile)
		return xtendedChoppaLoad(combineLoad, self, xmlFile)
	end;
	Combine.xtendedChoppa19062016 = true;
end;

local path = Utils.getFilename("xtendedChoppa.xml", g_currentModDirectory);
if fileExists(path) then
	Combine.xtendedChoppa = {};
	local xmlFile = loadXMLFile("xtendedChoppa", path);
	local i=0;
	while true do
	local key = string.format("xtendedConversion.convert(%d)", i);
	if not hasXMLProperty(xmlFile, key) then
		break;
	end;
	local input = getXMLString(xmlFile, key.."#input");
	local output = getXMLString(xmlFile, key.."#output");
	if input ~= nil and output ~= nil then
		table.insert(Combine.xtendedChoppa, {input=Fillable.fillTypeNameToInt[input], output=Fillable.fillTypeNameToInt[output]});
	end;
	i = i + 1;
	end;
end;
