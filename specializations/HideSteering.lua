--
-- HideSteering
--
-- @author  agp8x (ls@agp8x.org)
-- @date  18.04.15
--
-- hides the steering wheel on indoor cameras (user request)

HideSteering = {};

function HideSteering.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Steerable, specializations);
end;

function HideSteering:load(xmlFile)
end;

function HideSteering:delete()
end;

function HideSteering:mouseEvent(posX, posY, isDown, isUp, button)
end;

function HideSteering:keyEvent(unicode, sym, modifier, isDown)
end;

function HideSteering:update(dt)
	if self.isEntered and self.isClient and self.cameras[self.camIndex].isInside then
		setVisibility(self.steering, false);
	else
		setVisibility(self.steering, true);
	end;
end;

function HideSteering:updateTick(dt)
end;

function HideSteering:draw()
end;
