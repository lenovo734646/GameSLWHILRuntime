SEnv = SubGame_Env
-- if g_Env then
--     print = function (...)--日志屏蔽
--     end
-- end
_STR_ = _STR_ or function(str)
    return str
end
SEnv.gamectrl={}
SEnv.OpenPlazaUI=function (...)
    if g_Env then
        return g_Env.uiManager:OpenUI(...)
    end
end
SEnv.ClosePlazaUI=function (...)
    if g_Env then
        return g_Env.uiManager:CloseUI(...)
    end
end
SEnv.Leave = function (...)
    if g_Env then
        return g_Env.SubGameCtrl.Leave(...)
    end
end
SEnv.MessageBox = g_Env and g_Env.MessageBox or function(str)
    print('[兼容函数MessageBox]',str)
end

SEnv.ShowHintMessage = function(contentStr)
    if g_Env then
        g_Env.ShowHitMessage(contentStr)
    else
        print(contentStr)
    end
end

-- 想要方便测试，就在这里加上转换表
local convertTable = {
    ["CLLADY.EnterRoomAck"]={"房间不存在","已经在房间中","系统错误",},
    ["CLLADY.ExitRoomAck"]={"你不在房间中",},
    ["CLLADY.SetBetLevelAck"]={"你不在房间中","参数错误",},
    ["CLLADY.RandomResultAck"]={"你不在房间中","金币不足","房间配置参数错误","系统错误",},
    ["CLLADY.FreeGamesSelectLevelAck"]={"你没有免费游戏兑换权限","还有剩余免费游戏次数没使用完","参数错误",},
}
SEnv.ErrorPaser = g_Env and g_Env.GetServerErrorMsg or function(errCode, ackname)
    local errstr = convertTable[ackname] and convertTable[ackname][errCode] or nil
    return errstr or ('服务器返回错误errCode=' .. tostring(errCode) .. ' ackname=' .. tostring(ackname))
end

SEnv.GetHeadSprite = g_Env and g_Env.CommonUICtrl and g_Env.CommonUICtrl.GetHeadSprite
SEnv.GetHeadFrameSprite = g_Env and g_Env.CommonUICtrl and g_Env.CommonUICtrl.GetHeadSprite

if g_Env then
    setmetatable(SEnv,{
        __index = function (t,k)
            return g_Env[k]
        end
    })
end
