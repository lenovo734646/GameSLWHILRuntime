
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local pairs = pairs
local UnityEngine, GameObject, Image, Button = UnityEngine, GameObject, UnityEngine.UI.Image, UnityEngine.UI.Button
local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local WaitForSeconds = UnityEngine.WaitForSeconds
local _STR_ = _STR_
local SysDefines = SysDefines
_ENV = moduledef { seenamespace = CS }

-- 常用语快捷聊天界面
-- 快速聊天
local PhraseDataTable = {
    { index = 0, txt = _STR_"不要崇拜哥，哥只是个传说",      sound = "game_chat_sound_0" },
    -- {index = 1, txt = _STR_"不要崇拜姐，姐只是个传说",    sound = "game_chat_sound_1"},
    { index = 2, txt = _STR_"人在江湖飘，哪有不挨刀",        sound = "game_chat_sound_2" },
    -- {index = 3, txt = _STR_"我要上庄了，颤抖吧凡人",      sound = "game_chat_sound_3"},
    { index = 4, txt = _STR_"天空一声巨响，大爷闪亮登场",    sound = "game_chat_sound_4" },
    { index = 5, txt = _STR_"人有多大胆，地有多大产",        sound = "game_chat_sound_5" },
    -- {index = 6, txt = _STR_"真棒，恭喜您被爆",            sound = "game_chat_sound_6"},
    { index = 7, txt = _STR_"搏一搏，单车变摩托",            sound = "game_chat_sound_7" },
    { index = 8, txt = _STR_"辛辛苦苦几十把，一把回到解放前", sound = "game_chat_sound_8" },
    { index = 9, txt = _STR_"不是不爆，时候未到",             sound = "game_chat_sound_9" },
    { index = 10, txt = _STR_"大神们大爷们，谁能打赏点红包啊", sound = "game_chat_sound_10" },
    { index = 11, txt = _STR_"恭喜发财，红包发来",            sound = "game_chat_sound_11" },
    { index = 12, txt = _STR_"来来来，开车了，我带队一起玩",  sound = "game_chat_sound_12" },
    { index = 13, txt = _STR_"青山不改，绿水长流，先溜了",    sound = "game_chat_sound_13" },
    { index = 14, txt = _STR_"确认过眼神，这把指定赢",          sound = "game_chat_sound_14" },
    { index = 15, txt = _STR_"生死有命富贵在天，这把赢了赛神仙", sound = "game_chat_sound_15" },
    { index = 16, txt = _STR_"输赢五五开，错过再重来",          sound = "game_chat_sound_16" },
    { index = 17, txt = _STR_"稳住稳住，我们能赢",                sound = "game_chat_sound_17" },
    { index = 18, txt = _STR_"我信你个鬼，也不来把大牌",         sound = "game_chat_sound_18" },
    { index = 19, txt = _STR_"小哥哥小哥哥，我们去开房玩",        sound = "game_chat_sound_19" },
    { index = 20, txt = _STR_"一首凉凉送给你",                  sound = "game_chat_sound_20" },
    { index = 21, txt = _STR_"游戏玩的好，女友在高考",          sound = "game_chat_sound_21" },
    { index = 22, txt = _STR_"有开房一起玩的吗，约约约",         sound = "game_chat_sound_22" },
    { index = 23, txt = _STR_"有输就有赢，输得起才能赢得起",   sound = "game_chat_sound_23" },
    { index = 24, txt = _STR_"终于等到你，还好没放弃",          sound = "game_chat_sound_24" }
}
local FontSize = 30

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel, itemPrefab)
    self.panel = panel
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    --
    if itemPrefab == nil then
        logError("emojiPrefab is nil")
        return
    end
    local curLanguage = SysDefines.curLanguage
    if curLanguage~='CN' then
        FontSize = 20
    end
    self.itemCount = #PhraseDataTable
    for k, v in pairs(PhraseDataTable) do
        local data = {}
        local go = GameObject.Instantiate(itemPrefab, self.scrollView.content.transform)
        go:GetComponent(typeof(LuaInitHelper)):Init(data)
        go.name = v.index
        data.phraseText.fontSize = FontSize
        data.phraseText.text = v.txt
        data.item_phrase_button.onClick:AddListener(function ()
            self:OnPhraseClick(v)
        end)
    end
end

function Class:OnPhraseClick(data)
    print("点击快捷常用语：index = ", data.index, data.txt, data.sound)

    if self.OnPhraseClickCallBack ~= nil then
        self.OnPhraseClickCallBack(data)
    end
    
end

function Class:OnShow(isOn)
    if isOn then
        self.animatorHelper:Play("popup_in")
    else
        self.animatorHelper:Play("popup_out")
    end
end

function Class:GetPhraseData(index)
    for k, v in pairs(PhraseDataTable) do
        if v.index == index then
            return {content = v.txt, sound = v.sound}
        end
    end
    return nil
end

function Class:Release()
    if self.animatorHelper:GetAnimator() then
        self.animatorHelper:Stop()
    end
    if self.scrollView and self.scrollView.content then
        for i = 0, self.scrollView.content.transform.childCount-1 do
            local go = self.scrollView.content.transform:GetChild(i)
            go:GetComponent(typeof(Button)).onClick:RemoveAllListeners()
        end
    end
    self.OnPhraseClickCallBack = nil
end

return _ENV