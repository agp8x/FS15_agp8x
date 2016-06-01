--
-- fermenting bales change fruitTypes after some time
--
-- @author  agp8x <ls@agp8x.org>
-- @date  06.04.16
--
-- Bales mounted by a baleLoader are resetted on loading, because GIANTS rather has redundant code to save bales rather than calling Bale.getSaveAttributesAndNodes() when saving a BaleLoader.
--
-- To add other fermenting bales: load a .lua appending the table BaleUtil.fermentingBales just like lines 120-144 below.
-- Fermenting bales objects (i3d file) need to have an "isFermentingBale" User Attribute as flag.

FermentingBale = {textSize=0.05, radius=5}

function FermentingBale:setNodeId(nodeId)
	if not self.isfermenting then
		self.isFermenting = getUserAttribute(nodeId, "isFermentingBale");
	end;
	if self.isFermenting then
		for _, bale in pairs(BaleUtil.fermentingBales) do
			local hasLoadedFermentation = self.loadedFillType and (bale.fillType == self.loadedFillType);
			if bale.fillType == self.fillType or hasLoadedFermentation then
				self.fermentingTarget = bale.target;
				self.fermentingMax = bale.ticks;
				if hasLoadedFermentation then
					self.fillType = self.loadedFillType;
					self.loadedFillType = false;
					break;
				end;
				if not (self.fermentingLoaded or hasLoadedFermentation) then
					self.fermentingDuration = bale.ticks;
					break;
				end;
			end;
		end;
		if self.loadedFillType then
			self.fillType = self.loadedFillType;
			self.fermentingLoaded = false;
		end;
	end;
end;
function FermentingBale:update(dt)
	if not self.fermentingTarget then
		return;
	end;
	if g_currentMission:getIsClient() and g_currentMission.controlledVehicle == nil and g_gui.currentGui == nil then
		local x,y,z = getWorldTranslation(g_currentMission.player.rootNode);
		local bx,by,bz = getWorldTranslation(self.nodeId);
		
		local distance = FermentingBale.euclideanDistance(x,y,z, bx,by,bz);
		if distance > FermentingBale.radius then
			return;
		end;
		local sx,sy,sz = project(bx,by,bz);
		local fillType = Fillable.fillTypeIndexToDesc[self.fillType].nameI18N;
		local target = Fillable.fillTypeIndexToDesc[self.fermentingTarget].nameI18N;
		local text = "";
		if self.fermentingDuration then
			local progress = string.format("%i%%", (1 - (self.fermentingDuration / self.fermentingMax)) * 100);
			text = string.format(g_i18n:getText("agp8x_ferment"), fillType, target, progress);
		else
			text = string.format(g_i18n:getText("agp8x_ferment_done"), fillType);
		end;
		setTextColor(0,0,0,1);
		setTextBold(true);
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
			self.fermentingDuration = -1;
			self.fermentingLoaded = false;
			FermentingBale.setNodeId(self, self.nodeId);
		end;
	end;
end;
function FermentingBale:getSaveAttributesAndNodes(nodeIdent, superFunc)
	local attributes, nodes = superFunc(self, nodeIdent);
	if self.isFermenting then
		attributes = attributes..' fermentingBale="true" fermentingDuration="'..tostring(self.fermentingDuration)..'" fillType="'..tostring(Fillable.fillTypeIndexToDesc[self.fillType].name)..'"';
	end;
	return attributes, nodes;
end;
function FermentingBale:loadFromAttributesAndNodes(xmlFile, key, resetVehicles, superFunc)
	local isFermenting = Utils.getNoNil(getXMLBool(xmlFile, key.."#fermentingBale"), false);
	if isFermenting then
		self.fermentingLoaded = true;
		self.fermentingDuration = getXMLInt(xmlFile, key.."#fermentingDuration");
		local fillTypeName = getXMLString(xmlFile, key.."#fillType");
		self.fillType = Fillable.fillTypeNameToInt[fillTypeName];
		self.loadedFillType = self.fillType;
	end;
	return superFunc and superFunc(self, xmlFile, key, resetVehicles) or BaseMission.VEHICLE_LOAD_OK;
end;
function FermentingBale.euclideanDistance(x0,y0,z0, x1,y1,z1)
	return math.sqrt((x1-x0)^2 + (y1-y0)^2 + (z1-z0)^2)
end;
function FermentingBale:readStream(streamId, connection)
	if self.isFermenting then
		self.fermentingTarget = streamReadInt8(streamId);
		self.fillType = streamReadInt8(streamId);
		self.fermentingMax = streamReadFloat32(streamId);
		self.fermentingDuration = streamReadFloat32(streamId);
	end;
end;
function FermentingBale:writeStream(streamId, connection)
	if self.isFermenting then
		streamWriteInt8(streamId, self.fermentingTarget);
		streamWriteInt8(streamId, self.fillType);
		streamWriteFloat32(streamId, self.fermentingMax);
		streamWriteFloat32(streamId, self.fermentingDuration);
	end;
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
	Bale.readStream = Utils.appendedFunction(Bale.readStream, FermentingBale.readStream);
	Bale.writeStream = Utils.appendedFunction(Bale.writeStream, FermentingBale.writeStream);
end;