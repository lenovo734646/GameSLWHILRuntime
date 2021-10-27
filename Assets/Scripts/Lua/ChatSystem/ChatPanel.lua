local _G, g_Env, print, log, LogE, os, math = _G, g_Env, print, log, LogE, os, math
local class, typeof, type, string, utf8, pairs = class, typeof, type, string, utf8, pairs
local LogW = LogW

local tostring, tonumber = tostring, tonumber
local table = table
local tinsert = table.insert
local tremove = table.remove

local UnityEngine, GameObject, TextAsset, Sprite, Input, KeyCode = UnityEngine, GameObject, UnityEngine.TextAsset,
    UnityEngine.Sprite, UnityEngine.Input, UnityEngine.KeyCode
local GraphicRaycaster = UnityEngine.UI.GraphicRaycaster
local UnityHelper = UnityHelper
local Permission = UnityEngine.Android.Permission
local UserAuthorization = UnityEngine.UserAuthorization

local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
local InfinityScroView = require 'OSAScrollView.InfinityScroView'
local EmojiPanel = require "ChatSystem.EmojiPanel"
local PhrasePanel = require "ChatSystem.PhrasePanel"
local VoicePanel = require "ChatSystem.VoicePanel"
local ChatMsgData = require "ChatSystem.ChatMsgData"
local ChatMsgView = require 'ChatSystem.ChatMsgView'

local PBHelper = require 'protobuffer.PBHelper'
local CLCHATROOMSender = require 'protobuffer.CLCHATROOMSender'
local Helpers = require 'LuaUtil.Helpers'

local SEnv = SEnv
local GameConfig = GameConfig
local _Ver = _Ver
-- local GetHeadSprite = SEnv.GetHeadSprite
-- local GetHeadFrameSprite = SEnv.GetHeadFrameSprite
-- print("GetHeadSprite = ", GetHeadSprite, SEnv.GetHeadSprite)
-- 
local isOpen = false -- 是否显示聊天窗口
local waitSendChatMsgViewList = {}

_ENV = moduledef {
    seenamespace = CS
}

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel, loader, userData)
    self.loader = loader
    self.panel = panel
    local initHelper = panel:GetComponent(typeof(LuaInitHelper))
    initHelper:Init(self)
    self.eventListener:Init(self)
    -- 音频播放器
    local sounds = {}
    initHelper:ObjectsSetToLuaTable(sounds)
    self.soundClips = {}
    for key, clip in pairs(sounds) do
        self.soundClips[clip.name] = clip
    end
    self.msgItemBGs = {}
    self.msgItemBGInitHelper:ObjectsSetToLuaTable(self.msgItemBGs)
    self.msgItemBGInitHelper = nil

    waitSendChatMsgViewList = {}
    -- 未读消息
    self.unReadMsgCount = 0
    --
    self.faceSpr = SEnv.GetHeadSprite(userData.headID)

    -- msg scroll view
    self.msgScrollView = InfinityScroView.Create(self.OSAScrollViewCom)
    self.msgScrollView.OSAScrollView.ChangeItemsCountCallback =
        function(_, changeMode, changedItemCount)
            if changeMode == ItemCountChangeMode.INSERT then -- 插入则自动滚动到末尾
                local itemsCount = self.msgScrollView:GetItemsCount()
                local tarIndex = itemsCount - 1
                local DoneFunc = function()
                    if itemsCount > 100 then -- 只保存100条数据
                        self.msgScrollView:RemoveOneFromStart(true)
                    end
                end
                self.msgScrollView:SmoothScrollTo(tarIndex, 0.1, nil, DoneFunc)
            end
        end

    -- itemRoot : RectTransform类型
    self.msgScrollView.OnCreateViewItemData = function(itemRoot, itemIndex)
        return ChatMsgView.Create(itemRoot)
    end

    self.msgScrollView.UpdateViewItemHandler = function(itemdata, index, viewItemData)
        viewItemData:UpdateFromData(itemdata)
        self.OSAScrollViewCom:ScheduleComputeTwinPass(true)
    end

    -- emojiPanel 表情
    local emojis = {}
    local emojiPicsPrefab = loader:Load("Assets/AssetsFinal/EmojiPics.prefab")
    emojiPicsPrefab:GetComponent(typeof(LuaInitHelper)):ObjectsSetToLuaTable(emojis)
    -- local emojis = loader:LoadAll("Assets/ChatSystem/Texture/Emoji/Emoji.png", typeof(Sprite), true)
    self.emojiPanel = EmojiPanel.Create(self.emojiPanelGo, self.inputField, emojis, self.Item_Emoji)

    -- phrase 常用短语
    self.phrasePanel = PhrasePanel.Create(self.phrasePanelGo, self.Item_Phrase)
    self.phrasePanel.OnPhraseClickCallBack = function(phraseData)
        self:OnSendPhrase(phraseData.index)
    end

    -- 语音聊天
    -- 最长录音时间
    self.maxRecordTime = 60
    self.voicePanel = VoicePanel.Create(self.voicePanelGo, self.canvas_graphicraycaster, self.maxRecordTime)
    self.voicePanel.onSendCallback = function(clipData)
        self:OnSendVoice(clipData)
    end

    -- 消息监听
    PBHelper.AddListener('CLCHATROOM.ChatMessageNtf', function(data)
        print("收到消息：userID = ", data.user_id, data.nickname, data.message_type, data.content, data.metadata)
        local timeStampSec = tonumber(data.metadata)
        local headSpr = SEnv.GetHeadSprite(data.head)
        --local headFrameSpr = SEnv.GetHeadFrameSprite(data.headFrameID) -- 协议暂时没有头像框字段
        self:OnReceiveMsg(timeStampSec, data.user_id, data.nickname, data.message_type, data.content, data.metadata, headSpr)
    end)

    -- 兼容大厅版本
    self.tog_Voice.gameObject:SetActive(false)
    if _Ver and _Ver._ver >= 0.983 then
        self.tog_Voice.gameObject:SetActive(true)
    end
    if g_Env == nil then
        self.tog_Voice.gameObject:SetActive(true)
    end
