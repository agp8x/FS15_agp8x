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
	self.setPickupState_orig = self.setPickupState;
	self.setPickupState = SiloBaler.setPickupState;
	self.pickup=Utils.indexToObject(self.components,getXMLString(xmlFile,"vehicle.pickup#index"));
    
	self:switchWorkstate(0);--0: silobaling; 1:normal
	
	local i=0;
	while true do
		local key = string.format("vehicle.extraBales.bale(%d)", i);
		if not hasXMLProperty(xmlFile, key) then
            break;
        end;
		local fillType=getXMLString(xmlFile, key.."#fillType");
		local filename=getXMLString(xmlFile, key.."#filename");
		if fillType ~=nil and filename ~=nil then
			local isRoundBale = Utils.getNoNil(getXMLBool(xmlFile, key.."#isRoundBale"), false);
			local width = Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, key.."#width"), 1.2), 2);
			local height = Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, key.."#height"), 0.9), 2);
			local length = Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, key.."#length"), 2.4), 2);
			local diameter = Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, key.."#diameter"), 1.8), 2);
			local key = BaleUtil.getBaleKey(fillType, width, height, length, diameter, isRoundbale);
			if BaleUtil[key]==nil then
				BaleUtil.registerBaleType(filename, fillType, width, height, length, diameter, isRoundbale);
			end;
		end;
		i=i+1;
		end;
end;
function SiloBaler:delete()
end;
function SiloBaler:readStream(streamId, connection)
end;
function SiloBaler:writeStream(streamId, connection)
end;
function SiloBaler:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
    local state = Utils.getNoNil(getXMLInt(xmlFile, key.."#workstate"),0);
	self:switchWorkstate(state);
    return BaseMission.VEHICLE_LOAD_OK;
end;
function SiloBaler:getSaveAttributesAndNodes(nodeIdent)
    local nodes = "";
	attributes = 'workstate="'..self.workstate..'"';
    return attributes,nodes;
end;
function SiloBaler:mouseEvent(posX, posY, isDown, isUp, button)
end;
function SiloBaler:keyEvent(unicode, sym, modifier, isDown)
end;
function SiloBaler:update(dt)
    if self:getIsActiveForInput() then
        if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA3) and not self:getIsTurnedOn() then
            if self.workstate==0 then
				self:switchWorkstate(1);
			else
				self:switchWorkstate(0);
			end;
			--print("workstate changed to"..self.workstate);
        end;
    end;
end;
function SiloBaler:updateTick(dt)
    if self:getIsActive() and self.isTurnedOn and self.isServer then
		if self.workstate==0 then
			--SILOBALING
			if self.baleUnloadAnimationName == nil and self.fillLevel-self.lastFillLevel>0 then
				-- move all bales
				local deltaTime = self:getTimeFromLevel(self.fillLevel-self.lastFillLevel);
				self:moveBales(deltaTime);
			end;
			self.lastFillLevel=self.fillLevel
			if self.fillLevel >= self.capacity then
				local usedFillType=self.currentFillType;
				if self.baleTypes ~= nil then
					if self.baleAnimCurve ~= nil then
						local restDeltaFillLevel = 0
						self:setFillLevel(restDeltaFillLevel, usedFillType);
						self:createBale(usedFillType, self.capacity);
						local numBales = table.getn(self.bales);
						local bale = self.bales[numBales]
						self:moveBale(numBales, self:getTimeFromLevel(restDeltaFillLevel), true);
						-- note: self.bales[numBales] can not be accessed anymore since the bale might be dropped already
						g_server:broadcastEvent(BalerCreateBaleEvent:new(self, usedFillType, bale.time), nil, nil, self);
					elseif self.baleUnloadAnimationName ~= nil then
						self:createBale(usedFillType, self.capacity);
						g_server:broadcastEvent(BalerCreateBaleEvent:new(self, usedFillType, 0), nil, nil, self);
					end;
				end;
			end;
		end;
	end;
end;
function SiloBaler:draw()
    if self.isClient then
        if self:getIsActiveForInput(true) and not self:getIsTurnedOn() then
			g_currentMission:addHelpButtonText(g_i18n:getText("agp8x_change_workstate"), InputBinding.IMPLEMENT_EXTRA3);
			g_currentMission:addExtraPrintText(g_i18n:getText("agp8x_workstate").."  "..g_i18n:getText("agp8x_workstate"..self.workstate));
        end
    end;
end;
function SiloBaler:onTurnedOn(noEventSend)
	if self.workstate==0 then
		self.allowFillFromAir=true;
	end;
end;
function SiloBaler:onTurnedOff(noEventSend)
	if self.workstate==0 then
		self.allowFillFromAir=false;
	end;
end;
function SiloBaler:switchWorkstate(newState)
	--0: silobaling; 1:normal
	if newState ~= self.workstate and not self:getIsTurnedOn() then
		if newState==1 then
			self.workstate=1;
			setVisibility(self.pickup, true);
			self.allowFillFromAir=false;
		else
			self:setPickupState_orig(false);
			self.workstate=0;
			setVisibility(self.pickup, false);
			self.lastFillLevel=self.fillLevel;
		end;
	end;
end;
function SiloBaler:setPickupState(isLowered, noEvent)
	if self.workstate~=0 then
		self:setPickupState_orig(isLowered, noEvent);
	end;
end;

local getBale_orig = BaleUtil.getBale;
local allowPickup_orig= Baler.allowPickingUp;

function BaleUtil.getBale(fillType, width, height, length, diameter, isRoundbale)
	if FruitUtil.fillTypeToFruitType[fillType] == nil or FruitUtil.fruitIndexToDesc[FruitUtil.fillTypeToFruitType[fillType]].windrowName == nil then
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
function Baler.allowPickingUp(self, superFunc)
	if self.workstate==0 then
		return false;
	end;
	return allowPickup_orig(self, superFunc);
end;