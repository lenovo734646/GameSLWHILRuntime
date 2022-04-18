
local yield = coroutine.yield
--
local ROOM_NAME_PRIMARY = "初级"
local ROOM_NAME_INTERMEDIATE = "中级"
local ROOM_NAME_SENIOR = "高级"
local ROOM_NAME_VIP = "VIP"


local Class = class()

function Class.Create(...)
    return Class(...)
end
  -- 需要预留一个是否折叠同类房间的标记：比如 初级1234，四个房间，统一折叠成“初级房”
function Class:__init(ui, view, allRoomConfig, OnRoomSuccessCallback)
    self.ui = ui
    self.OnRoomSuccessCallback = OnRoomSuccessCallback
    local game_config = allRoomConfig.game_config
    -- 同类型房间是否重叠，同类型房间检索和玩家点击后的加入规则需确定
    local repeated_room = game_config.repeated_room 
    self.roomTypeList = {primary = {}, intermediate = {}, senior = {}, VIP = {}}
    -- 
    view:GetComponent(typeof(GS.LuaUnityEventListener)):Init(self)
    Log("allRoomConfig:", json.encode(allRoomConfig))
    for i = 1, #allRoomConfig.room_config_list, 1 do
        local roomConfig = allRoomConfig.room_config_list[i]
        Log("roomConfig:", json.encode(roomConfig))
        -- 房间折叠处理
        if repeated_room == 1 then -- 房间折叠处理统计房间
            if GF.string.Contains(roomConfig.room_name, ROOM_NAME_PRIMARY)  then
                roomConfig.room_name = ROOM_NAME_PRIMARY
                table.insert(self.roomTypeList.primary, roomConfig)
            elseif GF.string.Contains(roomConfig.room_name, ROOM_NAME_INTERMEDIATE) then
                roomConfig.room_name = ROOM_NAME_INTERMEDIATE
                table.insert(self.roomTypeList.intermediate, roomConfig)
            elseif GF.string.Contains(roomConfig.room_name, ROOM_NAME_SENIOR) then
                roomConfig.room_name = ROOM_NAME_SENIOR
                table.insert(self.roomTypeList.senior, roomConfig)
            elseif GF.string.Contains(roomConfig.room_name, ROOM_NAME_VIP) then
                roomConfig.room_name = ROOM_NAME_VIP
                table.insert(self.roomTypeList.VIP, roomConfig)
            end
        else -- 不折叠直接创建
            self:OnCreateRoom(roomConfig) 
        end
    end
    -- 折叠模式创建房间
    if repeated_room == 1 then
        if #self.roomTypeList.primary > 0 then
            self:OnCreateRoom(self.roomTypeList.primary[1], repeated_room, self.roomTypeList.primary)
        end
        if #self.roomTypeList.intermediate > 0 then
            self:OnCreateRoom(self.roomTypeList.intermediate[1], repeated_room, self.roomTypeList.intermediate)
        end
        if #self.roomTypeList.senior > 0 then
            self:OnCreateRoom(self.roomTypeList.senior[1], repeated_room, self.roomTypeList.senior)
        end
        if #self.roomTypeList.VIP > 0 then
            self:OnCreateRoom(self.roomTypeList.VIP[1], repeated_room, self.roomTypeList.VIP)
        end             
    end
    GG.CoroutineHelper.StartCoroutine(function ()
        GF.WaitForSeconds(0.1)
        ui.roomRootScrollView.horizontalNormalizedPosition = 0;
    end)
    -- 设置ScrollView 值

end

function Class:OnCreateRoom(roomConfig, repeated_room, roomTable)
    local ui = self.ui
    local roomGO = GS.Instantiate(ui.itemRoom, ui.roomRootScrollView.content)
    local roomData = {
        On_btn_Room_Event = function ()
            Log("点击房间 ID:", roomConfig.room_id, roomConfig.room_name)
            if self.OnRoomSuccessCallback then -- Main.lua 中的回调
                if repeated_room == 1 then-- 房间折叠
                    local _errmessage
                    -- 尝试进入房间
                    GG.CoroutineHelper.StartCoroutine(function ()
                        for key, roomCfg in pairs(roomTable) do
                            local dataAck
                            Log("尝试进入房间:", roomCfg.room_name, roomCfg.room_id)
                            GG.CLFQZSSender.Send_EnterRoomReq(function (data)
                                Log("尝试进入房间返回:", roomCfg.room_name, roomCfg.room_id)
                                dataAck = data
                            end, roomCfg.room_id)
                            while not dataAck do
                                yield()
                            end
                            -- 成功则进入，不成功尝试进入下一个
                            Log("尝试进入房间结束:", dataAck._errmessage)
                            _errmessage = dataAck._errmessage
                            if not _errmessage then
                                self.OnRoomSuccessCallback(dataAck)
                                _errmessage = nil
                                break
                            end
                        end
                        -- 如果所有房间都尝试失败，则弹窗
                        Log("所有房间尝试进入结束 _errmessage:", _errmessage)
                        if _errmessage then
                            _G.ShowErrMsgBoxAndExitGame(_errmessage)
                        end
                    end)
                else -- 房间不折叠
                    GG.CLFQZSSender.Send_EnterRoomReq(function (data)
                        if not data._errmessage then
                            self.OnRoomSuccessCallback(data)
                        else
                            _G.ShowErrMsgBoxAndExitGame(data._errmessage)
                        end
                    end, roomConfig.room_id)
                end
            end
        end,
    }
    roomGO:GetComponent(typeof(GS.LuaInitHelper)):Init(roomData)
    roomGO:GetComponent(typeof(GS.LuaUnityEventListener)):Init(roomData)
    roomData.textName.text = roomConfig.room_name
    if roomConfig.min_enter_score <= 0 then
        roomConfig.min_enter_score = 0
    end
    roomData.textMinEnterScore.text = tostring(roomConfig.min_enter_score)
end

-- 此函数自动生成
function Class:On_btn_Back_Event(btn_Back)
    if g_Env then
        g_Env.SubGameCtrl.Leave()
    else
        Log("点击选房界面退出按钮...")
    end
end

function Class:Release()

end

return Class