end

function Class:KeyControl()
    if Input.GetKeyDown(KeyCode.KeypadEnter) or Input.GetKeyDown(KeyCode.Return) then
        self:OnSendTextFromInputField(self.inputField)
    end
end

-- 发送语音
function Class:OnSendVoice(clipData)
    if clipData == nil then
        logError("OnSendVoice clipData is null")
        return
    end
    if self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    -- TODO:Send
    print("发送语音：", #clipData, clipData)
    local timeStampSec = os.time()
    local msgType = 2
    local audioClip = self.voicePanel:ByteToAudioClip(clipData)
    if audioClip == nil then
        LogE("音频数据转换 AudioClip 失败")
        return
    end
    print("语音长度:", audioClip.length)
    if audioClip.length <= 0.6 then
        LogW("音频时间过短 < 0.6")
        return
    end
    self:OnSendMsg(msgType, nil, timeStampSec, audioClip, clipData)
    --
    -- CoroutineHelper.StartCoroutineAuto(self.OSAScrollViewCom,function ()
    --     local data, err = CLCHATROOMSender.Send_QueryUploadUrlReq_Async(_G.ShowErrorByHintHandler)
    --     if err then
    --         LogE("请求语音上传链接错误:", err)
    --         return
    --     end
    --     local upload_url = data.upload_url
    --     local download_url = data.download_url
    --     print("语音上传链接请求成功上传链接:", upload_url..'\n下载链接：'..download_url)
    --     CoroutineHelper.StartCoroutineAuto(self.OSAScrollViewCom, function ()
    --         -- TODO: 显示正在发送提示
    --         local request = Helpers.WebRequestPut(upload_url, clipData)
    --         request:SendWebRequest()
    --         while (not request.isDone) do
    --             yield()
    --             --print("正在上传发送...")
    --         end
    --         if not string.IsNullOrEmpty(request.error) then
    --             _G.ShotHintMessage(_G._ERR_STR_(request.error))
    --             print("上传发送出错:", request.error)
    --             return
    --         end
    --         -- TODO: 上传完成 隐藏正在发送提示
    --         print("上传成功发送下载链接：", download_url)
    --         -- 发送完成 把下载地址返回给服务器
    --         self:OnSendMsg(msgType, download_url, timeStampSec, audioClip, clipData)
    --     end)
    -- end)
end

-- 发送文字
function Class:OnSendTextFromInputField(inputField)
    local text = inputField.text
    self.inputField.text = ""
    self:OnSendText(text)
end

function Class:OnSendText(text)
    if string.IsNullOrEmpty(text) or text == " " or text == '\n' or text == '\r' or text == '\t' or text == [[\u2000']] then
        return
    end
    if self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    --
    print("发送文本消息：", text)
    local timeStampSec = os.time()
    local msgType = 1
    self:OnSendMsg(msgType, text, timeStampSec, nil)
end

-- 发送常用语
function Class:OnSendPhrase(index)
    print("发送快捷消息：", index)
    local timeStampSec = os.time()
    local msgType = 3
    local content = tostring(index)
    --
    self:OnSendMsg(msgType, content, timeStampSec, nil)
    -- 关闭界面
    self.tog_Phrase.isOn = false;
end

-- 以 timeStampSec 时间戳为Key 对自己发送的消息做一个缓存，
-- 用来记录消息发送状态，发送完毕（OnReceiveMsg 接收到）之后删除
-- 发送错误用来重发
function Class:OnSendMsg(msgType, content, timeStampSec, audioClip, clipData)
    local playerRes = SEnv.playerRes
    local headSpr = SEnv.GetHeadSprite(playerRes.headID)
    local msgItemBgSpr = self:__GetMsgItemBGSpr(playerRes.selfUserID)
    local phraseIndex = -1
    if msgType == 3 then
        if content ~= nil then
            phraseIndex = tonumber(content)
            if phraseIndex ~= nil then
                local data = self.phrasePanel:GetPhraseData(phraseIndex)
                if data ~= nil then
                    content = data.content
                    self.audioSource:PlayOneShot(self.soundClips["game_chat_sound_" .. phraseIndex])
                else
                    LogE("获取快捷消息数据失败 index =" .. phraseIndex)
                    return
                end
            else
                LogE("快捷消息index 转换错误 content = " .. content)
                return
            end
        end
    end
    --
    local msgData = ChatMsgData.Create(msgType, timeStampSec, playerRes.selfUserID, playerRes.userName, true, content, audioClip, headSpr, msgItemBgSpr)
    if clipData then -- 保存音频二进制数据重发使用
        msgData.clipData = clipData
    end
    self.msgScrollView:InsertItem(msgData)
    local chatMsgView = self.msgScrollView:GetItemViewsHolderAtEnd()
    CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour,function ()
        while chatMsgView == nil do
            yield()
            print("获取 chatMsgView 中...")
            chatMsgView = self.msgScrollView:GetItemViewsHolderAtEnd()
        end

        print("获取 chatMsgView 成功... timeStampSec = ", timeStampSec)
        tinsert(waitSendChatMsgViewList, chatMsgView) -- 添加到等待发送列表
        -- 发送
        if msgType == 2 then    -- 音频发送
            if audioClip and clipData then
                CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour,function ()
                    local data, err = CLCHATROOMSender.Send_QueryUploadUrlReq_Async(_G.ShowErrorByHintHandler)
                    if err then
                        chatMsgView:OnSendFailed(err)
                        LogE("请求语音上传链接错误:", err)
                        return
                    end
                    local upload_url = data.upload_url
                    local download_url = data.download_url
                    print("语音上传链接请求成功上传链接:", upload_url..'\n下载链接：'..download_url)
                    CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour, function ()
                        -- TODO: 显示正在发送提示
                        local request = Helpers.WebRequestPut(upload_url, clipData)
                        request:SendWebRequest()
                        while (not request.isDone) do
                            yield()
                            chatMsgView:OnUpdateProgress(request.uploadProgress)
                        end
                        if not string.IsNullOrEmpty(request.error) then
                            _G.ShotHintMessage(_G._ERR_STR_(request.error))
                            print("上传发送出错:", request.error)
                            return
                        end
                        -- TODO: 上传完成 隐藏正在发送提示
                        print("上传成功发送下载链接：", download_url)
                        --self:OnReceiveMsg(111, 111, "111", 2, download_url, nil, headSpr)
                        -- 发送完成 把下载地址返回给服务器
                        CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour,function ()
                            CLCHATROOMSender.Send_SendChatMessageReq_Async(msgType, download_url, tostring(timeStampSec), _G.ShowErrorByHintHandler)
                        end)
                    end)
                end)
                
            else
                LogE("audioClip or clipData is nil")
                return
            end
        elseif msgType == 3 then
            CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour,function ()
                CLCHATROOMSender.Send_SendChatMessageReq_Async(msgType, tostring(phraseIndex), tostring(timeStampSec), _G.ShowErrorByHintHandler)
            end)
            --self:OnReceiveMsg(111, 111, "111", 3, tostring(phraseIndex), nil, headSpr)
        else
            CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour,function ()
                CLCHATROOMSender.Send_SendChatMessageReq_Async(msgType, content, tostring(timeStampSec), _G.ShowErrorByHintHandler)
            end)
            --self:OnReceiveMsg(111, 111, "111", 1, content, nil, headSpr)
        end
        return chatMsgView
    end)
    -- end
    
