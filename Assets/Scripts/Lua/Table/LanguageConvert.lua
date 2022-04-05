
-- 小游戏自己的语言转换表，大厅里的转换表找不到会从这里找
local constantStringConvertor = {
    -- 小游戏
    ["取消语音发送"] = {EN = "Cancel voice sending"},
    ["录音失败，请检查权限"] = {EN = "The recording failed, please check the permissions"},
    ["录音需要麦克风权限，请手动打开麦克风权限"] = {EN = " please turn on the microphone permissions"},
    ["在线人数：{1}"] = {EN = 'Online: {1}'},
    ["上局没有下注记录"] = {EN = "There was no betting record in the last game"},
    ["获取历史记录出错"] = {EN = "Get histroy record error"},
    ["选择的筹码不合法"] = {EN = "The chips selected are illegal"},
    ["等待下一局开始"] = {EN = "Wait for the next round to start"},
    ["金币不足"] = {EN = 'Gold shortage'},
    ["你已不在房间中"] = {EN = "You are not in room"},
    ["房间状态错误"] = {EN = "Room state error"},
    ["分数不足，无法续押"] = {EN = "Insufficient score,Can not Continue Bet"},
    [""] = {EN = ""},
    [""] = {EN = ""},
    [""] = {EN = ""},
    [""] = {EN = ""},
    [" 大四喜x{1} "] = {EN = "Big Four x {1}"},
    [" 大三元x{1} "] = {EN = "Big Three x {1}"},
    [" 庄x{1} "] = {EN = "Dealer x {1}"},
    [" 闲x{1} "] = {EN = "Player x {1}"},
    [" 和x{1} "] = {EN = "Tie x {1}"},
    [" 总局数x{1} "] = {EN = "Total x {1}"},

}

return constantStringConvertor