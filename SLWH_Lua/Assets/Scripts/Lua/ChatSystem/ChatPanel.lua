
local _G, g_Env, print, log, LogE, os, math = _G, g_Env, print, log, LogE, os, math
local class, typeof, type, string, utf8, pairs= class, typeof, type, string, utf8, pairs

local tostring, tonumber = tostring, tonumber

local UnityEngine, GameObject, TextAsset, Sprite, Input, KeyCode = UnityEngine, GameObject, UnityEngine.TextAsset, UnityEngine.Sprite, UnityEngine.Input, UnityEngine.KeyCode
local GraphicRaycaster = UnityEngine.UI.GraphicRaycaster
local BadWordsReplace = CS.SP.BadWordsReplace

local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
local InfinityScroView = require'OSAScrollView.InfinityScroView'
local EmojiPanel = require"ChatSystem.EmojiPanel"
local PhrasePanel = require"ChatSystem.PhrasePanel"
local VoicePanel = require"ChatSystem.VoicePanel"
local ChatMsgData = require"ChatSystem.ChatMsgData"
local ChatMsgView = require 'ChatSystem.ChatMsgView'

local PBHelper = require 'protobuffer.PBHelper'
local CLCHATROOMSender = require'protobuffer.CLCHATROOMSender'

_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel, loader, selfUserID)
    self.loader = loader
    self.selfUserID = selfUserID
    self.panel = panel
    local initHelper = panel:GetComponent(typeof(LuaInitHelper))
    -- 音频播放器
    local sounds = {}
    initHelper:ObjectsSetToLuaTable(sounds)
    self.soundClips = {}
    for key, clip in pairs(sounds) do
        self.soundClips[clip.name] = clip
    end
    
    initHelper:Init(self)
    self.eventListener:Init(self)

    --
    self.faceSpr = self.loader.LoadEditorAsset("Assets/ChatSystem/Texture/r0.png", typeof(Sprite), true)

    --msg scroll view
    self.msgScrollView = InfinityScroView.Create(self.OSAScrollViewCom)
    self.msgScrollView.OSAScrollView.ChangeItemsCountCallback = function (_, changeMode, changedItemCount)
        if changeMode == ItemCountChangeMode.INSERT then    --插入则自动滚动到末尾
            local itemsCount = self.msgScrollView:GetItemsCount()
            local tarIndex = itemsCount-1
            local DoneFunc = function ()
                if itemsCount > 100 then                    -- 只保存100条数据
                    self.msgScrollView:RemoveOneFromStart(true)
                end
            end
            self.msgScrollView:SmoothScrollTo(tarIndex, 0.1, nil, DoneFunc)
        end
    end

    --itemRoot : RectTransform类型
    self.msgScrollView.OnCreateViewItemData = function (itemRoot, itemIndex)
        return ChatMsgView.Create(itemRoot)
    end

    self.msgScrollView.UpdateViewItemHandler = function (itemdata,index,viewItemData)
        viewItemData:UpdateFromData(itemdata)
        self.OSAScrollViewCom:ScheduleComputeTwinPass(true)
    end

    -- 敏感词屏蔽
    local badwordTextAsset = loader.LoadEditorAsset("Assets/ChatSystem/BadWord.txt", typeof(TextAsset));
    self.badwordsReplace = BadWordsReplace(badwordTextAsset.text)
    --emojiPanel 表情
    local emojis = loader.LoadEditorAssetAll("Assets/ChatSystem/Texture/Emoji/Emoji.png", true)
    local emojiPrefab = loader.LoadEditorAsset("Assets/ChatSystem/prefab/Item_Emoji.prefab", typeof(GameObject), true)
    self.emojiPanel = EmojiPanel.Create(self.emojiPanelGo, self.inputField, emojis, emojiPrefab)

    -- phrase 常用短语
    local phrasePrefab = loader.LoadEditorAsset("Assets/ChatSystem/prefab/Item_Phrase.prefab", typeof(GameObject), true)
    self.phrasePanel = PhrasePanel.Create(self.phrasePanelGo, phrasePrefab)
    self.phrasePanel.OnPhraseClickCallBack = function (phraseData)
        self:OnSendPhrase(phraseData)
    end

    -- 语音聊天
    -- 最长录音时间
    self.maxRecordTime = 60
    self.voicePanel = VoicePanel.Create(self.voicePanelGo, self.graphicRaycaster, self.maxRecordTime)
    self.voicePanel.onSendCallback = function (clipData)
        self:OnSendVoice(clipData)
    end

    --
    --self.inputField.shouldHideMobileInput = true--已在编辑器直接设置
    self.inputField.onSubmit:AddListener(function (str)
        --回车键
        self:OnSendText(self.inputField)
    end)

    self.inputField.onEndEdit:AddListener(function (str)
        --EndEdit
        self:ShowSendBtnByInput(self.inputField)
    end)

    self.inputField.onValueChanged:AddListener(function (str)
        self:ShowSendBtnByInput(self.inputField)
    end)

    self.btnSend.onClick:AddListener(function ()
        self:OnSendText(self.inputField)
    end)



    -- 消息监听
    PBHelper.AddListener('ChatMessageNtf', function (data)
        print("收到消息：userID = ", data.user_id, data.nickname, data.message_type, data.content, data.metadata)
        local timeStampSec = tonumber(data.metadata)
        --local faceSpr = GetHeadSprite(data.head)
        self:OnReceiveMsg(timeStampSec, data.user_id, data.message_type, data.content, data.metadata, faceSpr)
    end)
