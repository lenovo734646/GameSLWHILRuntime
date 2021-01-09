
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, TextAsset, Sprite, Input, KeyCode = UnityEngine, GameObject, UnityEngine.TextAsset, UnityEngine.Sprite, UnityEngine.Input, UnityEngine.KeyCode
local GraphicRaycaster = UnityEngine.UI.GraphicRaycaster
local BadWordsReplace = CS.SP.BadWordsReplace

local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
local InfinityScroView = require'OSAScrollView.InfinityScroView'
local EmojiPanel = require"ChatRoot.EmojiPanel"
local PhrasePanel = require'ChatSystem.PhrasePanel'
local VoicePanel = require"ChatRoot.VoicePanel"
local ChatMsgData = require"ChatRoot.ChatMsgData"
local ChatMsgView = require 'ChatRoot.ChatMsgView'

_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel, loader, selfUserID)
    self.loader = loader
    self.selfUserID = selfUserID
    self.panel = panel
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    self.eventListener:Init(self)

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
    self.phrasePanel = PhrasePanel.create(self.phrasePanelGo, phrasePrefab)

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

function Class:OnSendVoice(clipData)
    if clipData == nil then
        logError("OnSendVoice clipData is null")
        return
    end
    if self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    self:OnSendMsg(nil, clipData)
end

function Class:OnSendText(inputField)
    local text = inputField.text
    if string.isNullOrEmpty(text) then
        return
    end
    if self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    text = self.badwordsReplace:Replace(text, "*")
    self:OnSendMsg(text, nil)
    -- to do send
    self.inputField.text = ""
end

function Class:OnSendMsg(text, clipData)

    local timeStampSec = os.time()
    
    
    -- 显示自己发送的信息
    local selfIcon = EditorAssetLoader.LoadEditorAsset("Assets/RareVoiceChat/Texture/r0.png", typeof(Sprite), true)
    self:OnReceiveMsg(timeStampSec, self.selfUserID, text, clipData, selfIcon)    
    -- 模拟他人的回复（测试）
    local otherIcon = EditorAssetLoader.LoadEditorAsset("Assets/RareVoiceChat/Texture/r1.png", typeof(Sprite), true)
    self:OnReceiveMsg(timeStampSec, 1, text, clipData, otherIcon)  

end

function Class:OnReceiveMsg(timeStampSec, userID, text, clipData, iconSpr)
    local isMine = false
    if userID == self.selfUserID then
        isMine = true
    end
    local audioClip = nil
    if clipData ~= nil then
        audioClip = self.voicePanel:ByteToAudioClip(clipData)
    end

    local msgData = ChatMsgData.Create(timeStampSec, userID, isMine, text, audioClip, iconSpr)
    self.msgScrollView:InsertItem(msgData)

end

function Class:ShowSendBtnByInput(inputField)
    if not string.isNullOrEmpty(self.inputField.text) then
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
    self.emojiPanel:OnShow(isOn)
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