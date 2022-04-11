
-- 聊天界面
Log("ChatPanel使用小游戏自带脚本.....")
local yield = coroutine.yield
--
local isOpen = false -- 是否显示聊天窗口
local waitSendChatMsgViewList = {}
local waitSendChatMsgView = nil

local CoroutineMonoBehaviour = nil
local InActiveMsgDataList = {} -- 未显示的聊天数据


local Class = class()

function Class.Create(...)
    return Class(...)
end

function Class:__init(panel, loader, playerRes, coMonoBehaviour)
    -- local 变量初始化
    isOpen = false -- 是否显示聊天窗口
    waitSendChatMsgViewList = {}
    waitSendChatMsgView = nil

    CoroutineMonoBehaviour = nil
    InActiveMsgDataList = {} -- 未显示的聊天数据
    --
    self.loader = loader
    self.panel = panel
    self.playerRes = playerRes
    local initHelper = panel:GetComponent(typeof(GS.LuaInitHelper))
    initHelper:Init(self)
    self.eventListener:Init(self)
    CoroutineMonoBehaviour = coMonoBehaviour
    -- 音频播放器
    -- local sounds = {}
    -- initHelper:ObjectsSetToLuaTable(sounds)
    -- self.soundClips = {}
    -- for key, clip in pairs(sounds) do
    --     self.soundClips[clip.name] = clip
    -- end
    self.msgItemBGs = {}
    self.msgItemBGInitHelper:ObjectsSetToLuaTable(self.msgItemBGs)
    self.msgItemBGInitHelper = nil

    waitSendChatMsgViewList = {}
    -- 未读消息
    self.unReadMsgCount = 0
    --
    self.faceSpr = SEnv.GetHeadSprite(playerRes.headID)
    Log("chatPanel init = ", self)
    -- msg scroll view
    self.msgScrollView = GG.InfinityScroView.Create(self.OSAScrollViewCom)
    self.msgScrollView.OSAScrollView.ChangeItemsCountCallback =
        function(_, changeMode, changedItemCount)
            if changeMode == GS.ItemCountChangeMode.INSERT then -- 插入则自动滚动到末尾
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
        return GG.ChatMsgView.Create(itemRoot, self)
    end

    self.msgScrollView.UpdateViewItemHandler = function(itemdata, index, viewItemHoder)
        viewItemHoder:UpdateFromData(itemdata)
        self.OSAScrollViewCom:ScheduleComputeTwinPass(true)
        if itemdata.isMine then
            -- Log("更新自己发送的 ViewHolder...")
            waitSendChatMsgView = viewItemHoder
        end
    end

    -- emojiPanel 表情
    local emojis = {}
    local emojiPicsPrefab = loader:Load("Assets/AssetsFinal/EmojiPics.prefab")
    emojiPicsPrefab:GetComponent(typeof(GS.LuaInitHelper)):ObjectsSetToLuaTable(emojis)
    -- local emojis = loader:LoadAll("Assets/ChatSystem/Texture/Emoji/Emoji.png", typeof(GS.Sprite), true)
    self.emojiPanel = GG.EmojiPanel.Create(self.emojiPanelGo, self.inputField, emojis, self.Item_Emoji)

    -- phrase 常用短语
    self.phrasePanel = GG.PhrasePanel.Create(self.phrasePanelGo, self.Item_Phrase)
    self.phrasePanel.OnPhraseClickCallBack = function(phraseData)
        self:OnSendPhrase(phraseData.index)
    end

    -- 语音聊天
    -- 最长录音时间
    self.maxRecordTime = 60
    self.voicePanel = GG.VoicePanel.Create(self.voicePanelGo, self.canvas_graphicraycaster, self.maxRecordTime)
    self.voicePanel.onSendCallback = function(clipData, clipChannels, freq)
        self:OnSendVoice(clipData, clipChannels, freq)
    end

    -- 消息监听
    GG.PBHelper.AddListener('CLCHATROOM.ChatMessageNtf', function(data)
        Log("收到消息：userID = ", data.user_id, data.nickname, data.message_type, data.content, data.metadata)
        self:OnReceiveMsg(data.user_id, data.nickname, data.message_type, data.content, data.metadata, data.head)
    end)
    -- self.inputField.onTouchScreenKeyboardStatusChanged:RemoveAllListeners()
    -- self.inputField.onTouchScreenKeyboardStatusChanged:AddListener(function (status)
    --     Log("onTouchScreenKeyboardStatusChanged ", status)
    --     if status ~= TouchScreenKeyboard_Status.Visible then
            
    --         -- self.inputField.onSubmit()
    --     end
    -- end)

    -- 兼容大厅版本
    self.tog_Voice.gameObject:SetActive(true)
