--
-- allow bales for non-windrow fruitTypes
--
-- @author  agp8x <ls@agp8x.org>
-- @date  01.04.16
--

if not BaleUtil.nonWindrowExtension01042016 then
	local getBale_orig = BaleUtil.getBale;
	BaleUtil.getBale = function(fillType, width, height, length, diameter, isRoundbale)
		if FruitUtil.fillTypeToFruitType[fillType] ~= nil and FruitUtil.fruitIndexToDesc[FruitUtil.fillTypeToFruitType[fillType]].windrowName == nil then
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
	
	BaleUtil.nonWindrowExtension01042016 = true;
end;