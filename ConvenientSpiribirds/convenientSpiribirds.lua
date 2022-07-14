--- Configurations

local SPIRIBIRD_MULTIPLIER = 2


--- Plugin

local convenientSpiribird_modded_ids = {}

sdk.hook(
    sdk.find_type_definition("snow.data.EquipmentInventoryData"):get_method("getLvBuffCageData"),
    function(args) end,
    function(retval)
        local param = sdk.to_managed_object(retval)._Param
        local id = param._Id
        if convenientSpiribird_modded_ids[id] then
            return retval
        end
        convenientSpiribird_modded_ids[id] = true


        local arr = param._StatusBuffAddValue
        for i, obj in ipairs(arr:get_elements()) do
            local value = obj.mValue
            arr[i - 1] = sdk.create_uint32(value * SPIRIBIRD_MULTIPLIER)
        end

        return retval
    end
)

local next_stamina_max = 0.0
local next_player
sdk.hook(
    sdk.find_type_definition("snow.player.PlayerQuestBase"):get_method("calcLvBuffStamina"),
    function(args)
        local player = sdk.to_managed_object(args[2])
        local count = sdk.to_int64(args[3])

        next_stamina_max = count * 30.0
        next_player = player
    end,
    function(retval)
        next_player:calcStaminaMax(next_stamina_max, false)
    end
)
