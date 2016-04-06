--
-- fermenting bales change fruitTypes after some time
--
-- @author  agp8x <ls@agp8x.org>
-- @date  06.04.16
--
FermentingBale = {}

function FermentingBale:setNodeId(nodeId)
	local isFermenting = getUserAttribute(nodeId, "isFermentingBale");
	if isFermenting then
		for _, bale in pairs(BaleUtil.fermentingBales) do
			if bale.fillType == self.fillType and not self.fermentingLoaded then
				self.fermentingDuration = bale.ticks;
				self.fermentingTarget = bale.target;
				break;
			end;
		end;
	end;
end;
function FermentingBale:update(dt)
end;
function FermentingBale:updateTick(dt)
	if self.fermentingDuration and self.fermentingDuration > 0 then
		self.fermentingDuration = self.fermentingDuration - dt;
		if self.fermentingDuration < 0 then
			self.fillType = self.fermentingTarget;
			self.fermentingDuration = nil;
		end;
	end;
end;
function FermentingBale:getSaveAttributesAndNodes(nodeIdent, superFunc)
	local attributes, nodes = superFunc(self, nodeIdent);
	if self.fermentingTarget then
		attributes = attributes..' fermentingDuration="'..tostring(self.fermentingDuration)..'"'
	end;
	return attributes, nodes;
end;
function FermentingBale:loadFromAttributesAndNodes(xmlFile, key, resetVehicles, superFunc)
	local fermentingDuration = getXMLInt(xmlFile, key.."#fermentingDuration");
	if fermentingDuration then
		self.fermentingLoaded = true;
		self.fermentingDuration = fermentingDuration;
	end;
	return superFunc and superFunc(self, xmlFile, key, resetVehicles) or BaseMission.VEHICLE_LOAD_OK;
end;

if not BaleUtil.fermentingBales ~= nil then
	BaleUtil.fermentingBales = {}
	local path = Utils.getFilename("fermentingBales.xml", g_currentModDirectory);
	if fileExists(path) then
		local xmlFile = loadXMLFile("fermentingBales", path);
		local defaultTicks = getXMLInt(xmlFile, "fermentingBales#defaultTicks");
		local i = 0;
		while true do
			local key = string.format("fermentingBales.bale(%d)", i);
			if not hasXMLProperty(xmlFile, key) then
				break;
			end;
			local fillType = getXMLString(xmlFile, key.."#fillType");
			local target = getXMLString(xmlFile, key.."#target");
			local ticks = Utils.getNoNil(getXMLInt(xmlFile, key.."#ticks"), defaultTicks);
			if fillType ~= nil and target ~= nil then
				fillType = Fillable.fillTypeNameToInt[fillType];
				target = Fillable.fillTypeNameToInt[target];
				if fillType ~= nil and target ~= nil then
					table.insert(BaleUtil.fermentingBales, {fillType=fillType, target=target, ticks=ticks});
				end;
			end;
			i = i + 1;
		end;
	end;
	
	Bale.setNodeId = Utils.appendedFunction(Bale.setNodeId, FermentingBale.setNodeId);
	Bale.updateTick = Utils.appendedFunction(Bale.updateTick, FermentingBale.updateTick);
	Bale.update = Utils.appendedFunction(Bale.update, FermentingBale.update);
	local baleGetSaveAttributesAndNodes = Bale.getSaveAttributesAndNodes;
	Bale.getSaveAttributesAndNodes = function(self, nodeIdent)
		return FermentingBale.getSaveAttributesAndNodes(self, nodeIdent, baleGetSaveAttributesAndNodes);
	end;
	local baleLoadFromAttributesAndNodes = Bale.loadFromAttributesAndNodes;
	Bale.loadFromAttributesAndNodes = function(self, xmlFile, key, resetVehicles)
		return FermentingBale.loadFromAttributesAndNodes(self, xmlFile, key, resetVehicles, baleLoadFromAttributesAndNodes);
	end;
end;