end

function Class:KeyControl()
    if Input:GetKeyDown(KeyCode.KeypadEnter) or Input:GetKeyDown(KeyCode.Return) then
        self:OnSendText(self.inputField)
    end
end

function Class:Update()
    self:KeyControl() --
    --安卓键盘高度同步

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
end

-- 发送文字
function Class:OnSendText(inputField)
    local text = inputField.text
    if string.IsNullOrEmpty(text) then
        return
    end
    if self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    text = self.badwordsReplace:Replace(text, "*")
    
    --
    print("发送文本消息：", text)
    local timeStampSec = os.time()
    -- 显示自己发送的信息
    self:OnReceiveMsg(timeStampSec, self.selfUserID, 1, text, nil, self.faceSpr)   
    --
    CLCHATROOMSender.Send_SendChatMessageReq(function (data)
        self:SendChatMsgAck(data)
    end,  1, text, tostring(timeStampSec))
    self.inputField.text = ""
end
-- 发送常用语
function Class:OnSendPhrase(phraseData)
    print("发送快捷消息：", phraseData.index)
    local timeStampSec = os.time()
    -- 显示自己发送的信息
    self:OnReceiveMsg(timeStampSec, self.selfUserID, 2, phraseData.index, nil, self.faceSpr)   
    --
    CLCHATROOMSender.Send_SendChatMessageReq(function (data)
        self:SendChatMsgAck(data)
    end,  2, tostring(phraseData.index), tostring(timeStampSec))
    -- 关闭界面
    self.tog_Phrase.isOn = false;
end

function Class:SendChatMsgAck(data)
    if data.errcode == 1 then
        print("发送消息失败：你不在房间中")
    elseif data.errcode == 2 then
        print("发送消息失败：发送内容太长")
    elseif data.errcode == 3 then
        print("发送消息失败：不支持的消息类型")
    end
end


-- msgType: 1文本消息 2语音消息 3快捷消息
function Class:OnReceiveMsg(timeStampSec, userID, msgType, content, metadata, headSpr)
    if content == nil then
        LogE("OnReceiveMsg: content is nil ")
        return
    end
    local isMine = false
    if userID == self.selfUserID then
        isMine = true
    end

    local index = -1
    local audioClip = nil
    if msgType == 3 then
        if content ~= nil then
            audioClip = self.voicePanel:ByteToAudioClip(content)
        end
    elseif msgType == 2 then
        if content ~= nil then
            index = tonumber(content)
            if index ~= nil then
                local data = self.phrasePanel:GetPhraseData(index)
                if data ~= nil then
                    content = data.content
                    self.audioSource:PlayOneShot(self.soundClips["game_chat_sound_"..index])
                else
                    LogE("获取快捷消息数据失败 index ="..index)
                    return
                end
            else
                LogE("快捷消息index 转换错误 content = "..content)
            end
        end
    end
    local msgData = ChatMsgData.Create(timeStampSec, userID, isMine, content, audioClip, headSpr)
    self.msgScrollView:InsertItem(msgData)

end

function Class:ShowSendBtnByInput(inputField)
    if not string.IsNullOrEmpty(self.inputField.text) then
        self.btnSend.gameObject:SetActive(true)
    else
        self.btnSend.gameObject:SetActive(false)
    end
end


-- 以下代码为自动生成代码
function Class:On_tog_Emoji_Event(tog_Emoji)
    local isOn = tog_Emoji.isOn
    --
    if isOn and self.tog_Phrase.isOn then
        self.tog_Phrase.isOn = false
    end
    if isOn and self.tog_Voice.isOn then
        self.tog_Voice.isOn = false
    end
    --
    self.emojiPanel:OnShow(isOn)
end

function Class:On_tog_Phrase_Event(tog_Phrase)
    local isOn = tog_Phrase.isOn
    --
    if isOn and self.tog_Voice.isOn then
        self.tog_Voice.isOn = false
    end
    if isOn and self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    --
    self.phrasePanel:OnShow(isOn)
end

function Class:On_tog_Voice_Event(tog_Voice)
    local isOn = tog_Voice.isOn
    --
    if isOn and self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    if isOn and self.tog_Phrase.isOn then
        self.tog_Phrase.isOn = false
    end
    --
    if self.btnSend.gameObject.activeSelf then
        self.btnSend.gameObject:SetActive(false)
    end
    self.voicePanel:OnShow(isOn)
end




return _ENV