
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, Image, Button = UnityEngine, GameObject, UnityEngine.UI.Image, UnityEngine.UI.Button


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
    self.emojiCount = #emojis
    if emojis ~= nil and self.emojiCount > 0 then
        for i = 1, self.emojiCount do
            local go = GameObject.Instantiate(itemPrefab, self.scrollView.content.transform)
            go:GetComponent(typeof(Image)).sprite = emojis[i]
            go.name = emojis[i].name
            go:GetComponent(typeof(Button)).onClick:RemoveAllListeners()
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
    str = string.format("<sprite=%02d>", index)
    self.inputField.text = self.inputField.text..str
    self.inputField:MoveTextEnd(false)
end

function Class:OnShow(isOn)
    self.panel:SetActive(isOn)
    if isOn then
        self.animatorHelper:Play("popup_in")
    else
        self.animatorHelper:Play("popup_out")
    end
end

function Class:Release()
    print("EmojiPanel Release", self.scrollView.content, self.animatorHelper:GetAnimator())
    if self.animatorHelper:GetAnimator() then
        self.animatorHelper:Stop()
    end
    
    if self.scrollView and self.scrollView.content then
        for i = 0, self.scrollView.content.transform.childCount-1 do
            local go = self.scrollView.content.transform:GetChild(i)
            go:GetComponent(typeof(Button)).onClick:RemoveAllListeners()
        end
    end
end

-- function Class:OnDestroy()
--     print("1111111111111")
-- end

return _ENV