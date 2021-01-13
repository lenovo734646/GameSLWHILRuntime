
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local pairs = pairs
local UnityEngine, GameObject, Image, Button = UnityEngine, GameObject, UnityEngine.UI.Image, UnityEngine.UI.Button
local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local WaitForSeconds = UnityEngine.WaitForSeconds

_ENV = moduledef { seenamespace = CS }

-- 常用语快捷聊天界面
-- 快速聊天
local PhraseDataTable = {
    { index = 0, txt = "不要崇拜哥，哥只是个传说",      sound = "game_chat_sound_0.mp3" },
    -- {index = 1, txt = "不要崇拜姐，姐只是个传说",    sound = "game_chat_sound_1.mp3"},
    { index = 2, txt = "人在江湖飘，哪有不挨刀",        sound = "game_chat_sound_2.mp3" },
    -- {index = 3, txt = "我要上庄了，颤抖吧凡人",      sound = "game_chat_sound_3.mp3"},
    { index = 4, txt = "天空一声巨响，大爷闪亮登场",    sound = "game_chat_sound_4.mp3" },
    { index = 5, txt = "人有多大胆，地有多大产",        sound = "game_chat_sound_5.mp3" },
    -- {index = 6, txt = "真棒，恭喜您被爆",            sound = "game_chat_sound_6.mp3"},
    { index = 7, txt = "搏一搏，单车变摩托",            sound = "game_chat_sound_7.mp3" },
    { index = 8, txt = "辛辛苦苦几十把，一把回到解放前", sound = "game_chat_sound_8.mp3" },
    { index = 9, txt = "不是不爆，时候未到",             sound = "game_chat_sound_9.mp3" },
    { index = 10, txt = "大神们大爷们，谁能打赏点红包啊", sound = "game_chat_sound_10.mp3" },
    { index = 11, txt = "恭喜发财，红包发来",            sound = "game_chat_sound_11.mp3" },
    { index = 12, txt = "来来来，开车了，我带队一起玩",  sound = "game_chat_sound_12.mp3" },
    { index = 13, txt = "青山不改，绿水长流，先溜了",    sound = "game_chat_sound_13.mp3" },
    { index = 14, txt = "确认过眼神，这把指定赢",          sound = "game_chat_sound_14.mp3" },
    { index = 15, txt = "生死有命富贵在天，这把赢了赛神仙", sound = "game_chat_sound_15.mp3" },
    { index = 16, txt = "输赢五五开，错过再重来",          sound = "game_chat_sound_16.mp3" },
    { index = 17, txt = "稳住稳住，我们能赢",                sound = "game_chat_sound_17.mp3" },
    { index = 18, txt = "我信你个鬼，也不来把大牌",         sound = "game_chat_sound_18.mp3" },
    { index = 19, txt = "小哥哥小哥哥，我们去开房玩",        sound = "game_chat_sound_19.mp3" },
    { index = 20, txt = "一首凉凉送给你",                  sound = "game_chat_sound_20.mp3" },
    { index = 21, txt = "游戏玩的好，女友在高考",          sound = "game_chat_sound_21.mp3" },
    { index = 22, txt = "有开房一起玩的吗，约约约",         sound = "game_chat_sound_22.mp3" },
    { index = 23, txt = "有输就有赢，输得起才能赢得起",   sound = "game_chat_sound_23.mp3" },
    { index = 24, txt = "终于等到你，还好没放弃",          sound = "game_chat_sound_24.mp3" }
}

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
    self.itemCount = #PhraseDataTable
    for k, v in pairs(PhraseDataTable) do
        local data = {}
        local go = GameObject.Instantiate(itemPrefab, self.scrollView.content.transform)
        go:GetComponent(typeof(LuaInitHelper)):Init(data)
        go.name = v.index
        data.phraseText.text = v.txt
        data.item_phrase_button.onClick:AddListener(function ()
            self:OnPhraseClick(data)
        end)
    end
end

function Class:OnPhraseClick(data)
    print("点击快捷常用语：index = ", data.index, data.txt, data.sound)

    -- 发送常用语
    -- 播放声音
end

function Class:OnShow(isOn)
    if isOn then
        self.animatorHelper:Play("popup_in")
    else
        self.animatorHelper:Play("popup_out")
    end
end


return _ENV