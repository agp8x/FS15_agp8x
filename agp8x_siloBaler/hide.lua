--
-- hide
-- Class for hiding
--
-- @author  agp8x <ls@agp8x.org>
-- @date  08/03/16
--

Hider = {};

function Hider.prerequisitesPresent(specializations)
    return true;
end;
function Hider:load(xmlFile)
	local i=0;
	while true do
		local key = string.format("vehicle.hides.hide(%d)", i);
		if not hasXMLProperty(xmlFile, key) then
            break;
        end;
		local index=getXMLString(xmlFile, key.."#index");
		if index ~=nil then
			local item = Utils.indexToObject(self.components, index);
			local show = Utils.getNoNil(getXMLBool(xmlFile, key.."#show"), false);
			setVisibility(item, show);
		end;
		i=i+1;
	end;
end;
function Hider:delete()
end;
function Hider:readStream(streamId, connection)
end;
function Hider:writeStream(streamId, connection)
end;
function Hider:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
end;
function Hider:getSaveAttributesAndNodes(nodeIdent)
end;
function Hider:mouseEvent(posX, posY, isDown, isUp, button)
end;
function Hider:keyEvent(unicode, sym, modifier, isDown)
end;
function Hider:update(dt)
end;
function Hider:updateTick(dt)
end;
function Hider:draw()
end;