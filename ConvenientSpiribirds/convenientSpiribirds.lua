

--- Configurations

local SPIRIBIRD_MULTIPLIER = 3


--- Plugin

sdk.hook(
    sdk.find_type_definition("snow.gui.define.EquipDetailParamShortcut"):get_method("createLvBuffDataParam(snow.data.NormalLvBuffCageData)"),
    function (args)
    end,
    function (retval)
        local param = sdk.to_managed_object(retval)
        local arr = param:get_field("statusBuffAddVal")
        for i, obj in ipairs(arr:get_elements()) do
            local value = obj:get_field("mValue")
            local new_value = value * SPIRIBIRD_MULTIPLIER

            arr[i - 1] = sdk.create_uint32(new_value)
        end
        
        return retval
    end
)

sdk.hook(
    sdk.find_type_definition("snow.data.EquipDataManager"):get_method("getStatusBuffAddVal"), 
    function(args) 
        last_args = sdk.to_float(args[4])
    end,
    function(retval)
        local value = sdk.to_int64(retval)
        return sdk.to_ptr(value * SPIRIBIRD_MULTIPLIER)
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