end

function Class:KeyControl()
    if GS.Input.GetKeyDown(GS.KeyCode.KeypadEnter) or GS.Input.GetKeyDown(GS.KeyCode.Return) then
        Log("键盘事件：Enter or Return...")
        self:OnSendTextFromInputField(self.inputField)
    end
end

-- 发送语音
function Class:OnSendVoice(clipData, clipChannels, freq)
    if clipData == nil then
        GF.logError("OnSendVoice clipData is null")
        return
    end
    if self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    -- TODO:Send
    Log("发送语音：", #clipData, clipChannels, freq)
    local timeStampSec = os.time()
    local msgType = 2
    local audioClip = self.voicePanel:ByteToAudioClip(clipData, clipChannels, freq)
    if audioClip == nil then
        LogE("音频数据转换 AudioClip 失败")
        return
    end
    Log("语音长度:", audioClip.length)
    if audioClip.length <= 0.6 then
        LogW("音频时间过短 < 0.6")
        return
    end
    self:OnSendMsg(msgType, nil, timeStampSec, audioClip, clipData, clipChannels, freq)
    --
end

-- 发送文字
function Class:OnSendTextFromInputField(inputField)
    local text = inputField.text
    self.inputField.text = ""
    self:OnSendText(text)
end

function Class:OnSendText(text)
    if GF.string.IsNullOrEmpty(text) or text == " " or text == '\n' or text == '\r' or text == '\t' or text == [[\u2000']] then
        return
    end
    if self.tog_Emoji.isOn then
        self.tog_Emoji.isOn = false
    end
    --
    Log("发送文本消息：", text)
    local timeStampSec = os.time()
    local msgType = 1
    self:OnSendMsg(msgType, text, timeStampSec, nil)
end

-- 发送常用语
function Class:OnSendPhrase(index)
    Log("发送快捷消息：", index)
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
function Class:OnSendMsg(msgType, content, timeStampSec, audioClip, clipData, clipChannels, freq)
    local playerRes = self.playerRes
    local headID = playerRes.headID
    local msgItemBgSpr = self:__GetMsgItemBGSpr(playerRes.selfUserID)
    local phraseIndex = -1
    if msgType == 3 then -- 快捷语音消息
        if content ~= nil then
            phraseIndex = tonumber(content)
            if phraseIndex ~= nil then
                local data = self.phrasePanel:GetPhraseData(phraseIndex)
                if data ~= nil then
                    content = data.content
                    local clip = GS.AudioManager.Instance:GetClipByName("game_chat_sound_" .. phraseIndex)
                    self:OnPlayAudioClip(clip)
                    -- self.audioSource:PlayOneShot(self.soundClips["game_chat_sound_" .. phraseIndex])
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
    local msgData = GG.ChatMsgData.Create(msgType, timeStampSec, playerRes.selfUserID, playerRes.userName, true, content, audioClip, headID, msgItemBgSpr)
    if clipData then -- 保存音频二进制数据重发使用
        msgData.clipData = clipData
    end
    waitSendChatMsgView = nil
    self.msgScrollView:InsertItem(msgData)
    GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour,function ()
        while waitSendChatMsgView == nil do
            yield()
            -- Log("获取 chatMsgView 中...")
        end

        -- Log("获取 chatMsgView 成功... timeStampSec = ", timeStampSec, waitSendChatMsgView.msgData.timestampSec, waitSendChatMsgView.msgData.text)
        table.insert(waitSendChatMsgViewList, waitSendChatMsgView) -- 添加到等待发送列表
        -- 发送
        if msgType == 2 then    -- 音频发送
            if audioClip and clipData then
                GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour,function ()
                    local data, err = GG.CLCHATROOMSender.Send_QueryUploadUrlReq_Async()
                    if err then
                        waitSendChatMsgView:OnSendFailed(err)
                        LogE("请求语音上传链接错误:", err)
                        return
                    end
                    local upload_url = data.upload_url
                    local download_url = data.download_url
                    Log("语音上传链接请求成功上传链接:", upload_url..'\n下载链接：'..download_url)
                    GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour, function ()
                        -- TODO: 显示正在发送提示
                        local request = GG.Helpers.WebRequestPut(upload_url, clipData)
                        request:SendWebRequest()
                        while (not request.isDone) do
                            yield()
                            waitSendChatMsgView:OnUpdateProgress(request.uploadProgress)
                        end
                        if not GF.string.IsNullOrEmpty(request.error) then
                            ShowTips(_G._ERR_STR_(request.error))
                            Log("上传发送出错:", request.error)
                            return
                        end
                        -- TODO: 上传完成 隐藏正在发送提示
                        Log("上传成功发送下载链接：", download_url)
                        -- 发送完成 把下载地址返回给服务器
                        local metadata = { timeStampSec = timeStampSec,  clipChannels = clipChannels, freq = freq}
                        local metadataJson = _G.json.encode(metadata)
                        --self:OnReceiveMsg(111, "111", 2, download_url, metadata, headID)
                        GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour,function ()
                            GG.CLCHATROOMSender.Send_SendChatMessageReq_Async(msgType, download_url, metadataJson)
                        end)
                    end)
                end)
                
            else
                LogE("audioClip or clipData is nil")
                return
            end
        elseif msgType == 3 then
            GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour,function ()
                GG.CLCHATROOMSender.Send_SendChatMessageReq_Async(msgType, tostring(phraseIndex), tostring(timeStampSec))
            end)
            --self:OnReceiveMsg(111, "111", 3, tostring(phraseIndex), 111, headID)
        else
            GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour,function ()
                GG.CLCHATROOMSender.Send_SendChatMessageReq_Async(msgType, content, tostring(timeStampSec))
            end)
            --self:OnReceiveMsg(111, "111", 1, content, 111, headID)
        end
        return waitSendChatMsgView
    end)
    -- end
    