end

-- msgType: 1文本消息 2语音消息 3快捷消息
function Class:OnReceiveMsg(timeStampSec, userID, nickName, msgType, content, metadata, headSpr)
    print("OnReceiveMsg: msgTypee = ", msgType, content)
    if content == nil then
        LogE("OnReceiveMsg: content is nil ")
        return
    end
    if not isOpen then
        self.redDotTip:SetActive(true)
        self.unReadMsgCount = self.unReadMsgCount +1
        if self.unReadMsgCount > 99 then
            self.unReadMsgCount = 99
        end
        self:__SetUnReadmsgCount(self.unReadMsgCount)
    else
        if self.redDotTip.activeSelf then
            self.redDotTip:SetActive(false)
        end
        self:__SetUnReadmsgCount(0)

    end
    ---
    local isMine = self:__IsSelf(userID)
    if isMine then
        local chatMsgView = self:__GetWaitSendChatMsgView(timeStampSec)
        if chatMsgView ~= nil then 
            chatMsgView:OnSendSuccess()
        end
        return
    end


    local msgItemBgSpr = self:__GetMsgItemBGSpr(userID)
    --
    local index = -1
    local audioClip = nil
    if msgType == 2 then    -- 音频消息
        if content ~= nil then
            print("收到语音消息下载链接：", content)
            -- 下载语音消息
            CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour,function ()
                local request = Helpers.WebRequestGet(content)
                request:SendWebRequest()
                while (not request.isDone) do
                    yield()
                    -- TODO: 显示正在下载提示 和 下载进度
                    -- req.ui:SetTipText(_G._STR_ '正在同步...' .. floor2(request.downloadProgress * 100) .. '%')
                    --print("正在下载...")
                end
                if not string.IsNullOrEmpty(request.error) then
                    _G.ShotHintMessage(_G._ERR_STR_(request.error))
                    print("下载出错:", request.error)
                    return
                end
                local data = request.downloadHandler.data
                print("语音数据下载成功...", #data, data)
                -- 下载成功 转换成 audioClip
                audioClip = self.voicePanel:ByteToAudioClip(request.downloadHandler.data)
                --audioClip = self.voicePanel:ByteToAudioClip(content)
                print("语音数据转换成AudioClip:", audioClip.length)
                local msgData = ChatMsgData.Create(msgType, timeStampSec, userID, nickName, isMine, content, audioClip, headSpr, msgItemBgSpr)
                self.msgScrollView:InsertItem(msgData)
            end)
        end
    elseif msgType == 3 then
        if content ~= nil then
            index = tonumber(content)
            if index ~= nil then
                local data = self.phrasePanel:GetPhraseData(index)
                if data ~= nil then
                    content = data.content
                    self.audioSource:PlayOneShot(self.soundClips["game_chat_sound_" .. index])
                    local msgData = ChatMsgData.Create(msgType, timeStampSec, userID, nickName, isMine, content, audioClip, headSpr, msgItemBgSpr)
                    self.msgScrollView:InsertItem(msgData)
                else
                    LogE("获取快捷消息数据失败 index =" .. index)
                    return
                end
            else
                LogE("快捷消息index 转换错误 content = " .. content)
                return
            end
        end
    else
        local msgData = ChatMsgData.Create(msgType, timeStampSec, userID, nickName, isMine, content, audioClip, headSpr, msgItemBgSpr)
        self.msgScrollView:InsertItem(msgData)
    end
