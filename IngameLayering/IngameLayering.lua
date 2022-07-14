local KEY_CONTROL = 0x11
local KEY_L = 0x4c
local TYPE_MASK = 0xff00000
local OUTFIT_VOUCHER_ITEM_ID = 0x04100B36

local gui_coroutine = nil
local function update_gui_coroutines()
    if not coroutine.resume(gui_coroutine) then
        log.info("coroutine end")
        gui_coroutine = nil
    end
end

local function getModelId(idVal)
    return sdk.get_managed_singleton("snow.data.ContentsIdDataManager")
        :getPlainWeaponData(idVal)
        :get_LocalBaseData()
        ._WeaponBaseData
        ._ModelId
end

local function getName(idVal)
    return sdk.get_managed_singleton("snow.data.ContentsIdDataManager")
        :getPlainWeaponData(idVal)
        :getName()
end

local function setModelId(weapon_data, new_id)
    weapon_data._HyakuryuModelId = new_id
end

local function error_message_coroutine(message)
    return coroutine.create(function()
        log.info(string.format("open error: %s", message))
        local gui_mgr = sdk.get_managed_singleton("snow.gui.GuiManager")
        gui_mgr:call(
            "setOpenInfo(System.String, snow.gui.GuiCommonInfoBase.Type, snow.gui.SnowGuiCommonUtility.Segment, System.Boolean, System.Boolean)"
            , message, 0x1, 0x32, false, false)

        coroutine.yield()

        while not gui_mgr:updateInfoWindow() do
            coroutine.yield()
        end
    end)
end

local function layering_coroutine(making_data)
    return coroutine.create(function()
        if not making_data:canMakeAsProcessNext() then
            return
        end

        local player = sdk.get_managed_singleton("snow.player.PlayerManager"):findMasterPlayer()
        local weapon_data = player._WeaponListDataCache:get_RefInventory()
        local current_model_id = getModelId(weapon_data._IdVal)

        local id_val = making_data:get_IdVal()
        local new_model_id = getModelId(id_val)
        if current_model_id & TYPE_MASK ~= new_model_id & TYPE_MASK then
            gui_coroutine = error_message_coroutine("You cannot layer another weapon type !")
            return
        end
        log.info("model id ok")

        local item_box = sdk.get_managed_singleton("snow.data.DataManager")._PlItemBox;
        local inventory_data = item_box:findInventoryData(OUTFIT_VOUCHER_ITEM_ID)
        local voucher_count = inventory_data._ItemCount._Num
        if inventory_data == nil or voucher_count == 0 then
            gui_coroutine = error_message_coroutine("You do not have any outfit vouchers")
            return
        end
        log.info("vouchers count:" .. voucher_count)

        local name = getName(id_val)
        local confirmation_string = string.format("Use 1 Outfit Voucher+ to layer %s onto your equipped weapon ?\n (Current amount of Outfit Voucher+: %d)"
            , name, voucher_count)
        log.info("confirmation_string:" .. confirmation_string)


        local guiMgr = sdk.get_managed_singleton("snow.gui.GuiManager")
        guiMgr:call(
            "setOpenYNInfo(System.String, snow.gui.GuiManager.YNInfoUIState, snow.gui.SnowGuiCommonUtility.Segment, System.Boolean, System.Boolean)"
            ,
            confirmation_string, 0, 0x32, false, false
        )

        coroutine.yield()
        local result = 2
        while result == 2 do
            result = guiMgr:updateYNInfoWindow(0xaa66032d)
            coroutine.yield()
        end
        if result == 0 then
            item_box:tryAddGameItem(inventory_data, OUTFIT_VOUCHER_ITEM_ID, -1)
            setModelId(weapon_data, new_model_id)
        end
        guiMgr:closeYNInfo()
    end)
end

local function is_key_down(key_id)
    local kb = sdk.call_native_func(
        sdk.get_native_singleton("via.hid.Keyboard"),
        sdk.find_type_definition("via.hid.Keyboard"),
        "get_Device")
    return kb:call("isTrigger", key_id)
end

sdk.hook(sdk.find_type_definition("snow.gui.fsm.smithy.GuiSmithyFsmWeaponMenuSelectAction"):get_method("update"),
    function(args)
        if gui_coroutine ~= nil then
            update_gui_coroutines()
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        if not (is_key_down(KEY_L)) then
            return
        end

        local gui_smithy_mgr = sdk.get_managed_singleton("snow.gui.fsm.smithy.GuiSmithyFsmManager")
        local making_data = gui_smithy_mgr:getSelectedWeaponMakingData()
        if not making_data then
            return
        end
        gui_coroutine = layering_coroutine(making_data)
    end,
    function(retval) end
)
