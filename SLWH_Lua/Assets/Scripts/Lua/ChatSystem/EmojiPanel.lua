
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, Image, Button = UnityEngine, GameObject, UnityEngine.UI.Image, UnityEngine.UI.Button
local assetLoader = g_Env.assetLoader
local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local WaitForSeconds = UnityEngine.WaitForSeconds



_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel, inputField, emojis, emojiPrefab)
    self.panel = panel
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    --
    if emojiPrefab == nil then
        logError("emojiPrefab is nil")
        return
    end
    self.inputField = inputField
    self.emojiCount = emojis.Length-1
    if emojis ~= nil and self.emojiCount > 0 then
        for i = 1, self.emojiCount do
            local go = GameObject.Instantiate(emojiPrefab, self.contentRoot)
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
        if self.panel.activeSelf == false then
            self.panel:SetActive(true)
        end
        self.panelAnimator:Play("popup")
        CoroutineHelper.StartCoroutine(function ()
            yield(WaitForSeconds(0.1))
            self.scrollRect.verticalScrollbar.value = 1;
        end)
    else
        self.panelAnimator:Play("popup reverse")
        CoroutineHelper.StartCoroutine(function ()
            while true do
                yield()
                if self.panel.transform.localScale.y <= 0 then
                    self.panel:SetActive(false)
                    break
                end
            end
        end)
    end


end


return _ENV