end

function Class:OnReceiveText()
    
end

function Class:OnReceiveAduioClip()
    
end

function Class:OnReceivePhrase()
    
end

function Class:ShowSendBtnByInput(inputField)
    -- print('inputField.text',inputField.text)
    if not string.IsNullOrEmpty(inputField.text) then
        self.btnSend.gameObject:SetActive(true)
    else
        self.btnSend.gameObject:SetActive(false)
    end
end
-- 消息重发
function Class:OnReSend(timestampSec)
    local chatMsgView = self:__GetWaitSendChatMsgView(timestampSec)
    if chatMsgView ~= nil then -- 本条删除，拿到元数据重新发一条一样的
        local msgData = chatMsgView.msgData
        if msgData then
            if msgData.msgType == 1 then -- 文本
                self:OnSendText(msgData.text)
            elseif msgData.msgType == 2 and msgData.clipData then -- 音频
                self:OnSendVoice(msgData.clipData)
            else    -- 快捷消息
                self:OnSendPhrase(msgData.text)
            end
        end
    else
        LogE("OnReSend 未找到时间戳为:"..timestampSec.."  的chatMsgView")
    end
end

function Class:__SetUnReadmsgCount(count)
    self.unReadMsgCount = count
    self.unReadMsgCountText.text = tostring(count)