end

-- msgType: 1文本消息 2语音消息 3快捷消息
function Class:OnReceiveMsg(userID, nickName, msgType, content, metadata, headID)
    Log("收到消息: chatPanel = ", self)
    -- Log("OnReceiveMsg: msgTypee = ", msgType, content)
    if content == nil then
        LogE("OnReceiveMsg: content is nil ")
        return
    end
    ---
    local timeStampSec, clipChannels, freq
    if msgType == 1 or msgType == 3 then
        timeStampSec = tonumber(metadata)
    else
        local metadata = _G.json.decode(metadata)
        timeStampSec = metadata["timeStampSec"]
        clipChannels = metadata["clipChannels"]
        freq = metadata["freq"]
        Log("解析元数据 timeStampSec = ", timeStampSec, clipChannels, freq)
    end
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
    local msgData
    if msgType == 2 then    -- 音频消息
        if content ~= nil then
            Log("收到语音消息下载链接：", content)
            -- 下载语音消息
            GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour,function ()
                local request = GG.Helpers.WebRequestGet(content)
                request:SendWebRequest()
                while (not request.isDone) do
                    yield()
                    -- TODO: 显示正在下载提示 和 下载进度
                    -- req.ui:SetTipText(_G._STR_ '正在同步...' .. floor2(request.downloadProgress * 100) .. '%')
                    --Log("正在下载...")
                end
                if not GF.string.IsNullOrEmpty(request.error) then
                    ShowTips(_G._ERR_STR_(request.error))
                    Log("下载出错:", request.error)
                    return
                end
                local data = request.downloadHandler.data
                Log("语音数据下载成功...", #data, data)
                -- 下载成功 转换成 audioClip
                audioClip = self.voicePanel:ByteToAudioClip(request.downloadHandler.data, clipChannels, freq)
                Log("语音数据转换成AudioClip:", audioClip.length)
                msgData = GG.ChatMsgData.Create(msgType, timeStampSec, userID, nickName, isMine, content, audioClip, headID, msgItemBgSpr)
                self:ProcessPanelInactive(msgData) -- 要等协程返回，不能放函数最后统一处理，不然等不到协程结果
            end)
        end
    elseif msgType == 3 then
        if content ~= nil then
            index = tonumber(content)
            if index ~= nil then
                local data = self.phrasePanel:GetPhraseData(index)
                if data ~= nil then
                    content = data.content
                    if isOpen then
                        local clip = GS.AudioManager.Instance:GetClipByName("game_chat_sound_" .. index)
                        self:OnPlayAudioClip(clip)
                    end
                    msgData = GG.ChatMsgData.Create(msgType, timeStampSec, userID, nickName, isMine, content, audioClip, headID, msgItemBgSpr)
                    self:ProcessPanelInactive(msgData)
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
        msgData = GG.ChatMsgData.Create(msgType, timeStampSec, userID, nickName, isMine, content, audioClip, headID, msgItemBgSpr)
        self:ProcessPanelInactive(msgData)
    end
