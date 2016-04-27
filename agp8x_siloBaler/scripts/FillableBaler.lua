--
-- FillableBaler
-- Class for FillableBalers
--
-- @author  agp8x <ls@agp8x.org>
-- @date  01.04.16
--

FillableBaler = {};

function FillableBaler.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Baler, specializations);
end;
function FillableBaler:load(xmlFile)
	self.fillableBalerActive = Utils.getNoNil(getXMLBool(xmlFile, "vehicle.fillableBaler#active", true));
end;
function FillableBaler:delete()
end;
function FillableBaler:mouseEvent(posX, posY, isDown, isUp, button)
end;
function FillableBaler:keyEvent(unicode, sym, modifier, isDown)
end;
function FillableBaler:update(dt)
end;
function FillableBaler:updateTick(dt)
    if self:getIsActive() and self:getIsTurnedOn() and self.isServer then
		if self.fillableBalerActive then
			if self.baleUnloadAnimationName == nil and (self.fillLevel - self.lastFillLevel > 0) then
				-- move all bales
				local deltaTime = self:getTimeFromLevel(self.fillLevel - self.lastFillLevel);
				self:moveBales(deltaTime);
			end;
			self.lastFillLevel = self.fillLevel;
			if self.fillLevel >= self.capacity then
				local usedFillType = self.currentFillType;
				if self.baleTypes ~= nil then
					if self.baleAnimCurve ~= nil then
						local restDeltaFillLevel = 0;
						self:setFillLevel(restDeltaFillLevel, usedFillType);
						self:createBale(usedFillType, self.capacity);
						local numBales = table.getn(self.bales);
						local bale = self.bales[numBales];
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
function FillableBaler:draw()
end;