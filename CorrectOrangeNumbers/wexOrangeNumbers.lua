
local next_arg
sdk.hook(
    sdk.find_type_definition("snow.enemy.EnemyUtility"):get_method("getHitUIColorType"),
    function(args)
        next_arg = sdk.to_managed_object(args[2])
    end,

    function(retval)
        local calcParam = next_arg._CalcParam
        local ownerType = calcParam:get_OwnerType()
        if ownerType ~= 3 and ownerType ~= 4 then
            return retval
        end
        local calcType = calcParam:get_CalcType()
        if calcType ~= 0 and calcType ~= 1 then
            return retval
        end
        if calcParam:get_PhysicalMeatAdjustRate() > 0.445 then
            return sdk.to_ptr(0x1)
        else
            return sdk.to_ptr(0x0)
        end
    end
)