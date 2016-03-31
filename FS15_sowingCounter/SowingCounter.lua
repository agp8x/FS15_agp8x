--
-- SowingCounter
-- Specialization for counting sowed hectars
--
-- @author:  	Manuel Leithner
-- @date:		23/10/12
-- @version:	v2.0
-- @history:	v2.0 - initial implementation
--              v2.1 - portation to sowing machines (by agp8x)
--
-- free for noncommerical-usage
--

SowingCounter = {};

local tc_directory = g_currentModDirectory;

function SowingCounter.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(SowingMachine, specializations);
end;

function SowingCounter:load(xmlFile)
	print("-- loading SowingCounter specialization");
	
	self.SowingCounter = {};
	self.SowingCounter.sessionHectars = 0;	
	self.SowingCounter.sessionHectarsSent = 0;
	self.SowingCounter.totalHectars = 0;
	self.SowingCounter.totalHectarsSent = 0;
		
	self.xPos = Utils.getNoNil(getXMLFloat(xmlFile,  "vehicle.SowingCounter#posX"), 0.5029);
	self.yPos = Utils.getNoNil(getXMLFloat(xmlFile,  "vehicle.SowingCounter#posY"), 0.05238);	
	self.scOverlay = Overlay:new("hudSCOverlay", Utils.getFilename("SowingCounter_hud.png", tc_directory), self.xPos, self.yPos, 0.2371, 0.039525);	
	
	self.SowingCounter.DirtyFlag = self:getNextDirtyFlag();
end;

function SowingCounter:delete()
end;

function SowingCounter:readStream(streamId, connection)
	local session = streamReadFloat32(streamId);
	local total = streamReadFloat32(streamId);
		
	self.SowingCounter.sessionHectars = session;
	self.SowingCounter.totalHectars = total;
	self.SowingCounter.sessionHectarsSent = self.SowingCounter.sessionHectars;
	self.SowingCounter.totalHectarsSent = self.SowingCounter.totalHectars;
end;

function SowingCounter:writeStream(streamId, connection)	
	streamWriteFloat32(streamId, self.SowingCounter.sessionHectars);
	streamWriteFloat32(streamId, self.SowingCounter.totalHectars);
end;

function SowingCounter:readUpdateStream(streamId, timestamp, connection)
    if connection:getIsServer() then
        if streamReadBool(streamId) then
			self.SowingCounter.sessionHectars = streamReadFloat32(streamId);
			self.SowingCounter.totalHectars = streamReadFloat32(streamId);
        end;
    end;
end;

function SowingCounter:writeUpdateStream(streamId, connection, dirtyMask)
    if not connection:getIsServer() then
        if streamWriteBool(streamId, bitAND(dirtyMask, self.SowingCounter.DirtyFlag) ~= 0) then
			streamWriteFloat32(streamId, self.SowingCounter.sessionHectarsSent);
			streamWriteFloat32(streamId, self.SowingCounter.totalHectarsSent);
        end;
    end;
end;

function SowingCounter:mouseEvent(posX, posY, isDown, isUp, button)
end;

function SowingCounter:keyEvent(unicode, sym, modifier, isDown)
end;

function SowingCounter:update(dt)
end;

function SowingCounter:updateTick(dt)
	local ha = self.lastSowingArea ;			
	self.SowingCounter.sessionHectars = self.SowingCounter.sessionHectars + ha;		
	self.SowingCounter.totalHectars = self.SowingCounter.totalHectars + ha;	
	
	if math.abs(self.SowingCounter.sessionHectars - self.SowingCounter.sessionHectarsSent) > 0.01 or math.abs(self.SowingCounter.totalHectars - self.SowingCounter.totalHectarsSent) > 0.01 then
		self:raiseDirtyFlags(self.SowingCounter.DirtyFlag);
		self.SowingCounter.sessionHectarsSent = self.SowingCounter.sessionHectars;
		self.SowingCounter.totalHectarsSent = self.SowingCounter.totalHectars;
	end;
end;

function SowingCounter:draw()
	local counterSession = math.floor(self.SowingCounter.sessionHectars*100) / 100;
	local counterTotal = math.floor(self.SowingCounter.totalHectars*10) / 10;
	local fullSession = math.floor(counterSession);
	local fullTotal = math.floor(counterTotal);
	local deciSession = math.floor((counterSession - fullSession)*100);
	if deciSession < 10 then
		deciSession = "0" .. deciSession;
	end;
	local deciTotal = math.floor((counterTotal - fullTotal)*10);
	
	self.scOverlay:render();
	setTextAlignment(RenderText.ALIGN_RIGHT);
	setTextBold(true);	
	setTextColor(0, 0, 0, 1);
    renderText(self.xPos+0.068, 			self.yPos + 0.008, 0.022, tostring(fullTotal) .. ",");
	renderText(self.xPos+0.059+0.2371/2, self.yPos + 0.008, 0.022, tostring(fullSession) .. ",");
	setTextColor(1,1,1,1);
	renderText(self.xPos+0.068, 			self.yPos + 0.010, 0.022, tostring(fullTotal) .. ",");
	renderText(self.xPos+0.059+0.2371/2, self.yPos + 0.010, 0.022, tostring(fullSession) .. ",");
	setTextColor(0, 0, 0, 1);
    renderText(self.xPos+0.077, 			  self.yPos + 0.008, 0.023, tostring(deciTotal));
	renderText(self.xPos+0.077 + 0.2371/2, self.yPos + 0.008, 0.023, tostring(deciSession));
	setTextColor(0.95,0,0,1);
	renderText(self.xPos+0.077, 			  self.yPos + 0.010, 0.023, tostring(deciTotal));
	renderText(self.xPos+0.077 + 0.2371/2, self.yPos + 0.010, 0.023, tostring(deciSession));
	setTextColor(0, 0, 0, 1);
    renderText(self.xPos+0.097, 			self.yPos + 0.008, 0.023, "ha");
	renderText(self.xPos+0.097+0.2371/2, self.yPos + 0.008, 0.023, "ha");
	setTextColor(1,1,1,1);
	renderText(self.xPos+0.097, 			self.yPos + 0.010, 0.023, "ha");
	renderText(self.xPos+0.097+0.2371/2, self.yPos + 0.010, 0.023, "ha");
	setTextAlignment(RenderText.ALIGN_LEFT);
end;

function SowingCounter:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	local totalHectars = Utils.getNoNil(getXMLFloat(xmlFile, key .. "#totalHectars"), self.SowingCounter.totalHectars);
	self.SowingCounter.totalHectars = totalHectars;
	
    return BaseMission.VEHICLE_LOAD_OK;
end;

function SowingCounter:getSaveAttributesAndNodes(nodeIdent)
	local attributes = 'totalHectars="' .. tostring(self.SowingCounter.totalHectars) ..'"';
	return attributes, nil;
end;

--SowingMachine.updateTick = Utils.appendedFunction(SowingCounter.updateTick, SowingMachine.updateTick);