end

function Class:__IsSelf(userID)
    if userID == SEnv.playerRes.selfUserID then
        return true
    end
    return false
end

-- 根据 userID 获取消息条目背景 自己或他人
function Class:__GetMsgItemBGSpr(userID)
    if self:__IsSelf(userID) then
        return self.msgItemBGs[2]
    end
    return self.msgItemBGs[1]
end

function Class:__GetWaitSendChatMsgView(timestampSec)
    local chatMsgView, index = table.Find(waitSendChatMsgViewList, function (v)
        return v.msgData.timestampSec == timestampSec
    end)
    if chatMsgView == nil then
        LogE("未找到时间戳为:"..timestampSec.."  的chatMsgView")
        return nil
    end
    -- 移出旧的
    tremove(waitSendChatMsgViewList, index)
    return chatMsgView
end


-- 以下代码为自动生成代码
function Class:On_tog_Emoji_Event(tog_Emoji)
    local isOn = tog_Emoji.isOn
    -- --
    -- if isOn and self.tog_Phrase.isOn then
    --     self.tog_Phrase.isOn = false
    -- end
    -- if isOn and self.tog_Voice.isOn then
    --     self.tog_Voice.isOn = false
    -- end
    -- --
    self.emojiPanel:OnShow(isOn)
end

function Class:On_tog_Phrase_Event(tog_Phrase)
    local isOn = tog_Phrase.isOn
    -- --
    -- if isOn and self.tog_Voice.isOn then
    --     self.tog_Voice.isOn = false
    -- end
    -- if isOn and self.tog_Emoji.isOn then
    --     self.tog_Emoji.isOn = false
    -- end
    -- --
    self.phrasePanel:OnShow(isOn)
end

function Class:On_tog_Voice_Event(tog_Voice)
    local isOn = tog_Voice.isOn
    -- --
    -- if isOn and self.tog_Emoji.isOn then
    --     self.tog_Emoji.isOn = false
    -- end
    -- if isOn and self.tog_Phrase.isOn then
    --     self.tog_Phrase.isOn = false
    -- end
    -- --
    if self.btnSend.gameObject.activeSelf then
        self.btnSend.gameObject:SetActive(false)
    end
    self.voicePanel:OnShow(isOn)
end

function Class:On_tog_ChatPanel_Event(tog_ChatPanel)
    if tog_ChatPanel.isOn then
        isOpen = true
        if self.redDotTip.activeSelf then
            self.redDotTip:SetActive(false)
        end
        self:__SetUnReadmsgCount(0)
        self.msgScrollView:Refresh()
        self.msgScrollView:SmoothScrollToEnd()
    else
        isOpen = false
    end
end

-- 响应onEndEdit和onValueChanged
function Class:On_msgInputField_Event(inputField)
    self:ShowSendBtnByInput(inputField)
end

function Class:On_btnSend_Event(btnSend)
    self:OnSendTextFromInputField(self.inputField)
end

function Class:OnCustumEvent(params)
    -- -- 回车键
    -- if params[0]=='msgInputField_onSubmit' then
    --     self:OnSendTextFromInputField(self.inputField)
    -- end
end

function Class:Release()
    self.inputField.onSubmit:RemoveAllListeners()
    self.inputField = nil

    self.emojiPanel:Release()
    self.emojiPanel = nil
    -- phrase 常用短语
    self.phrasePanel:Release()
    self.phrasePanel.OnPhraseClickCallBack = nil
    self.phrasePanel = nil

    self.voicePanel.onSendCallback = nil
    self.voicePanel:Release()
    self.voicePanel = nil

    self.msgScrollView.OSAScrollView.ChangeItemsCountCallback = nil
    self.msgScrollView.OnCreateViewItemData = nil
    self.msgScrollView.UpdateViewItemHandler = nil
    self.msgScrollView:Release()
    self.msgScrollView = nil

end

function Class:OnDestroy()
    print("ChatPanel OnDestroy")
    self:Release()
end

return _ENV
