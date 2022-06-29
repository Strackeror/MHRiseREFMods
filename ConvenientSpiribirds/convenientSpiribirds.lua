

--- Configurations

local SPIRIBIRD_MULTIPLIER = 3


--- Plugin

local modded_ids = {}
sdk.hook(
    sdk.find_type_definition("snow.data.EquipmentInventoryData"):get_method("getLvBuffCageData"),
    function(args) end,
    function(retval)
        local buffCageData = sdk.to_managed_object(retval)
        local param = buffCageData:get_field("_Param")
        local id = param:get_field("_Id")
        if  modded_ids[id] then
            return retval
        end

        
        local arr = param:get_field("_StatusBuffAddValue")
        
        for i, obj in ipairs(arr:get_elements()) do
            local value = obj:get_field("mValue")
            
            arr[i - 1] = sdk.create_uint32(value * SPIRIBIRD_MULTIPLIER)
        end
        
        modded_ids[id] = true
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

        local staminaMax = player:get_field("_refPlayerData"):get_field("_staminaMax")
        next_stamina_max = count * 30.0
        next_player = player
    end,
    function(retval)
        next_player:call("calcStaminaMax", next_stamina_max, false)
    end
)