end

function Class:ProcessPanelInactive(msgData)
    if not msgData then
        return
    end
    if not isOpen then
        self.redDotTip:SetActive(true)
        self.unReadMsgCount = self.unReadMsgCount +1
        if self.unReadMsgCount > 99 then
            self.unReadMsgCount = 99
        end
        self:__SetUnReadmsgCount(self.unReadMsgCount)
        table.insert(InActiveMsgDataList, msgData) -- 界面未打开，暂时把消息数据存起来
        Log("msg.Type = ", msgData.msgType, "数量：", #InActiveMsgDataList, "audioClip = ", msgData.audioClip)
    else
        if self.redDotTip.activeSelf then
            self.redDotTip:SetActive(false)
        end
        self:__SetUnReadmsgCount(0)
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
    -- Log('inputField.text',inputField.text)
    if not GF.string.IsNullOrEmpty(inputField.text) then
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
    if userID == self.playerRes.selfUserID then
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
    local chatMsgView, index = GF.table.Find(waitSendChatMsgViewList, function (v)
        -- Log("v.timestampSec = ", v.msgData.timestampSec, " target = ", timestampSec)
        return v.msgData.timestampSec == timestampSec
    end)
    if chatMsgView == nil then
        LogE("未找到时间戳为:"..timestampSec.."  的chatMsgView")
        return nil
    end
    -- 移出旧的
    table.remove(waitSendChatMsgViewList, index)
    return chatMsgView
end
-- 当游戏状态发生变化时取消输入状态，主要是取消语音输入
function Class:OnCancelInput()
    self.voicePanel:CancelVoiceInput()
    self.inputField.onEndEdit:Invoke(self.inputField.text)
end

local curPlayClip
local curwfDraw
local isPlayingAudioClip
local musicMute = false
local audioMute = false
local curPlayCO
function Class:OnPlayAudioClip(clip, wfDraw)
    if not clip then
        LogE("clip is nil")
        return
    end
    -- 
    if curPlayClip then
        self:OnStopAudioClip(curwfDraw)
    end
    
    if curPlayClip ~= clip then
        -- 音乐音效状态记录
        if not GS.AudioManager.Instance.MusicAudio.mute then
            GS.AudioManager.Instance.MusicAudio.mute = true
            musicMute = false
        else
            musicMute = true
        end
        if not GS.AudioManager.Instance.EffectAudio.mute then
            GS.AudioManager.Instance.EffectAudio.mute = true
            audioMute = false
        else
            audioMute = true
        end
        --
        curPlayClip = clip
        curwfDraw = wfDraw
        isPlayingAudioClip = true
        self.audioSource.clip = clip
        self.audioSource:Play()
        local clipChannels = clip.channels
        -- 协程等待播放结束
        curPlayCO = GG.CoroutineHelper.StartCoroutine(function ()
            -- if not isPlayingAudioClip then
            --     return
            -- end
            while isPlayingAudioClip do
                yield()
                if curwfDraw then
                    curwfDraw.playbackSli.value = self.audioSource.timeSamples * clipChannels
                end
                if self.audioSource.isPlaying == false then
                    self:OnStopAudioClip(curwfDraw)
                    break
                end
            end
        end)
    --
    end
end

function Class:OnStopAudioClip(wfDraw)
    self.audioSource:Stop()
    self.audioSource.clip = nil
    if wfDraw then
        wfDraw.playbackSli.value = 0
        curwfDraw = nil
    end
    
    curPlayClip = nil
    isPlayingAudioClip = nil
    -- 恢复声音
    GS.AudioManager.Instance.MusicAudio.mute = musicMute
    GS.AudioManager.Instance.EffectAudio.mute = audioMute
    isPlayingAudioClip = false
    if curPlayCO then
        GG.CoroutineHelper.StopCoroutine(curPlayCO)
        curPlayCO = nil
    end
end


-- 以下代码为自动生成代码
function Class:On_tog_Emoji_Event(tog_Emoji)
    local isOn = tog_Emoji.isOn
    -- --
    self.emojiPanel:OnShow(isOn)
end

function Class:On_tog_Phrase_Event(tog_Phrase)
    local isOn = tog_Phrase.isOn
    -- --
    self.phrasePanel:OnShow(isOn)
end

function Class:On_tog_Voice_Event(tog_Voice)
    local isOn = tog_Voice.isOn
    -- -- 权限检查
    if GS.UnityHelper.GetPlatform() == "Android" then
        if GS.UnityHelper.HasUserAuthorizedPermission and isOn == true then
            GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour, function ()
                self.voicePanel:RequestMicrophone()
                yield()
                local hasPermission = GS.UnityHelper.HasUserAuthorizedPermission("RECORD_AUDIO")
                if not hasPermission then
                    ShowTips(_G._STR_("录音需要麦克风权限，请手动打开麦克风权限"))
                    tog_Voice.isOn = false
                else
                    Log("已获取麦克风权限")
                    if self.btnSend.gameObject.activeSelf then
                        self.btnSend.gameObject:SetActive(false)
                    end
                    self.voicePanel:OnShow(isOn)
                end
            end)
        end
    else
        if self.btnSend.gameObject.activeSelf then
            self.btnSend.gameObject:SetActive(false)
        end
        self.voicePanel:OnShow(isOn)
    end
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
        --把隐藏的消息数据放出来
        GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour, function ()
            while #InActiveMsgDataList > 0 do
                if not isOpen then
                    break
                end
                local msgData = table.remove(InActiveMsgDataList, 1)
                Log("1111111111111111msgData.msgType = ", msgData.msgType, msgData.audioClip)
                self.msgScrollView:InsertItem(msgData)
                yield()
            end
        end)
    else
        isOpen = false
    end
