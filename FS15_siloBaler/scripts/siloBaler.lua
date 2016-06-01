--
-- siloBaler
-- Class for siloBalers
--
-- @author  agp8x <ls@agp8x.org>
-- @date  14/01/15
--

SiloBaler = {};

function SiloBaler.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Fillable, specializations);
end;
function SiloBaler:load(xmlFile)
	self.switchWorkstate = SiloBaler.switchWorkstate;
	self.setPickupState = SiloBaler.setPickupState;
	self.allowPickingUp = SiloBaler.allowPickingUp;
	self.workstateDirty = self:getNextDirtyFlag();
	
	self.pickup = Utils.indexToObject(self.components,getXMLString(xmlFile,"vehicle.siloBaler#pickupIndex"));
	local state = Utils.getNoNil(getXMLBool(xmlFile, "vehicle.siloBaler#initialSilobaling"), true);
	self:switchWorkstate(state);
end;
function SiloBaler:delete()
end;
function SiloBaler:readStream(streamId, connection)
	self:switchWorkstate(streamReadBool(streamId));
end;
function SiloBaler:writeStream(streamId, connection)
	streamWriteBool(streamId, self.siloBaling);
end;
function SiloBaler:readUpdateStream(streamId, timestamp, connection)
	if streamReadBool(streamId) then
		self:switchWorkstate(streamReadBool(streamId));
	end;
end;
function SiloBaler:writeUpdateStream(streamId, connection, dirtyMask)
	if streamWriteBool(streamId, bitAND(dirtyMask, self.workstateDirty) ~= 0) then
		streamWriteBool(streamId, self.siloBaling);
	end;
end;
function SiloBaler:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
    local state = Utils.getNoNil(getXMLBool(xmlFile, key.."#workstate"), true);
	self:switchWorkstate(state);
    return BaseMission.VEHICLE_LOAD_OK;
end;
function SiloBaler:getSaveAttributesAndNodes(nodeIdent)
    local nodes = "";
	attributes = 'workstate="'..tostring(self.siloBaling)..'"';
    return attributes,nodes;
end;
function SiloBaler:mouseEvent(posX, posY, isDown, isUp, button)
end;
function SiloBaler:keyEvent(unicode, sym, modifier, isDown)
end;
function SiloBaler:update(dt)
    if self:getIsActiveForInput() then
        if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA4) then
			self:raiseDirtyFlags(self.workstateDirty);
			SiloBalerWorkstateEvent.sendEvent(self, not self.siloBaling)
            self:switchWorkstate(not self.siloBaling);
        end;
    end;
end;
function SiloBaler:updateTick(dt)
end;
function SiloBaler:draw()
    if self.isClient then
        if self:getIsActiveForInput(true) and not self:getIsTurnedOn() then
			local i = 0;
			if not self.siloBaling then
				i = 1;
			end;
			g_currentMission:addHelpButtonText(g_i18n:getText("agp8x_change_workstate")..": "..g_i18n:getText("agp8x_workstate"..i), InputBinding.IMPLEMENT_EXTRA4);
        end
    end;
end;
function SiloBaler:onTurnedOn(noEventSend)
	if self.siloBaling then
		self.allowFillFromAir = true;
	end;
end;
function SiloBaler:onTurnedOff(noEventSend)
	self.allowFillFromAir = false;
end;
function SiloBaler:switchWorkstate(newState)
	if newState ~= self.siloBaling and not self:getIsTurnedOn() then
		self.siloBaling = newState;
		self.fillableBalerActive = newState;
		setVisibility(self.pickup, not newState);
		if newState then
			self:setPickupState(false);
			self.lastFillLevel = self.fillLevel;
		else
			self.allowFillFromAir = false;
		end;
	end;
end;
function SiloBaler:setPickupState(isLowered, noEvent)
	if not self.siloBaling then
		Pickup.setPickupState(self, isLowered, noEvent);
	end;
end;

function SiloBaler:allowPickingUp(superFunc)
	if self.siloBaling then
		return false;
	end;
	return Baler.allowPickingUp(self, superFunc);
end;

--EVENT

SiloBalerWorkstateEvent = {};
SiloBalerWorkstateEvent_mt=Class(SiloBalerWorkstateEvent, Event);

InitEventClass(SiloBalerWorkstateEvent, "SiloBalerWorkstateEvent");

function SiloBalerWorkstateEvent:emptyNew()
	local self = Event:new(SiloBalerWorkstateEvent_mt);
	return self;
end;

function SiloBalerWorkstateEvent:new(object, newState)
	local self = SiloBalerWorkstateEvent:emptyNew()
	self.object = object;
	self.newState = newState;
	return self;
end;
function SiloBalerWorkstateEvent:readStream(streamId, connection)
	self.object = networkGetObject(streamReadInt32(streamId));
	self.newState = streamReadBool(streamId);
	self:run(connection);
end;
function SiloBalerWorkstateEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, networkGetObjectId(self.object));
	streamWriteBool(streamId, self.newState);
end;
function SiloBalerWorkstateEvent:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(SiloBalerWorkstateEvent:new(self.object, self.newState), nil, connection, self.object);
	end;
	self.object:switchWorkstate(self.newState)
end;
function SiloBalerWorkstateEvent.sendEvent(vehicle, newState, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SiloBalerWorkstateEvent:new(vehicle, newState), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(SiloBalerWorkstateEvent:new(vehicle, newState));
		end;
	end;
end;
