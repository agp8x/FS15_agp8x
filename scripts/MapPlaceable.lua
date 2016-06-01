-- Build placeables into map
-- agp8x
-- 08.05.2016

-- UserAttributes:
-- onCreate: <mapName>.onCreatePlaceable
-- xmlFile: <path-to-xml>

--[[
    <UserAttribute nodeId="361367">
      <Attribute name="onCreate" type="scriptCallback" value="myMap.onCreatePlaceable"/>
      <Attribute name="xmlFilename" type="string" value="Karlsdom/Karlsdom.xml"/>
    </UserAttribute>
]]

MapPlaceable = {};
local dir = g_currentModDirectory;

function onCreatePlaceable(self, id)
	local xmlFileName = getUserAttribute(id, "xmlFilename");
	if not xmlFileName then
		print("ERROR: no xmlFile for MapPlacable node ", getName(id));
		return;
	end;
	local xmlFileName = Utils.getFilename(xmlFileName, dir);
	local instance = ChurchClock:new(BaseMission.getIsServer(), BaseMission.getIsClient(), nil);
	local x,y,z = getTranslation(id);
	local rx,ry,rz = getRotation(id);
	instance:load(xmlFileName, x,y,z, rx,ry,rz, false);
	instance:finalizePlacement()
	g_currentMission:addOnCreateLoadedObject(instance);
	instance:register(true);
end;