end

-- 此函数响应的是onValueChanged事件
local spriteLen = 11
function Class:On_msgInputField_Event(inputField)
    local str = inputField.text
    local contentLimitLength = inputField.characterLimit
    --
    -- Log("onValueChanged:", str)
    if string.len(str) > contentLimitLength then

        local tempStr = string.sub(str, 1, contentLimitLength)
        -- Log("0000 = ", tempStr);
        -- 如果最后是 <sprite=%d>被截断，则将截断的去掉
        local tStr = string.sub(tempStr, - spriteLen)
        -- Log("1111tStr = ", tStr, "tempStr = ", tempStr);
        tempStr = string.sub(tempStr, 1, string.len(tempStr)- spriteLen)
        -- Log("2222tStr = ",tStr, "tempStr = ",tempStr);
        if not GF.string.startswith(tStr, "<") or not GF.string.endswith(tStr,">") then
            local index = string.find(tStr, "<")
            if index ~= nil then
                tStr = string.sub(tStr, 1, index-1);
                -- Log("截断 tStr = ", tStr , "index = ", index);
            end
        end
        tempStr = tempStr .. tStr;
        -- Log("3333 = " , tempStr);
        inputField.text = tempStr;
    end
    --
    self:ShowSendBtnByInput(inputField)
end

function Class:On_btnSend_Event(btnSend)
    Log("发送按钮事件触发....")
    self:OnSendTextFromInputField(self.inputField)
end

function Class:OnCustumEvent(params)
    -- -- 回车键
    -- if params[0]=='msgInputField_onSubmit' then
    --     self:OnSendTextFromInputField(self.inputField)
    -- end
end

function Class:OnEndEdit()
    Log("OnEndEdit....")
end

function Class:StopAllCoroutines()
    if CoroutineMonoBehaviour then
        GG.CoroutineHelper.StopAllCoroutinesAuto(CoroutineMonoBehaviour)
    end
end

function Class:Release()
    Log("ChatPanel Release")
    GG.PBHelper.RemoveAllListenerByName('CLCHATROOM.ChatMessageNtf')
    self:StopAllCoroutines()
    CoroutineMonoBehaviour = nil
    InActiveMsgDataList = {}
    waitSendChatMsgViewList = {}
    waitSendChatMsgView = nil

    if self.inputField then
        self.inputField.onSubmit:RemoveAllListeners()
        self.inputField.onSubmit:Invoke("")
        self.inputField = nil
    end

    if self.emojiPanel then
        self.emojiPanel:Release()
        self.emojiPanel = nil
    end
    if self.phrasePanel then
        self.phrasePanel:Release()
        self.phrasePanel = nil
    end
    if self.voicePanel then
        self.voicePanel:Release()
        self.voicePanel = nil
    end
    if self.msgScrollView then
        self.msgScrollView:Release()
        self.msgScrollView = nil
    end
end

function Class:OnDestroy()
    Log("ChatPanel OnDestroy")
    self:Release()
end

return Class
