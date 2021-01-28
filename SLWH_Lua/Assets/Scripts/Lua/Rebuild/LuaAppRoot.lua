local _G = _G
local g_Env = g_Env
local print, tostring, SysDefines, typeof, Destroy, LogE,string, assert =
      print, tostring, SysDefines, typeof, Destroy, LogE,string, assert

local UnityEngine = UnityEngine



local HotUpdate = require'Table.HotUpdate'

_ENV = moduledef { seenamespace = CS }
---------------------module start
---
---
function Create()

    local this = {
        _assetUrl = '',
        curGameGroup = 0,
        curState = 0,
        CurGameId = 0,
        hallurl = '',
    }

    function this:IsRunInHall()
        return true --只有小游戏才调用这个函数
    end
    function this:GameToHall()
        return GameToHall(self)
    end
    function this:GoToGame(...)
        return GoToGame(self,...)
    end
    function this:InitContext(...)
        return g_Env.Config:GetDownUrlBase()
    end
    return this
end



function GoToGame(this, table, isReconnet)
    if not table.ServerName then
        LogE('配置文件还未更新或设置 NameEN:'..table.NameEN)
        return
    end
    print("GoToGame:  ",table.ServerName )

    NetController.Instance:SendAccessServiceReq(table.GameGroupType, EnumAccessServiceType.JoinGame,
    function(gameData)
        -- 如果是断线重连进游戏,但是没有gamedata不启动小游戏
        if isReconnet and gameData and gameData ~= '' then
            NetController.Instance:SendAccessServiceReq(table.GameGroupType, EnumAccessServiceType.QuitGame)
            return
        end

        this.curGameGroup = table.GameGroupType
        this.CurGameId = table.GameId
        this.curServerName = table.ServerName

        g_Env.OpenSubGame({
            gameName = table.NameEN,
        })

        if (not string.IsNullOrEmpty(gameData)) then
            --g_Env.subGameEnv.OnGameReconnected(gameData)
            if _G.OnGameReconnected then
                _G.OnGameReconnected(gameData)
            end
        end

        this.curState = 1

        if (table.ScreenOrientation == 2) then
            UnityEngine.Screen.orientation = UnityEngine.ScreenOrientation.Portrait
            g_Env.gamectrl.MainCanvasScaler.referenceResolution = UnityEngine.Vector2(1080, 1920)
            MessageCenter.Instance:SendMessage(MsgType.CLIENT_INNERGAME_OPENCLOSE, nil)
        end

        g_Env.uiManager:CloseUI('LuaMainUI')
        g_Env.loaders.plaza:Clear()


    end,table.ServerName)
end

function GameToHall(this)

    print("GameToHall : ",this.curGameGroup,EnumAccessServiceType.QuitGame)
    NetController.Instance:SendAccessServiceReq(this.curGameGroup, EnumAccessServiceType.QuitGame, function(gameData)

        this.curGameGroup = 0
        this.CurGameId = 0

        g_Env.CLoseSubGame()

        g_Env.loaders.plaza:LoadScene('MainScene')

        AudioManager.Instance:PlayMusic(SysDefines.AUDIO .. "main")

        this.curState = 0

        UnityEngine.Screen.orientation = UnityEngine.ScreenOrientation.Landscape
        g_Env.gamectrl.MainCanvasScaler.referenceResolution = UnityEngine.Vector2(1920, 1080)
        MessageCenter.Instance:SendMessage(MsgType.CLIENT_INNERGAME_OPENCLOSE, nil)

        g_Env.uiManager:OpenUI('LuaMainUI')

    end ,this.curServerName )
end

function ForceQuit(this)

    this.curGameGroup = 0
    g_Env.CLoseSubGame()

    this.curState = 0
end

function HallToGame(this, gameId)
    print("HallToGame id = " .. gameId)


    if (this.curState == 1) then return end

    local hotUpdate
    -- 查找小游戏配置
    for i = 1, #HotUpdate do
        if gameId == HotUpdate[i].GameId then
            hotUpdate = HotUpdate[i]
            break
        end
    end
    -- _G.PrintTable(hotUpdate)
    GoToGame(this, hotUpdate)
end

return _ENV