-- 游戏涉及lua文件统一在此文件加载
-- protobuffer文件夹下的结构体文件不在这里统一加载
print("初始化全局变量GG")

GG = {}

require "ModuleHelper"  --此文件包含class定义，放到最前面
require "Table.LanguageConvert" --涉及_STR_的定义，放到LuaDefines之前加载

--FrameWork
_G.json = require "LuaUtil.dkjson"
require "LuaUtil.dumper"

require "LuaUtil.LuaDefines"
require "LuaUtil.Functions"
require "LuaUtil.Logger"

GG.Config = require "Config"

GG.LuaAssetLoader = require "LuaAssetLoader"
GG.LuaHintMessage = require "LuaHintMessage"
GG.LuaLoginCtrl = require   "LuaLoginCtrl"
GG.WebRequest = require "WebRequest"

-- LuaUtil
GG.CoroutineHelper = require "LuaUtil.CoroutineHelper"
GG.LanguageHelper = require "LuaUtil.LanguageHelper"
GG.Helpers = require "LuaUtil.Helpers"

-- Message
GG.MessageCenter = require "Message.MessageCenter"
GG.MsgType = require "Message.MessageType"

-- Module -- 大厅 GamePlayer 小游戏独立运行登录用
GG.GamePlayer = require "Module.GamePlayer"

-- Pool
GG.PoolManager, GG.Pool = require "Pool.PoolManager"

-- protobuffer
GG.CLGTSender = require "protobuffer.CLGTSender" -- 大厅消息协议
GG.PBHelper = require "protobuffer.PBHelper"
-- 
GG.CLSLWHSender = require "protobuffer.CLSLWHSender" -- 小游戏消息协议

-- Table
GG.LanguageErrcode = require "Table.LanguageErrcode"
GG.DisconnectTips = require "Table.DisconnectTips"
GG.Language = require "Table.Language"
GG.Item = require "Table.Item"

-- OSAScroll
GG.OSAScrollView = require 'OSAScrollView.OSAScrollView'
GG.InfinityScroView = require 'OSAScrollView.InfinityScroView'
GG.ScrollItemViewDataHelper = require 'OSAScrollView.ScrollItemViewDataHelper'

-- Chat
GG.EmojiPanel = require "ChatSystem.EmojiPanel"
GG.PhrasePanel = require "ChatSystem.PhrasePanel"
GG.VoicePanel = require "ChatSystem.VoicePanel"
GG.ChatMsgData = require "ChatSystem.ChatMsgData"
GG.ChatMsgView = require 'ChatSystem.ChatMsgView'
GG.ChatPanel = require "ChatSystem.ChatPanel"
GG.PBHelper = require 'protobuffer.PBHelper'
GG.CLCHATROOMSender = require 'protobuffer.CLCHATROOMSender'
-- PlayerList
GG.PlayerListPanel = require "PlayerList.PlayerListPanel"
GG.PlayerListItemData = require "PlayerList.PlayerListItemData"
GG.PlayerListItemView = require "PlayerList.PlayerListItemView"

-- Game 小游戏模块
GG.GameConfig = require "Game.GameConfig"
GG.CountDownTimerManager = require "Game.CountDownTimerManager"
GG.ChouMaFly = require "Game.ChouMaFly"

GG.FQZS_UserInfo = require "Game.UI.FQZS_UserInfo"
GG.FQZS_TimerCounterUI = require "Game.UI.FQZS_TimerCounterUI"
GG.FQZS_RulePanel = require "Game.UI.FQZS_RulePanel"
GG.FQZS_ResultPanel = require "Game.UI.FQZS_ResultPanel"
GG.FQZS_LuDan_PanluPanel = require "Game.UI.FQZS_LuDanPanluPanel"
GG.FQZS_LuDan_AnimalPanel = require "Game.UI.FQZS_LuDanZoushiAnimPanel"
GG.FQZS_LuDan_TypePanel = require "Game.UI.FQZS_LuDanZoushiTypePanel"
GG.FQZS_LuDan_MainPanel = require "Game.UI.FQZS_LuDanPanel"
GG.FQZS_MainUI = require "Game.UI.FQZS_MainUI"

GG.FQZS_View = require "Game.View.FQZS_View"
GG.FQZS_ViewCtrl = require "Game.Controller.FQZS_ViewCtrl"
GG.FQZS_RoomSelectView = require "Game.View.FQZS_RoomSelectView"
GG.FQZS_RoomSelectViewCtrl = require "Game.Controller.FQZS_RoomSelectViewCtrl"










