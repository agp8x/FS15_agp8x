--
-- fermenting bales change fruitTypes after some time
--
-- @author  agp8x <ls@agp8x.org>
-- @date  06.04.16
--
-- bales mounted by a baleLoader are resetted on loading, because GIANTS rather has redundant code to save bales rather than calling Bale.getSaveAttributesAndNodes() when saving a baleLoader

FermentingBale = {textSize=0.05}

function FermentingBale:setNodeId(nodeId)
	local isFermenting = getUserAttribute(nodeId, "isFermentingBale");
	if isFermenting then
		for _, bale in pairs(BaleUtil.fermentingBales) do
			if bale.fillType == self.fillType then
				self.fermentingTarget = bale.target;
				self.fermentingMax = bale.ticks;
				if not self.fermentingLoaded then
					self.fermentingDuration = bale.ticks;
				end;
				break;
			end;
		end;
	end;
end;
function FermentingBale:update(dt)
	--[[if self.isClient and g_currentMission.controlledVehicle == nil then
	
		if g_gui.currentGui == nil ]]
	if not self.fermentingTarget then
		return;
	end;
	if g_currentMission:getIsClient() then
		local radius = 5;
		local x,y,z = getWorldTranslation(g_currentMission.player.rootNode);
		local bx,by,bz = getWorldTranslation(self.nodeId);
		
		local distance = FermentingBale.euclideanDistance(x,y,z, bx,by,bz);
		if distance > radius then
			return;
		end;
		local sx,sy,sz = project(bx,by,bz);
		local fillType = Fillable.fillTypeIndexToDesc[self.fillType].nameI18N;
		local target = Fillable.fillTypeIndexToDesc[self.fermentingTarget].nameI18N;
		local progress;
		if self.fermentingDuration then
			progress = string.format("%i%%", (1 - (self.fermentingDuration / self.fermentingMax)) * 100);
		else
			progress = g_i18n:getText("agp8x_ferment_done");
		end;
		setTextColor(0,0,0,1);
		setTextBold(true);
		local text = string.format(g_i18n:getText("agp8x_ferment"), fillType, target, progress);
		local width = getTextWidth(FermentingBale.textSize, text);
		local height = getTextHeight(FermentingBale.textSize, text);
		renderText(sx-(height/2), sy-(width/2), FermentingBale.textSize, text);
	end;
end;
function FermentingBale:updateTick(dt)
	if (self.fermentingDuration and self.fermentingDuration > 0) or self.fermentingLoaded then
		self.fermentingDuration = self.fermentingDuration - dt;
		if self.fermentingDuration < 0 then
			self.fillType = self.fermentingTarget;
			self.fermentingDuration = nil;
			self.fermentingLoaded = false;
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
	local fermentingDuration = getXMLString(xmlFile, key.."#fermentingDuration");
	if fermentingDuration then
		self.fermentingLoaded = true;
		self.fermentingDuration = getXMLInt(xmlFile, key.."#fermentingDuration");
	end;
	return superFunc and superFunc(self, xmlFile, key, resetVehicles) or BaseMission.VEHICLE_LOAD_OK;
end;
function FermentingBale.euclideanDistance(x0,y0,z0, x1,y1,z1)
	return math.sqrt((x1-x0)^2 + (y1-y0)^2 + (z1-z0)^2)
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