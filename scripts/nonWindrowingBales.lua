--
-- allow bales for non-windrow fruitTypes
--
-- @author  agp8x <ls@agp8x.org>
-- @date  01.04.16
--
--<extraBales>
--	<bale fillType="chaff" filename="baleChaff240.i3d" isRoundBale="false"  width="1.2" height="0.9" length="2.4" />
--</extraBales>

if not BaleUtil.nonWindrowExtension01042016 then
	local getBale_orig = BaleUtil.getBale;
	BaleUtil.getBale = function(fillType, width, height, length, diameter, isRoundbale)
		if FruitUtil.fillTypeToFruitType[fillType] ~= nil and FruitUtil.fruitIndexToDesc[FruitUtil.fillTypeToFruitType[fillType]].windrowName == nil then
			--override no windrow filltype
			local key = BaleUtil.getBaleKey(Fillable.fillTypeIntToName[fillType], width, height, length, diameter, isRoundbale);
			if BaleUtil[key] ~= nil then
				local desc=BaleUtil.baleIndexToDesc[BaleUtil[key]]
				return desc;
			end;
		end;
		-- default
		return getBale_orig(fillType, width, height, length, diameter, isRoundbale)
	end;
	
	BaleUtil.nonWindrowExtension01042016 = true;
end;

local path = Utils.getFilename("extraBales.xml", g_currentModDirectory);
if fileExists(path) then
	local xmlFile = loadXMLFile("extraBales", path);
	local i=0;
	while true do
	local key = string.format("extraBales.bale(%d)", i);
	if not hasXMLProperty(xmlFile, key) then
		break;
	end;
	local fillType = getXMLString(xmlFile, key.."#fillType");
	local filename = getXMLString(xmlFile, key.."#filename");
	if fillType ~= nil and filename ~= nil then
		local isRoundBale = Utils.getNoNil(getXMLBool(xmlFile, key.."#isRoundBale"), false);
		local width = Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, key.."#width"), 1.2), 2);
		local height = Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, key.."#height"), 0.9), 2);
		local length = Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, key.."#length"), 2.4), 2);
		local diameter = Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, key.."#diameter"), 1.8), 2);
		local key = BaleUtil.getBaleKey(fillType, width, height, length, diameter, isRoundbale);
		if BaleUtil[key] == nil then
			BaleUtil.registerBaleType(filename, fillType, width, height, length, diameter, isRoundbale);
		end;
	end;
	i = i + 1;
	end;
end;