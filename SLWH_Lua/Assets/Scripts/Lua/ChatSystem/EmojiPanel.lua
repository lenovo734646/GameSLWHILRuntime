
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, Image, Button = UnityEngine, GameObject, UnityEngine.UI.Image, UnityEngine.UI.Button
local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local WaitForSeconds = UnityEngine.WaitForSeconds



_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel, inputField, emojis, itemPrefab)
    self.panel = panel
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    --
    if itemPrefab == nil then
        logError("emojiPrefab is nil")
        return
    end
    self.inputField = inputField
    self.emojiCount = emojis.Length-1
    if emojis ~= nil and self.emojiCount > 0 then
        for i = 1, self.emojiCount do
            local go = GameObject.Instantiate(itemPrefab, self.scrollView.content.transform)
            go:GetComponent(typeof(Image)).sprite = emojis[i]
            go.name = emojis[i].name
            go:GetComponent(typeof(Button)).onClick:AddListener(function ()
                self:OnEmojiClick(i-1)
            end)
        end
    end

end

function Class:OnEmojiClick(index)
    local str = ""
    if index < 0 or index > self.emojiCount then
        return
    end
    str = "<sprite="..index..">"
    self.inputField.text = self.inputField.text..str
    self.inputField:MoveTextEnd(false)
end

function Class:OnShow(isOn)
    if isOn then
        self.animatorHelper:Play("popup_in")
    else
        self.animatorHelper:Play("popup_out")
    end
end


return _ENV