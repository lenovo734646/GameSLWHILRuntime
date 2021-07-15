
/******************************************************************************
 * 
 *  Title:  捕鱼项目
 *
 *  Version:  1.0版
 *
 *  Description:
 *
 *  Author:  WangXingXing
 *       
 *  Date:  2018
 * 
 ******************************************************************************/

using System;
using System.Collections;
using UnityEngine;

using System.Collections.Generic;
using QL.Core;
using QL.Protocol;
using System.Linq;
using System.Threading.Tasks;
using XLua;
using SubGameNet;

public class NetController : DDOLSingleton<NetController> 
{
    public string serverUrl = "http://101.36.116.254:8000/router/rest";//"http://47.104.147.168:8000/router/rest";
    private DefaultQLClient webClient;
    public DefaultQLClient WebClient
    {
        get
        {
            //这里会在非主线程调用！！
            if (null == webClient)
            {
                webClient = new DefaultQLClient("client", "mbXr8nNL3Gnust17");
                Debug.Log("serverUrl:" + serverUrl);
                webClient.ServerUrl = serverUrl;
            }
            return webClient;
        }
    }

    public NetComponent netComponent = new NetComponent(new NetReactor());


    private void Awake()
    {
        //netComponent.addResponser(new ClientGTResponser());
        netComponent.SendMessageFunc = objs => {
            MessageCenter.Instance.SendMessage(MsgType.NET_RECEIVE_DATA, objs[0], objs[1]);
        };
        netComponent.addResponser(new ClientPFResponserPB());
        netComponent.addResponser(new ClientGTResponserPB()); 
        //netComponent.addResponser(new ClientFishingMainResponserPB());
        //netComponent.addResponser(new ClientFishingRoomResponserPB());
    }

    private void Update()
    {
        netComponent.run();
    }



    /// <summary>
    /// 获取连接IP 与 Port
    /// </summary>
    /// <param name="connectGame">回调函数</param>
    public void GetIpPort(Action connectGame)
    {
        ClientGetGateConnectionRequest webReq = new ClientGetGateConnectionRequest();
        webReq.ZoneId = SysDefines.ZoneId;
        asyncExecuteWebRequest(webReq, webRsp =>
        {
            if (webRsp.IsError)
            {
                Debug.LogError($"获取网关连接方式失败：{webRsp.ErrMsg}");
                //TODO: 最好将错误信息提示出来
            }
            else
            {
                SysDefines.Ip = webRsp.Ip;
                SysDefines.Port = webRsp.Port;
                connectGame?.Invoke();
                Debug.LogFormat("ip: {0}, port: {1}", SysDefines.Ip, SysDefines.Port);
            }
        });
    }

   

    //异步执行web请求
    private async void asyncExecuteWebRequest<T>(IQLRequest<T> request, Action<T> callback) where T : QLResponse
    {
        T webRsp = await Task.Run(() => WebClient.Execute(request));
        callback?.Invoke(webRsp);
        //string body = "";
        //T webRsp = await Task.Run(() => WebClient.Execute(request, null, DateTime.Now, ref body));
        //if (webRsp == null)
        //{
        //    var r = GLuaSharedHelper.g_Env.Get<LuaTable>("ResponseHeler").Get<LuaFunction>("CreateResponseByJson").Call(body);
        //    webRsp = r[0] as T;
        //    if (webRsp == null)
        //    {
        //        Debug.LogError("webRsp == null body:" + body);
        //    }
        //}
        //callback?.Invoke(webRsp);
    }

    //#endregion
    /// <summary>
    /// 握手协议
    /// </summary>
    public void SendHandReq()
    {
        CLGT.HandReq req = new CLGT.HandReq();
        req.Platform = (CLGT.HandReq.Types.PlatformType)SysDefines.Platform;
        req.Product = 1;
        req.Version = (int)SysDefines.Version;
        req.Device = SystemInfo.deviceUniqueIdentifier;
        req.Channel = "com.game.fishing.android";
        req.Country = "ZH-CN";
        req.Language = "CN";
        netComponent.asyncRequest<CLGT.HandAck>(req, rsp => 
        {
            netComponent.SetRandomKey(rsp.RandomKey.ToByteArray());
            //Debug.Log(" 收到握手回应! ");
            MessageCenter.Instance.SendMessage(MsgType.NET_HAND_ACK, this, rsp);
            //rsp.RandomKey
        });
    }

    /// <summary>
    /// 登录大厅请求
    /// </summary>
    /// <param name="randomKey">随机密钥</param>
    public void SendLoginPlatformReq(int randomKey)
    {
        CLGT.LoginReq req = new CLGT.LoginReq();
        req.LoginType = (CLGT.LoginReq.Types.LoginType)SysDefines.LoginType;
        var expendToken = SysDefines.OpeninstallToken;
        switch (SysDefines.LoginType) {
            case 1:
                //req.token = UnityHelper.CA3Encode("zhubin000", randomKey);
                req.Token = $"{SystemInfo.deviceUniqueIdentifier},{expendToken}";
                break;
            case 2:
                req.Token = $"{SysDefines.LoginToken},{expendToken}";
                break;
            case 4:
                req.Token = $"{SysDefines.LoginToken},{expendToken}";
                break;
            default:
                return;
        }

        netComponent.asyncRequestWithLock<CLGT.LoginAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_LOGIN_PLATFORM_ACK, this, rsp);

             //打开app到登录完成需要一定时间，这段时间内有可能发布了客户端配置表
             //为了在这种情况下也能加载到最新配置，这时调用一下LoadFromNet ^_^
             //下面还是先注释掉吧，2019年7月13日11:01:30 client_config_md5参数需要从json串里查找
             //if (rsp.errcode == 0)
             //{
             //    TableLoadHelper.LoadFromNet(SysDefines.OssUrl, rsp.client_config_md5, null);
             //}
         });
    }

    /// <summary>
    /// 登出大厅请求
    /// </summary>
    public void SendLogoutReq()
    {
        CLPF.LogoutReq req = new CLPF.LogoutReq();
        netComponent.Send(req);
    }

    /// <summary>
    /// 连接或断开服务器请求
    /// </summary>
    /// <param name="groupId">服务组Id</param>
    /// <param name="actionType">加入或者离开服务组</param>
    /// <param name="action">是否有回调</param>
    public void SendAccessServiceReq(int groupId, EnumAccessServiceType actionType, Action<string> action) {
        CLGT.AccessServiceReq req = new CLGT.AccessServiceReq();
        req.ServerName = "";
        req.Action = (int)actionType;
        netComponent.asyncRequestWithLock<CLGT.AccessServiceAck>(req, rsp => {
            //Debug.Log("SendMessage NET_ACCESSSERVICE_ACK rsp.errcode=" + rsp.errcode);
            MessageCenter.Instance.SendMessage(MsgType.NET_ACCESSSERVICE_ACK, this, rsp, new Dictionary<string, object>() {
                {"ActionType", actionType},
                {"Action", action},
                {"GroupId", groupId}
            });
        } );
    }

    /// <summary>
    /// 连接或断开服务器请求
    /// </summary>
    /// <param name="actionType">加入或者离开服务组</param>
    /// <param name="action">是否有回调</param>
    public void SendAccessServiceReq(int groupId , EnumAccessServiceType actionType, Action<string> action,string ServerName)
    {
        CLGT.AccessServiceReq req = new CLGT.AccessServiceReq();
        req.ServerName = ServerName;
        req.Action = (int)actionType;
        netComponent.asyncRequestWithLock<CLGT.AccessServiceAck>(req, rsp => {
            //Debug.Log("SendMessage NET_ACCESSSERVICE_ACK rsp.errcode=" + rsp.errcode);
            MessageCenter.Instance.SendMessage(MsgType.NET_ACCESSSERVICE_ACK, this, rsp, new Dictionary<string, object>() {
                {"ActionType", actionType},
                {"Action", action},
                {"GroupId", groupId}
            });
        });
    }


    /// <summary>
    /// 加入玩法请求
    /// </summary>
    /// <param name="">游戏玩法的ID</param>
    public void SendEnterSiteReq(int siteId, int roomId = -1, int seatId = -1, int password = -1)
    {
        //清理上次渔场内的ack协议缓存
        netComponent.clearWaitingResponse<CLFR.EnterGameAck>();
        netComponent.clearWaitingResponse<CLFR.EnterGameWithPasswordAck>();
        netComponent.clearWaitingResponse<CLFR.ExitGameAck>();
        netComponent.clearWaitingResponse<CLFR.GetReadyAck>();
        netComponent.clearWaitingResponse<CLFR.JoinMatchAck>();
        netComponent.clearWaitingResponse<CLFR.GunValueChangeAck>();
        netComponent.clearWaitingResponse<CLFR.ShootAck>();
        netComponent.clearWaitingResponse<CLFR.MultiShootAck>();
        netComponent.clearWaitingResponse<CLFR.HitAck>();
        netComponent.clearWaitingResponse<CLFR.BossHitAck>();
        netComponent.clearWaitingResponse<CLFR.BossRankAck>();
        netComponent.clearWaitingResponse<CLFR.GunUnlockAck>();
        netComponent.clearWaitingResponse<CLFR.BonusWheelAck>();
        netComponent.clearWaitingResponse<CLFR.GunSwitchAck>();
        netComponent.clearWaitingResponse<CLFR.IntegralGainQueryAck>();
        netComponent.clearWaitingResponse<CLFR.WarheadLockAck>();
        netComponent.clearWaitingResponse<CLFR.WarheadBoomAck>();
        netComponent.clearWaitingResponse<CLFR.MultipleHitChangeAck>();
        netComponent.clearWaitingResponse<CLFR.BossNextAppearTimeAck>();
        netComponent.clearWaitingResponse<CLFR.BossSummonAck>();
        netComponent.clearWaitingResponse<CLFR.AcrossShootAck>();
        netComponent.clearWaitingResponse<CLFR.AcrossMultiShootAck>();
        netComponent.clearWaitingResponse<CLFR.AcrossHitAck>();
        netComponent.clearWaitingResponse<CLFR.AcrossBossHitAck>();
        netComponent.clearWaitingResponse<CLFR.EnergyStoreAck>();
        netComponent.clearWaitingResponse<CLFR.EnergyShootAck>();

        //发送进入渔场协议
        CLFM.EnterSiteReq req = new CLFM.EnterSiteReq();
        req.SiteId = siteId;
        //netComponent.asyncRequestWithLock<CLFM.EnterSiteAck>(req, rsp =>
        //{
            MessageCenter.Instance.SendMessage(MsgType.NET_ENTERSITE_ACK, this, null, new Dictionary<string, object>()
            {
                { "SiteId", siteId },
                { "RoomId", roomId },
                { "SeatId", seatId },
                { "Password", password },
            });
        //});
    }

    /// <summary>
    /// 退出玩法请求
    /// </summary>
    /// <param name="siteId">游戏玩法的ID</param>
    /// <param name="reason">退出原因 0正常渔场退出 1选座失败</param>
    public void SendExitSiteReq(int siteId, int reason = 0)
    {
        CLFM.ExitSiteReq req = new CLFM.ExitSiteReq();
        req.SiteId = siteId;
        //netComponent.asyncRequestWithLock<CLFM.ExitSiteAck>(req, rsp =>
        //{
            MessageCenter.Instance.SendMessage(MsgType.NET_EXITSITE_ACK, this, null, new Dictionary<string, object>()
            {
                {"SiteId", siteId},
                {"Reason", reason},
            });
        //});
    }

    /// <summary>
    /// 进入捕鱼游戏
    /// </summary>
    /// <param name="configID">配置的房间号</param>
    public void SendEnterFishingGameReq(int configID, int roomId, int seatId, int password = -1)
    {
        CLFR.EnterGameWithPasswordReq req = new CLFR.EnterGameWithPasswordReq();
        req.ConfigId = configID;
        req.RoomId = roomId;
        req.SeatId = seatId;
        req.Password = password;
        netComponent.asyncRequestWithLock<CLFR.EnterGameWithPasswordAck>(req, rsp =>
        {
            //FishingRoomController.ProcessEnterFishingRoomAck(rsp, configID, roomId > 0);
        });
    }

    /// <summary>
    /// 退出捕鱼房间
    /// </summary>
    public void SendExitGameReq(Action action)
    {
        CLFR.ExitGameReq req = new CLFR.ExitGameReq();
        netComponent.asyncRequestWithLock<CLFR.ExitGameAck>(req, rsp =>
        {
            //FishingRoomController.ProcessExitGameAck(rsp, action);
        });
    }

    /// <summary>
    /// 表示客户端已准备可以接收服务器的推送
    /// </summary>
    public void SendGetReadyReq()
    {
        CLFR.GetReadyReq req = new CLFR.GetReadyReq();
        netComponent.asyncRequest<CLFR.GetReadyAck>(req, rsp =>
         {
             //FishingRoomController.ProcessGetReadyAck(rsp);
         });
    }

    /// <summary>
    /// 开火
    /// </summary>
    /// <param name="angle">炮台角度</param>
    /// <param name="lockFishID">锁定鱼的id</param>
    //public void SendShootReq(int angle, int lockFishID, bool isPenetrate, byte multiple = 0)
    //{
    //    if (!SysDefines.IsInFishingGame) return;

    //    if (!isPenetrate)
    //    {
    //        //先创建一个虚拟子弹
    //        var bullet = FishingRoomController.CreateVirtualBulletForPlayerSelf(angle, lockFishID, false);
    //        if (bullet != null)
    //        {
    //            CLFR.ShootReq req = new CLFR.ShootReq();
    //            req.Angle = angle;
    //            req.LockFish = lockFishID;
    //            req.Multiple = multiple;
    //            netComponent.asyncRequest<CLFR.ShootAck>(req, rsp =>
    //            {
    //                FishingRoomController.ProcessShootAck(rsp, angle, bullet);
    //            });
    //        }
    //    }
    //    else
    //    {
    //        //先创建一个虚拟子弹
    //        var bullet = FishingRoomController.CreateVirtualBulletForPlayerSelf(angle, 0, true);
    //        if (bullet != null)
    //        {
    //            CLFR.AcrossShootReq req = new CLFR.AcrossShootReq();
    //            req.Angle = angle;
    //            req.Multiple = multiple;
    //            netComponent.asyncRequest<CLFR.AcrossShootAck>(req, rsp =>
    //            {
    //                FishingRoomController.ProcessAcrossShootAck(rsp, angle, bullet);
    //            });
    //        }
    //    }
    //}

    /// <summary>
    /// 分身开火
    /// </summary>
    /// <param name="angle">炮台角度</param>
    /// <param name="locakFishID">锁定鱼的id</param>
    //public void SendCloneShootReq(int[] angles, int[] lockFishIDs, bool isPenetrate, byte multiple = 0)
    //{
    //    if (!SysDefines.IsInFishingGame) return;

    //    if (!isPenetrate)
    //    {
    //        CLFR.MultiShootReq req = new CLFR.MultiShootReq();
    //        //req.ShootArray.Count = (SByte)angles.Length;
    //        var bullets = new RoomBullet[angles.Length];
    //        var info = new CLFR.ShootInfo[angles.Length];
    //        for (int i = 0; i < angles.Length; i++)
    //        {
    //            info[i] = new CLFR.ShootInfo();
    //            info[i].Angle = angles[i];
    //            info[i].LockFish = lockFishIDs[i];
    //            bullets[i] = FishingRoomController.CreateVirtualBulletForPlayerSelf(info[i].Angle, info[i].LockFish, false, i + 1);
    //        }
    //        req.ShootArray.AddRange( info);
    //        req.Multiple = multiple;
    //        if (bullets.Count(a => a != null) == bullets.Length)
    //        {
    //            netComponent.asyncRequest<CLFR.MultiShootAck>(req, rsp =>
    //            {
    //                FishingRoomController.ProcessCloneShootAck(rsp, bullets);
    //            });
    //        }
    //    }
    //    else
    //    {
    //        CLFR.AcrossMultiShootReq req = new CLFR.AcrossMultiShootReq();
    //        //req.shoot_len = (SByte)angles.Length;
    //        var bullets = new RoomBullet[angles.Length];
    //        var info = new int[angles.Length];
    //        for (int i = 0; i < angles.Length; i++)
    //        {
    //            info[i] = angles[i];
    //            bullets[i] = FishingRoomController.CreateVirtualBulletForPlayerSelf(info[i], 0, true, i + 1);
    //        }
    //        req.ShootArray.AddRange(info);
    //        req.Multiple = multiple;
    //        if (bullets.Count(a => a != null) == bullets.Length)
    //        {
    //            netComponent.asyncRequest<CLFR.AcrossMultiShootAck>(req, rsp =>
    //            {
    //                FishingRoomController.ProcessAcrossMultiShootAck(rsp, bullets);
    //            });
    //        }
    //    }
    //}

    /// <summary>
    /// 碰撞请求
    /// </summary>
    /// <param name="bulletId">子弹ID</param>
    /// <param name="fishId">鱼ID</param>
    //public void SendHitReq(int bulletId, int fishId, int[] related)
    //{
    //    if (!SysDefines.IsInFishingGame) return;

    //    CLFR.HitReq req = new CLFR.HitReq();
    //    req.BulletId = bulletId;
    //    req.FishId = fishId;
    //    if (!ReferenceEquals(related, null))
    //    {
    //        req.RelatedFishArray.AddRange( related);
    //        //req.RelatedFishArray.cou = (sbyte)related.Length;
    //    }
    //    netComponent.asyncRequest<CLFR.HitAck>(req, rsp =>
    //    {
    //        FishingRoomController.ProcessHitAck(rsp, bulletId, fishId);
    //    });
    //}

    /// <summary>
    /// 上报机器人子弹碰撞信息
    /// </summary>
    /// <param name="bulletId">子弹Id</param>
    /// <param name="fishId">鱼Id</param>
    //public void SendRobotHitRpt(int bulletId, int fishId)
    //{
    //    if (!SysDefines.IsInFishingGame) return;

    //    CLFR.RobotHitRpt rpt = new CLFR.RobotHitRpt();
    //    rpt.BulletId = bulletId;
    //    rpt.FishId = fishId;
    //    netComponent.send(rpt);
    //}

    /// <summary>
    /// boss子弹碰撞信息
    /// </summary>
    /// <param name="bulletId">子弹Id</param>
    //public void SendBossHitReq(int bulletId)
    //{
    //    if (!SysDefines.IsInFishingGame) return;

    //    CLFR.BossHitReq req = new CLFR.BossHitReq();
    //    req.BulletId = bulletId;
    //    netComponent.asyncRequest<CLFR.BossHitAck>(req, rsp => 
    //    {
    //        FishingRoomController.ProcessBossHitAck(rsp, bulletId);
    //    });
    //}

    /// <summary>
    /// 穿透命中请求
    /// </summary>
    //public void SendAcrossHitReq(int bulletId, int fishId, int[] related, long hitCache)
    //{
    //    if (!SysDefines.IsInFishingGame) return;

    //    CLFR.AcrossHitReq req = new CLFR.AcrossHitReq();
    //    req.BulletId = bulletId;
    //    req.FishId = fishId;
    //    if (!ReferenceEquals(related, null))
    //    {
    //        req.RelatedFishArray.AddRange( related);
    //        //req.related_fish_len = (sbyte)related.Length;
    //    }
    //    netComponent.asyncRequest<CLFR.AcrossHitAck>(req, rsp =>
    //    {
    //        FishingRoomController.ProcessAcrossHitAck(rsp, bulletId, fishId, hitCache);
    //    });
    //}

    /// <summary>
    /// boss穿透命中请求
    /// </summary>
    //public void SendAcrossBossHitReq(int bulletId, long hitCache)
    //{
    //    if (!SysDefines.IsInFishingGame) return;

    //    CLFR.AcrossBossHitReq req = new CLFR.AcrossBossHitReq();
    //    req.BulletId = bulletId;
    //    netComponent.asyncRequest<CLFR.AcrossBossHitAck>(req, rsp =>
    //    {
    //        FishingRoomController.ProcessAcrossBossHitAck(rsp, bulletId, hitCache);
    //    });
    //}

    /// <summary>
    /// 改变炮值请求
    /// </summary>
    /// <param name="gunValue">改变的炮值</param>
    //public void SendGunValueChangeReq(long gunValue)
    //{
    //    if (!SysDefines.IsInFishingGame) return;

    //    CLFR.GunValueChangeReq req = new CLFR.GunValueChangeReq();
    //    req.GunValue = gunValue;
    //    netComponent.asyncRequest<CLFR.GunValueChangeAck>(req, rsp =>
    //    {
    //        FishingRoomController.ProcessGunValueChangeAck(rsp);
    //    });
    //}

    /// <summary>
    /// 使用物品请求
    /// </summary>
    /// <param name="itemId">物品类型ID</param>
    /// <param name="itemSubId">物品子ID</param>
    /// <param name="count">使用物品的数量[默认使用1个]</param>
    ////public void SendItemUseReq(int itemId, int itemSubId, string ServerName,long count = 1, int groupId = 1, int serviceId = 1)
    ////{
    ////    CLPF.ItemUseReq req = new CLPF.ItemUseReq();
    ////    req.Item = new CLPF.ItemInfo();
    ////    req.Item.ItemId = itemId;
    ////    req.Item.ItemSubId = itemSubId;
    ////    req.Item.ItemCount = count;
    ////    req.ServerName = ServerName;


    ////    netComponent.asyncRequest<CLPF.ItemUseAck>(req, rsp =>
    ////    {
    ////        FishingRoomController.ProcessItemUseAck(rsp, itemId, itemSubId, count);
    ////    } );
    ////}

    /// <summary>
    /// 购买物品请求
    /// </summary>
    /// <param name="itemId">物品类型ID</param>
    /// <param name="itemSubId">物品子ID</param>
    /// <param name="count">购买物品的数量[默认购买1个]</param>
    /// <param name="action">是否有回调</param>
    public void SendItemBuyReq(int itemId, int itemSubId, long count = 1, Action action = null)
    {
        CLPF.ItemBuyReq req = new CLPF.ItemBuyReq();
        req.Item = new CLPF.ItemInfo();
        req.Item.ItemId = itemId;
        req.Item.ItemSubId = itemSubId;
        req.Item.ItemCount = count;
        netComponent.asyncRequest<CLPF.ItemBuyAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_ITEM_BUY_ACK, this, rsp, new Dictionary<string, object>()
            {
                { "action",action}
            });
        } );   
    }

    /// <summary>
    /// 解锁炮台请求
    /// </summary>
    //public void SendGunUnlockReq()
    //{
    //    CLFR.GunUnlockReq req = new CLFR.GunUnlockReq();
    //    netComponent.asyncRequest<CLFR.GunUnlockAck>(req, rsp =>
    //    {
    //        FishingRoomController.ProcessGunUnlockAck(rsp);
    //    });
    //}

    /// <summary>
    /// 锻造炮台请求
    /// </summary>
    /// <param name="use_crystal">是否使用水晶</param>
    public void SendGunForgeReq(sbyte useCrystal)
    {
        CLFR.GunForgeReq req = new CLFR.GunForgeReq();
        req.UseCrystal = useCrystal;
        netComponent.asyncRequest<CLFR.GunForgeAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_FORGE, this, rsp);
        });
    }

    /// <summary>
    /// 奖金抽奖请求
    /// </summary>
    public void SendBonusWheelReq()
    {
        CLFR.BonusWheelReq req = new CLFR.BonusWheelReq();
        netComponent.asyncRequest<CLFR.BonusWheelAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_BONUSWHEEL_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 切换炮台请求
    /// </summary>
    //public void SendGunSwitchReq(int gunId)
    //{
    //    CLFR.GunSwitchReq req = new CLFR.GunSwitchReq();
    //    req.GunId = gunId;
    //    netComponent.asyncRequest<CLFR.GunSwitchAck>(req, rsp =>
    //    {
    //        FishingRoomController.ProcessGunSwitchAck(rsp, gunId);
    //    });
    //}

    /// <summary>
    /// 修改头像
    /// </summary>
    /// <param name="headId">新头像id</param>
    //public void SendModifyHeadReq(int headId)
    //{
    //    CLPF.ModifyHeadReq req = new CLPF.ModifyHeadReq();
    //    req.NewHead = headId;
    //    netComponent.asyncRequest<CLPF.ModifyHeadAck>(req, rsp =>
    //    {
    //        switch (rsp.Errcode)
    //        {
    //            case 0:
    //                GLuaSharedHelper.Get<GamePlayer>("GamePlayer").SetNewHead(headId);
    //                break;
    //            default:
    //                MessageCenter.Instance.SendMessage(MsgType.CALL_LUA, "CreateHintMessageByResponseProtocol", rsp);
    //                break;
    //        }
    //    } );
    //}

    /// <summary>
    /// 设置昵称
    /// </summary>
    /// <param name="nickName">新昵称</param>
    public void SendModifyNicknameReq(string nickName)
    {
        CLPF.ModifyNicknameReq req = new CLPF.ModifyNicknameReq();
        req.NewNickname = nickName;
        netComponent.asyncRequest<CLPF.ModifyNicknameAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_MODIFYNICKNAME_ACK, this, rsp, new Dictionary<string, object>()
            {
                { "NickName",nickName}
            });
        } );
    }

    /// <summary>
    /// 商城购买次数请求
    /// </summary>
    public void SendShopQueryBuyCountReq()
    {
        CLPF.ShopQueryBuyCountReq req = new CLPF.ShopQueryBuyCountReq();
        netComponent.asyncRequest<CLPF.ShopQueryBuyCountAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_SHOP_BUYCOUNT_QUERY, this, rsp);
        });
    }

    /// <summary>
    /// 购买商品
    /// </summary>
    /// <param name="shopId">商品id</param>
    public void SendFShopBuyReq(int shopId)
    {
        CLPF.ShopBuyReq req = new CLPF.ShopBuyReq();
        req.ShopId = shopId;
        netComponent.asyncRequest<CLPF.ShopBuyAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_SHOP_BUY, this, rsp, new Dictionary<string, object>()
            {
                { "shopId", shopId }
            });
        });
    }
    /// <summary>
    /// 通用充值请求
    /// </summary>
    /// <param name="payMode"></param>
    /// <param name="shopId"></param>
    public void SendRechargeReq(int payMode, int shopId, int contentType = 1)
    {
        CLPF.RechargeReq req = new CLPF.RechargeReq();
        req.PayMode = payMode;
        req.ContentId = shopId;
        req.ContentType = contentType;
        netComponent.asyncRequest<CLPF.RechargeAck>(req, rsp =>
        {
            switch (rsp.Errcode)
            {
                case 0:
                    MessageCenter.Instance.SendMessage(MsgType.CLIENT_PAY_REQ, this, rsp, new Dictionary<string, object>() { { "PayMode", payMode } });
                    break;
                default:
                    //MessageCenter.Instance.SendMessage(MsgType.CALL_LUA, "CreateHintMessageByResponseProtocol", rsp);
                    break;
            }
        } );
    }

    //签到查询
    public void SendQuerySignReq()
    {
        CLPF.QuerySignReq req = new CLPF.QuerySignReq();
        netComponent.asyncRequest<CLPF.QuerySignAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_QUERY_SIGN, this, rsp);
        } );
    }

    //签到请求
    public void SendActSignReq()
    {
        CLPF.ActSignReq req = new CLPF.ActSignReq();
        netComponent.asyncRequest<CLPF.ActSignAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_ACT_SIGN, this, rsp);
        } );
    }

    /// <summary>
    /// 查询VIP抽奖请求
    /// </summary>
    public void SendQueryVipWheelReq()
    {
        CLPF.QueryVipWheelReq req = new CLPF.QueryVipWheelReq();
        netComponent.asyncRequest<CLPF.QueryVipWheelAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_VIPLOTTERY_QUERY, this, rsp);
        } );
    }

    /// <summary>
    /// 执行VIP抽奖请求
    /// </summary>
    public void SendActVipWheelReq()
    {
        CLPF.ActVipWheelReq req = new CLPF.ActVipWheelReq();
        netComponent.asyncRequest<CLPF.ActVipWheelAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_VIPLOTTERY_ACT, this, rsp);
         } );
    }

    /// <summary>
    /// 获取排行榜请求
    /// </summary>
    /// <param name="rank_type">排行榜类型 1金币榜 2弹头榜</param>
    public void SendGetRankListReq(int rankType)
    {
        CLPF.GetRankListReq req = new CLPF.GetRankListReq();
        req.RankType = rankType;
        netComponent.asyncRequest<CLPF.GetRankListAck>(req, rsp =>
         {
             switch (rsp.Errcode)
             {
                 case 0:
                     //var para = new object[1] { rankType };
                     MessageCenter.Instance.SendMessage(MsgType.NET_RANKINFO_ACK, this, rsp, new Dictionary<string, object>()
                     {
                         {"rankType",rankType}
                     });
                     break;
                 default:
                     //MessageCenter.Instance.SendMessage(MsgType.CALL_LUA, "CreateHintMessageByResponseProtocol", rsp);
                     break;
             }
         } );
    }

    /// <summary>
    /// 比赛排行榜请求
    /// </summary>
    /// <param name="matchType">排行榜类型 1免费赛 2大奖赛</param>
    public void SendMatchRankReq(int matchType)
    {
        CLFM.MatchRankReq req = new CLFM.MatchRankReq();
        req.MatchType = matchType;
        netComponent.asyncRequest<CLFM.MatchRankAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_MATCHRANK, this, rsp, new Dictionary<string, object>()
            {
                {"matchType",matchType}
            });
        });
    }

    /// <summary>
    /// 加入比赛请求
    /// </summary>
    public void SendJoinMatchReq()
    {
        CLFR.JoinMatchReq req = new CLFR.JoinMatchReq();
        netComponent.asyncRequest<CLFR.JoinMatchAck>(req, rsp =>
        {
            //FishingRoomController.ProcessJoinMatchAck(rsp);
        });
    }

    /// <summary>
    /// 查询所有邮件ID请求
    /// </summary>
    public void SendQueryAllMailId()
    {
        CLPF.MailQueryAllIdsReq req = new CLPF.MailQueryAllIdsReq();
        netComponent.asyncRequest<CLPF.MailQueryAllIdsAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_QUERY_ALL_MAIL, this, rsp);
         } );
    }

    /// <summary>
    /// 批量邮件内容请求
    /// </summary>
    public void SendMailBatchQueryContentReq(int[] reqIds, string language = "CN")
    {
        CLPF.MailBatchQueryContentReq req = new CLPF.MailBatchQueryContentReq();
        //req.len = reqIds.Length;
        req.Array.AddRange( reqIds);
        req.Language = language;
        netComponent.asyncRequest<CLPF.MailBatchQueryContentAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_MAIL_CONTENT_ACK, this, rsp);
        } );
    }

    /// <summary>
    /// 查看邮件请求
    /// </summary>
    public void SendMailAccessReq(int mailId)
    {
        CLPF.MailAccessReq req = new CLPF.MailAccessReq();
        req.MailId = mailId;
        netComponent.asyncRequest<CLPF.MailAccessAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_MAIL_ACCESS_ACK, this, rsp, new Dictionary<string, object>()
            {
                {"accessId",mailId}
            });
         } );
    }

    /// <summary>
    /// 领取邮件物品请求
    /// </summary>
    public void SendMailFetchItem(int mailId)
    {
        CLPF.MailFetchItemReq req = new CLPF.MailFetchItemReq();
        req.MailId = mailId;
        netComponent.asyncRequest<CLPF.MailFetchItemAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_MAIL_FETCH_ACK, this, rsp, new Dictionary<string, object>()
                    {
                        {"fetchId",mailId}
                    });
        } );
    }

    /// <summary>
    /// 删除邮件请求
    /// </summary>
    public void SendMailRemoveReq(sbyte removeType, int[] remove_ids)
    {
        CLPF.MailRemoveReq req = new CLPF.MailRemoveReq();
        req.RemoveType = removeType;
        req.RemoveIds.AddRange( remove_ids);
        //req.remove_ids = remove_ids;
        netComponent.asyncRequest<CLPF.MailRemoveAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_MAIL_REMOVE_ACK, this, rsp);
        } );
    }

    //#region 公会
    /// <summary>
    /// 获取公会推荐列表
    /// </summary>
    /// <param name="operationType">操作类型 1打开 2刷新</param>
    public void SendGuildQueryRecommendListReq(int operationType)
    {
        CLPF.GuildQueryRecommendListReq req = new CLPF.GuildQueryRecommendListReq();
        netComponent.asyncRequest<CLPF.GuildQueryRecommendListAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_RECOMMENDLIST_ACK, this, rsp, new Dictionary<string, object>
            {
                { "OperationType",operationType}
            });
        } );
    }

    /// <summary>
    /// 加入公会
    /// </summary>
    /// <param name="guildId">公会id</param>
    public void SendGuildJoinReq(int guildId)
    {
        CLPF.GuildJoinReq req = new CLPF.GuildJoinReq();
        req.GuildId = guildId;
        netComponent.asyncRequest<CLPF.GuildJoinAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_JOIN_ACK, this, rsp, new Dictionary<string, object>
            {
                { "GuildId",guildId}
            });
        } );
    }

    /// <summary>
    /// 快读加入公会
    /// </summary>
    public void SendGuildQuickJoinReq()
    {
        CLPF.GuildQuickJoinReq req = new CLPF.GuildQuickJoinReq();
        netComponent.asyncRequest<CLPF.GuildQuickJoinAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_QUICKJOIN_ACK, this, rsp);
        } );
    }

    /// <summary>
    /// 查找公会
    /// </summary>
    /// <param name="guildId">公会id</param>
    public void SendGuildSearchReq(int guildId)
    {
        CLPF.GuildSearchReq req = new CLPF.GuildSearchReq();
        req.GuildId = guildId;
        netComponent.asyncRequest<CLPF.GuildSearchAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_SEARCH_ACK, this, rsp);
        } );
    }

    /// <summary>
    /// 创建公会
    /// </summary>
    /// <param name="guildName">公会名</param>
    /// <param name="badge">公会图标</param>
    /// <param name="userLevelLimit">限制玩家等级</param>
    /// <param name="vipLevelLimit">限制玩家vip等级</param>
    /// <param name="allowAutoJoin">是否允许自动加入</param>
    public void SendGuildCreateReq(string guildName,int badge, int userLevelLimit,int vipLevelLimit,sbyte allowAutoJoin)
    {
        CLPF.GuildCreateReq req = new CLPF.GuildCreateReq();
        req.Name = guildName;
        req.Icon = badge;
        req.UserLevelLimit = userLevelLimit;
        req.VipLevelLimit = vipLevelLimit;
        req.AllowAutoJoin = allowAutoJoin == 1;
        netComponent.asyncRequest<CLPF.GuildCreateAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_CREATE_ACK, this, rsp);
        } );

    }

    /// <summary>
    /// 获取公会仓库信息请求
    /// </summary>
    /// <param name="operationType">操作类型 1打开 2刷新</param>
    public void SendGuildBagQueryInfoReq(int operationType)
    {
        CLPF.GuildBagQueryInfoReq req = new CLPF.GuildBagQueryInfoReq();
        netComponent.asyncRequest<CLPF.GuildBagQueryInfoAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_CUILD_BAGQUERY_ACK, this, rsp, new Dictionary<string, object>
            {
                { "OperationType",operationType}
            });
        });
    }

    /// <summary>
    /// 公会仓库日志信息
    /// </summary>
    /// <param name="Page">日志页数</param>
    /// <param name="operationType">操作类型 1打开 2刷新</param>
    public void SendGuildBagQueryLogReq(int page, int operationType)
    {
        CLPF.GuildBagQueryLogReq req = new CLPF.GuildBagQueryLogReq();
        req.PageIndex = page;
        netComponent.asyncRequestWithLock<CLPF.GuildBagQueryLogAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_BAGQUERYLOG_ACK, this, rsp, new Dictionary<string, object>
            {
                {"OperationType",operationType },
                {"Page", page}
            });
        });
    }

    /// <summary>
    /// 捐赠物品
    /// </summary>
    /// <param name="info">捐赠物品信息</param>
    public void SendGuildBagStoreItemReq(ItemInfo info)
    {
        CLPF.GuildBagStoreItemReq req = new CLPF.GuildBagStoreItemReq();
        var item = new CLPF.ItemInfo();
        item.ItemId = info.ItemID;
        item.ItemSubId = info.ItemSubID;
        item.ItemCount = info.ItemCount;
        req.Item = item;
        netComponent.asyncRequest<CLPF.GuildBagStoreItemAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_BAGSTORE_ACK, this, rsp, new Dictionary<string, object>
            {
                { "ItemInfo",info}
            });
        });
    }

    /// <summary>
    /// 分配物品
    /// </summary>
    /// <param name="info">分配物品信息</param>
    /// <param name="userId">分配给某人的id</param>
    public void SendGuildBagFetchItemReq(ItemInfo info,int userId)
    {
        CLPF.GuildBagFetchItemReq req = new CLPF.GuildBagFetchItemReq();
        var item = new CLPF.ItemInfo();
        item.ItemId = info.ItemID;
        item.ItemSubId = info.ItemSubID;
        item.ItemCount = info.ItemCount;
        req.Item = item;
        req.UserId = userId;
        netComponent.asyncRequest<CLPF.GuildBagFetchItemAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_BAGFETCH_ACK, this, rsp, new Dictionary<string, object>
            {
                { "ItemInfo",info},
                { "UserId",userId}
            });
        });
    }


    /// <summary>
    /// 获取公会信息请求
    /// </summary>
    public void SendGuildQueryInfoReq(bool isOpenUI)
    {
        CLPF.GuildQueryInfoReq req = new CLPF.GuildQueryInfoReq();
        netComponent.asyncRequest<CLPF.GuildQueryInfoAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_QUERYINFO_ACK, this, rsp, new Dictionary<string, object>
                     {
                         {"isOpenUI",isOpenUI}
                     });
         } );
    }

    /// <summary>
    /// 获取公会成员信息请求
    /// </summary>
    public void SendGuildQueryMembersReq(int pageIndex)
    {
        CLPF.GuildQueryMembersReq req = new CLPF.GuildQueryMembersReq();
        req.PageIndex = pageIndex;
        netComponent.asyncRequest<CLPF.GuildQueryMembersAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_QUERY_MEMBERS_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 公会玩家信息查询请求
    /// </summary>
    public void SendGuildMemberQueryReq(int userId)
    {
        CLPF.GuildMemberQueryReq req = new CLPF.GuildMemberQueryReq();
        req.UserId = userId;
        netComponent.asyncRequest<CLPF.GuildMemberQueryAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_MEMBER_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 公会踢出成员请求
    /// </summary>
    /// <param name="idArr">踢出的成员数组</param>
    public void SendGuildKickMemberReq(int[] idArr)
    {
        CLPF.GuildKickMemberReq req = new CLPF.GuildKickMemberReq();
        //req.id = idArr.Length;
        req.IdArray.AddRange(idArr);
        netComponent.asyncRequest<CLPF.GuildKickMemberAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_KICK_ACK, this, rsp);
        } );
    }

    /// <summary>
    /// 获取公会申请列表
    /// </summary>
    public void SendGuildQueryJoinListReq()
    {
        CLPF.GuildQueryJoinListReq req = new CLPF.GuildQueryJoinListReq();
        netComponent.asyncRequest<CLPF.GuildQueryJoinListAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_QUERYJOIN_ACK, this, rsp);
        } );
    }

    /// <summary>
    /// 处理公会加入请求
    /// </summary>
    /// <param name="id">玩家Id</param><param name="agree">是否同意加入 1是0否</param>
    public void SendGuildHandleJoinReq(int id, int agree)
    {
        CLPF.GuildHandleJoinReq req = new CLPF.GuildHandleJoinReq();
        req.UserId = id;
        req.Agree = agree == 1;
        netComponent.asyncRequest<CLPF.GuildHandleJoinAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_HANDLEJOIN_ACK, this, rsp);
         } );
    }

    /// <summary>
    /// 退出公会请求
    /// </summary>
    public void SendGuildExitReq()
    {
        CLPF.GuildExitReq req = new CLPF.GuildExitReq();
        netComponent.asyncRequest<CLPF.GuildExitAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_EXIT_ACK, this, rsp);
         } );
    }

    /// <summary>
    /// 修改公会信息请求
    /// </summary>
    public void SendGuildModifyInfoReq(Dictionary<string, object> data)
    {
        CLPF.GuildModifyInfoReq req = new CLPF.GuildModifyInfoReq();
        req.Name = data["name"].ToString();
        req.Desc = data["desc"].ToString();
        req.Icon = int.Parse(data["icon"].ToString());
        req.UserLevelLimit = int.Parse(data["user_level_limit"].ToString());
        req.VipLevelLimit = int.Parse(data["vip_level_limit"].ToString());
        req.AllowAutoJoin = sbyte.Parse(data["allow_auto_join"].ToString()) == 1;
        netComponent.asyncRequest<CLPF.GuildModifyInfoAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_MODIFYINFO_ACK, this, rsp);
         } );
    }

    /// <summary>
    /// 公会升级请求
    /// </summary>
    public void SendGuildUpgradeReq()
    {
        CLPF.GuildUpgradeReq req = new CLPF.GuildUpgradeReq();
        netComponent.asyncRequest<CLPF.GuildUpgradeAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_UPGRADE_ACK, this, rsp);
         } );
    }

    /// <summary>
    /// 获取公会红包信息
    /// </summary>
    public void SendGuildQueryRedPacketInfo()
    {
        CLPF.GuildQueryRedPacketInfoReq req = new CLPF.GuildQueryRedPacketInfoReq();
        netComponent.asyncRequest<CLPF.GuildQueryRedPacketInfoAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_QUERY_REDPACKETINFO_ACK, this, rsp);
         });
    }

    /// <summary>
    /// 获取公会红包排行榜信息
    /// </summary>
    public void SendGuildQueryRedPacketRankReq()
    {
        CLPF.GuildQueryRedPacketRankReq req = new CLPF.GuildQueryRedPacketRankReq();
        netComponent.asyncRequest<CLPF.GuildQueryRedPacketRankAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_QUERY_REDPACKETRANK_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 公会抢红包请求
    /// </summary>
    public void SendGuildActRedPacketReq()
    {
        CLPF.GuildActRedPacketReq req = new CLPF.GuildActRedPacketReq();
        netComponent.asyncRequest<CLPF.GuildActRedPacketAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_ACTREDPACKET_ACK, this, rsp);
         });
    }

    /// <summary>
    /// 查询会长福利
    /// </summary>
    public void SendGuildQueryWelfareReq()
    {
        CLPF.GuildQueryWelfareReq req = new CLPF.GuildQueryWelfareReq();
        netComponent.asyncRequest<CLPF.GuildQueryWelfareAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_QUERYWELFARE_ACK, this, rsp);
         } );
    }

    /// <summary>
    /// 领取会长福利
    /// </summary>
    public void SendGuildFetchWelfareReq()
    {
        CLPF.GuildFetchWelfareReq req = new CLPF.GuildFetchWelfareReq();
        netComponent.asyncRequest<CLPF.GuildFetchWelfareAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUILD_FETCHWELFARE_ACK, this, rsp);
        });
    }
    //#endregion

    /// <summary>
    /// 心跳包
    /// </summary>
    public IEnumerator SendTKeepAlive()
    {
        while (true)
        {
            yield return new WaitForSeconds(10.0f);
            CLGT.KeepAliveReq alive = new CLGT.KeepAliveReq();
            netComponent.Send(alive);
        }
    }

    /// <summary>
    /// 断线重连
    /// </summary>
    public IEnumerator TryReconnet() {
        while (true) {
            //MessageCenter.Instance.SendMessage(MsgType.CALL_LUA, "SendNetConnect", SysDefines.LoginType);
          
            yield return new WaitForSeconds(8.0f);
        }
    }

    /// <summary>
    /// 领取月卡奖励
    /// </summary>
    public void SendMonthCardFetchRewardReq()
    {
        CLPF.MonthCardFetchRewardReq req = new CLPF.MonthCardFetchRewardReq();
        netComponent.asyncRequest<CLPF.MonthCardFetchRewardAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_MONTHCARD_FETCH_ACK, this, rsp);
         });
    }

    /// <summary>
    /// 查询每日充值请求
    /// </summary>
    public void SendRechargeDailyQueryReq()
    {
        CLPF.RechargeDailyQueryReq req = new CLPF.RechargeDailyQueryReq();
        netComponent.asyncRequest<CLPF.RechargeDailyQueryAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_RECHARGEDAILY_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 领取救济金请求
    /// </summary>
    public void SendReliefGoldFetchReq()
    {
        CLPF.ReliefGoldFetchReq req = new CLPF.ReliefGoldFetchReq();
        netComponent.asyncRequest<CLPF.ReliefGoldFetchAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_RELIEFGOLD_FETCH_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询任务状态
    /// </summary>
    public void SendTaskQueryReq()
    {
        CLPF.TaskQueryReq req = new CLPF.TaskQueryReq();
        netComponent.asyncRequest<CLPF.TaskQueryAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_TASK_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询新手成就任务状态
    /// </summary>
    public void SendTaskAchieveQueryReq()
    {
        CLPF.TaskAchieveQueryInfoReq req = new CLPF.TaskAchieveQueryInfoReq();
        netComponent.asyncRequest<CLPF.TaskAchieveQueryInfoAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_TASK_ACHIEVE_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 领取任务奖励请求
    /// </summary>
    public void SendTaskFetchTaskRewardsReq(int taskId)
    {
        CLPF.TaskFetchTaskRewardsReq req = new CLPF.TaskFetchTaskRewardsReq();
        req.TaskId = taskId;
        netComponent.asyncRequest<CLPF.TaskFetchTaskRewardsAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_TASK_FETCH_ACK, this, rsp, new Dictionary<string, object>()
            {
                {"taskId", taskId},
            });
        });
    }

    /// <summary>
    /// 领取成就任务奖励请求
    /// </summary>
    public void SendTaskAchieveFetchRewardReq(int taskId)
    {
        CLPF.TaskAchieveFetchRewardReq req = new CLPF.TaskAchieveFetchRewardReq();
        req.TaskAchieveId = taskId;
        netComponent.asyncRequest<CLPF.TaskAchieveFetchRewardAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_TASK_ACHIEVE_FETCH_ACK, this, rsp, new Dictionary<string, object>()
            {
                {"taskId", taskId},
            });
        });
    }

    /// <summary>
    /// 领取活跃度奖励请求
    /// </summary>
    public void SendTaskFetchActiveRewardsReq(int taskId)
    {
        CLPF.TaskFetchActiveRewardsReq req = new CLPF.TaskFetchActiveRewardsReq();
        req.ActiveId = taskId;
        netComponent.asyncRequest<CLPF.TaskFetchActiveRewardsAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_TASK_ACTIVE_FETCH_ACK, this, rsp, new Dictionary<string, object>()
            {
                {"taskId", taskId},
            });
        });
    }

    /// <summary>
    /// 摇数字获取信息请求
    /// </summary>
    public void SendShakeNumberQueryInfoReq()
    {
        CLPF.ShakeNumberQueryInfoReq req = new CLPF.ShakeNumberQueryInfoReq();
        netComponent.asyncRequest<CLPF.ShakeNumberQueryInfoAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_SHAKENUMBER_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 摇数字请求
    /// </summary>
    public void SendShakeNumberActReq()
    {
        CLPF.ShakeNumberActReq req = new CLPF.ShakeNumberActReq();
        netComponent.asyncRequest<CLPF.ShakeNumberActAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_SHAKENUMBER_ACT_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 领取摇到的金币奖励请求
    /// </summary>
    public void SendShakeNumberFetchRewardReq()
    {
        CLPF.ShakeNumberFetchRewardReq req = new CLPF.ShakeNumberFetchRewardReq();
        netComponent.asyncRequest<CLPF.ShakeNumberFetchRewardAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_SHAKENUMBER_FETCHREWARD_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 领取摇到数字后的宝箱礼包请求
    /// </summary>
    /// <param name="day">第几天的宝箱？范围：0-6</param>
    public void SendShakeNumberFetchBoxRewardReq(int day)
    {
        CLPF.ShakeNumberFetchBoxRewardReq req = new CLPF.ShakeNumberFetchBoxRewardReq();
        req.Day = day;
        netComponent.asyncRequest<CLPF.ShakeNumberFetchBoxRewardAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_SHAKENUMBER_FETCHBOX_ACK, this, rsp, new Dictionary<string, object>()
            {
                {"day", day},
            });
        });
    }

    /// <summary>
    /// 福利猪获取信息请求
    /// </summary>
    public void SendWelfarePigQueryReq()
    {
        CLPF.WelfarePigQueryInfoReq req = new CLPF.WelfarePigQueryInfoReq();
        netComponent.asyncRequest<CLPF.WelfarePigQueryInfoAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_WELFAREPIG_QUERY_ACK, this, rsp);
         });
    }

    /// <summary>
    /// 福利猪领取每日锤子碎片请求
    /// </summary>
    public void SendWelfarePigFetchMaterialReq()
    {
        CLPF.WelfarePigFetchMaterialReq req = new CLPF.WelfarePigFetchMaterialReq();
        netComponent.asyncRequest<CLPF.WelfarePigFetchMaterialAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_WELFAREPIG_FETCHMATERIAL_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 福利猪砸罐子请求
    /// </summary>
    public void SendWelfarePigBrokenReq()
    {
        CLPF.WelfarePigBrokenReq req = new CLPF.WelfarePigBrokenReq();
        netComponent.asyncRequest<CLPF.WelfarePigBrokenAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_WELFAREPIG_BROKEN_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 福利猪搜一搜请求
    /// </summary>
    public void SendWelfarePigSearchReq()
    {
        CLPF.WelfarePigSearchReq req = new CLPF.WelfarePigSearchReq();
        netComponent.asyncRequest<CLPF.WelfarePigSearchAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_WELFAREPIG_SEARCH_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询投资炮倍信息请求
    /// </summary>
    public void SendInvestGunQueryInfoReq()
    {
        CLPF.InvestGunQueryInfoReq req = new CLPF.InvestGunQueryInfoReq();
        netComponent.asyncRequest<CLPF.InvestGunQueryInfoAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_INVEST_GUN_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 领取投资炮倍奖励请求
    /// </summary>
    public void SendInvestGunFetchRewardReq(int gunValue)
    {
        CLPF.InvestGunFetchRewardReq req = new CLPF.InvestGunFetchRewardReq();
        req.GunValue = gunValue;
        netComponent.asyncRequest<CLPF.InvestGunFetchRewardAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_INVEST_GUN_FETCH_ACK, this, rsp, new Dictionary<string, object>()
            {
                {"gunValue", gunValue},
            });
        });
    }

    /// <summary>
    /// 查询出海保险信息请求
    /// </summary>
    public void SendInvestCostQueryInfoReq()
    {
        CLPF.InvestCostQueryInfoReq req = new CLPF.InvestCostQueryInfoReq();
        netComponent.asyncRequest<CLPF.InvestCostQueryInfoAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_INVEST_COST_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 领取出海保险奖励请求
    /// </summary>
    public void SendInvestCostFetchRewardReq(int rewardId)
    {
        CLPF.InvestCostFetchRewardReq req = new CLPF.InvestCostFetchRewardReq();
        req.RewardId = rewardId;
        netComponent.asyncRequest<CLPF.InvestCostFetchRewardAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_INVEST_COST_FETCH_ACK, this, rsp, new Dictionary<string, object>()
            {
                {"rewardId", rewardId},
            });
        });
    }

    /// <summary>
    /// 查询常用的真实地址请求
    /// </summary>
    public void SendRealGoodsQueryAddressReq()
    {
        CLPF.RealGoodsQueryAddressReq req = new CLPF.RealGoodsQueryAddressReq();
        netComponent.asyncRequest<CLPF.RealGoodsQueryAddressAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_REALGOODS_ADD_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 实物奖励下单请求
    /// </summary>
    public void SendRealGoodsCreateOrderReq(int goodsId, string name, string phone, string address)
    {
        CLPF.RealGoodsCreateOrderReq req = new CLPF.RealGoodsCreateOrderReq();
        req.GoodsId = goodsId;
        req.RealName = name;
        req.Phone = phone;
        req.Address = address;
        netComponent.asyncRequest<CLPF.RealGoodsCreateOrderAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_REALGOODS_CREATEORDER_ACK, this, rsp, new Dictionary<string, object>()
            {
                {"GoodsId", goodsId},
            });
        });
    }

    /// <summary>
    /// 查询实物奖励兑换纪录请求
    /// </summary>
    public void SendRealGoodsQueryExchangeLogReq()
    {
        CLPF.RealGoodsQueryExchangeLogReq req = new CLPF.RealGoodsQueryExchangeLogReq();
        netComponent.asyncRequest<CLPF.RealGoodsQueryExchangeLogAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_REALGOODS_LOG_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询已完成的新手引导标记数组请求
    /// </summary>
    public void SendGuideDataQueryReq()
    {
        CLPF.GuideDataQueryReq req = new CLPF.GuideDataQueryReq();
        netComponent.asyncRequest<CLPF.GuideDataQueryAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_GUIDE_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 上报完成了某个新手引导标记
    /// </summary>
    public void SendGuideDataActRpt(int flag)
    {
        CLPF.GuideDataActRpt rpt = new CLPF.GuideDataActRpt();
        rpt.Flag = flag;
        netComponent.Send(rpt);
    }

    /// <summary>
    /// 使用弹头锁定鱼请求
    /// </summary>
    /// <param name="bombInfo">弹头信息</param>
    /// <param name="fishId">鱼ID</param>
    public void SendWarheadLockReq(ItemInfo bombInfo, int fishId)
    {
        CLFR.WarheadLockReq req = new CLFR.WarheadLockReq();
        req.ItemId = bombInfo.ItemID;
        req.ItemSubId = bombInfo.ItemSubID;
        req.ItemCount = (int)bombInfo.ItemCount;
        req.FishId = fishId;
        netComponent.asyncRequest<CLFR.WarheadLockAck>(req, rsp =>
         {
             MessageCenter.Instance.SendMessage(MsgType.NET_WARHEAD_LOCK_ACK, this, rsp);
         });
    }

    /// <summary>
    /// 弹头爆炸请求
    /// </summary>
    public void SendWarheadBoomReq()
    {
        CLFR.WarheadBoomReq req = new CLFR.WarheadBoomReq();
        netComponent.asyncRequest<CLFR.WarheadBoomAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_WARHEAD_BOOM_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询房间总人数请求
    /// </summary>
    public void SendRoomUserCountSummaryReq()
    {
        CLFM.RoomUserCountSummaryReq req = new CLFM.RoomUserCountSummaryReq();
        req.SiteId = 1;
        netComponent.asyncRequest<CLFM.RoomUserCountSummaryAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_ROOM_USERCOUNT_SUMMARY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询房间详细人数请求
    /// </summary>
    public void SendRoomUserCountDetailReq(int configId, int startId, int count)
    {
        CLFM.RoomUserCountDetailReq req = new CLFM.RoomUserCountDetailReq();
        req.SiteId = 1;
        req.ConfigId = configId;
        req.StartRoomId = startId;
        req.Count = count;
        netComponent.asyncRequest<CLFM.RoomUserCountDetailAck>(req, rsp =>
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_ROOM_USERCOUNT_DETAIL_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询房间内获取到的积分请求
    /// </summary>
    public void SendIntegralGainQueryReq()
    {
        CLFR.IntegralGainQueryReq req = new CLFR.IntegralGainQueryReq();
        netComponent.asyncRequest<CLFR.IntegralGainQueryAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_INTEGRAL_GAIN_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 领取新手初始礼包请求
    /// </summary>
    public void SendFirstPackageFetchReq()
    {
        CLPF.FirstPackageFetchReq req = new CLPF.FirstPackageFetchReq();
        netComponent.asyncRequest<CLPF.FirstPackageFetchAck>(req, rsp => 
        {
            MessageCenter.Instance.SendMessage(MsgType.NET_FIRST_PACKAGE_FETCH_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 倍击倍数改变请求
    /// </summary>
    public void SendMultipleHitChangeReq(int value)
    {
        CLFR.MultipleHitChangeReq req = new CLFR.MultipleHitChangeReq();
        req.Value = value;
        netComponent.asyncRequest<CLFR.MultipleHitChangeAck>(req, rsp =>
         {
             //MessageCenter.Instance.SendMessage(MsgType.NET_MUILTIPLE_HIT_CHANGE_ACK, this, rsp);
         });
    }

    /// <summary>
    /// boss下次出现的时间请求
    /// </summary>
    public void SendBossNextAppearTimeReq()
    {
        CLFR.BossNextAppearTimeReq req = new CLFR.BossNextAppearTimeReq();
        netComponent.asyncRequest<CLFR.BossNextAppearTimeAck>(req, rsp => 
        {
            ////MessageCenter.Instance.SendMessage(MsgType.NET_BOSS_NEXT_APPEAR_TIME_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 获取Boss排行榜请求
    /// </summary>
    public void SendBossRankReq()
    {
        CLFR.BossRankReq req = new CLFR.BossRankReq();
        netComponent.asyncRequest<CLFR.BossRankAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_BOSS_RANK_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 激活码领取奖励请求
    /// </summary>
    public void SendCdkeyFetchRewardReq(string code)
    {
        CLPF.CdkeyFetchRewardReq req = new CLPF.CdkeyFetchRewardReq();
        req.Code = code;
        netComponent.asyncRequest<CLPF.CdkeyFetchRewardAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_CDKEY_FETCH_REWARD_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 账号绑定状态请求
    /// </summary>
    public void SendAccountBindStateReq()
    {
        CLPF.AccountBindStateReq req = new CLPF.AccountBindStateReq();
        netComponent.asyncRequest<CLPF.AccountBindStateAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_ACCOUNT_BIND_STATE_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 账号手机绑定请求
    /// </summary>
    public void SendAccountPhoneBindReq(string phone, string smsAppKey, string smsZone, string smsCode, string password)
    {
        CLPF.AccountPhoneBindReq req = new CLPF.AccountPhoneBindReq();
        req.Phone = phone;
        req.SmsAppKey = smsAppKey;
        req.SmsZone = smsZone;
        req.SmsCode = smsCode;
        req.Password = password;
        //req.SmsChannel = SysDefines.SmsChannel;
        netComponent.asyncRequest<CLPF.AccountPhoneBindAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_ACCOUNT_PHONE_BIND_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    { "Phone", phone },
            //});
        });
    }

    /// <summary>
    /// 账号手机更换请求1
    /// </summary>
    public void SendAccountPhoneChange1Req(string phone, string smsAppKey, string smsZone, string smsCode)
    {
        CLPF.AccountPhoneChange1Req req = new CLPF.AccountPhoneChange1Req();
        req.Phone = phone;
        req.SmsAppKey = smsAppKey;
        req.SmsZone = smsZone;
        req.SmsCode = smsCode;
        //req.SmsChannel = SysDefines.SmsChannel;
        //netComponent.asyncRequest<CLPF.AccountPhoneChange1Ack>(req, rsp => 
        //{
        //    MessageCenter.Instance.SendMessage(MsgType.NET_ACCOUNT_PHONE_CHANGE1_ACK, this, rsp);
        //});
    }

    /// <summary>
    /// 账号手机更换请求2
    /// </summary>
    public void SendAccountPhoneChange2Req(string phone, string smsAppKey, string smsZone, string smsCode)
    {
        CLPF.AccountPhoneChange2Req req = new CLPF.AccountPhoneChange2Req();
        req.NewPhone = phone;
        req.SmsAppKey = smsAppKey;
        req.SmsZone = smsZone;
        req.SmsCode = smsCode;
        //req.SmsChannel = SysDefines.SmsChannel;
        //netComponent.asyncRequest<CLPF.AccountPhoneChange2Ack>(req, rsp =>
        //{
        //    MessageCenter.Instance.SendMessage(MsgType.NET_ACCOUNT_PHONE_CHANGE2_ACK, this, rsp, new Dictionary<string, object>()
        //    {
        //        { "Phone", phone },
        //    });
        //});
    }

    /// <summary>
    /// 账号统一绑定请求
    /// </summary>
    public void SendAccountUniformBindReq(string phone, string smsAppKey, string smsZone, string smsCode, byte type, string token)
    {
        CLPF.AccountUniformBindReq req = new CLPF.AccountUniformBindReq();
        req.Phone = phone;
        req.SmsAppKey = smsAppKey;
        req.SmsZone = smsZone;
        req.SmsCode = smsCode;
        req.Type = type;
        req.Token = token;
        //req.SmsChannel = SysDefines.SmsChannel;
        //netComponent.asyncRequest<CLPF.AccountUniformBindAck>(req, rsp => 
        //{
        //    MessageCenter.Instance.SendMessage(MsgType.NET_ACCOUNT_UNIFORM_BIND_ACK, this, rsp, new Dictionary<string, object>()
        //    {
        //        { "Type", type },
        //    });
        //});
    }

    /// <summary>
    /// 账号统一解绑请求
    /// </summary>
    public void SendAccountUniformUnbindReq(string phone, string smsAppKey, string smsZone, string smsCode, byte type)
    {
        CLPF.AccountUniformUnbindReq req = new CLPF.AccountUniformUnbindReq();
        req.Phone = phone;
        req.SmsAppKey = smsAppKey;
        req.SmsZone = smsZone;
        req.SmsCode = smsCode;
        req.Type = type;
        //req.SmsChannel = SysDefines.SmsChannel;
        //netComponent.asyncRequest<CLPF.AccountUniformUnbindAck>(req, rsp => 
        //{
        //    MessageCenter.Instance.SendMessage(MsgType.NET_ACCOUNT_UNIFORM_UNBIND_ACK, this, rsp, new Dictionary<string, object>()
        //    {
        //        { "Type", type },
        //    });
        //});
    }

    /// <summary>
    /// 金库密码初始化请求 注意：该请求成功后，不用再进行密码验证功能了，可以直接进入金库界面
    /// </summary>
    public void SendBankPasswordInitReq(string password)
    {
        CLPF.BankPasswordInitReq req = new CLPF.BankPasswordInitReq();
        req.Password = password;
        netComponent.asyncRequest<CLPF.BankPasswordInitAck>(req, rsp => 
        {
            ////MessageCenter.Instance.SendMessage(MsgType.NET_BANK_PASSWORD_INIT_ACK, this, rsp, new Dictionary<string, object>()
            ////{
            ////    { "Password", password },
            ////});
        });
    }

    /// <summary>
    /// 金库密码验证请求
    /// </summary>
    public void SendBankPasswordVerifyReq(string password)
    {
        CLPF.BankPasswordVerifyReq req = new CLPF.BankPasswordVerifyReq();
        req.Password = password;
        netComponent.asyncRequest<CLPF.BankPasswordVerifyAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_BANK_PASSWORD_VERIFY_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    { "Password", password },
            //});
        });
    }

    /// <summary>
    /// 金库密码修改请求
    /// </summary>
    public void SendBankPasswordModifyReq(string oldPassword, string newPassword)
    {
        CLPF.BankPasswordModifyReq req = new CLPF.BankPasswordModifyReq();
        req.OriginPassword = oldPassword;
        req.NewPassword = newPassword;
        netComponent.asyncRequest<CLPF.BankPasswordModifyAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_BANK_PASSWORD_MODIFY_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    { "Password", newPassword },
            //});
        });
    }

    /// <summary>
    /// 金库密码重置请求 注意：该请求成功后，不用再进行密码验证功能了，可以直接进入金库界面
    /// </summary>
    public void SendBankPasswordResetReq(string phone, string smsAppKey, string smsZone, string smsCode, string password)
    {
        CLPF.BankPasswordResetReq req = new CLPF.BankPasswordResetReq();
        req.Phone = phone;
        req.SmsAppKey = smsAppKey;
        req.SmsZone = smsZone;
        req.SmsCode = smsCode;
        req.NewPassword = password;
        //req.SmsChannel = SysDefines.SmsChannel;
        //netComponent.asyncRequest<CLPF.BankPasswordResetAck>(req, rsp => 
        //{
        //    MessageCenter.Instance.SendMessage(MsgType.NET_BANK_PASSWORD_RESET_ACK, this, rsp, new Dictionary<string, object>()
        //    {
        //        { "Password", password },
        //    });
        //});
    }

    /// <summary>
    /// 金库物品查询请求
    /// </summary>
    public void SendBankItemQueryReq()
    {
        CLPF.BankItemQueryReq req = new CLPF.BankItemQueryReq();
        netComponent.asyncRequest<CLPF.BankItemQueryAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_BANK_ITEM_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 金库物品存入请求
    /// </summary>
    public void SendBankItemStoreReq(int itemId, int itemSubId, long count)
    {
        CLPF.BankItemStoreReq req = new CLPF.BankItemStoreReq();
        req.Item = new CLPF.ItemInfo();
        req.Item.ItemId = itemId;
        req.Item.ItemSubId = itemSubId;
        req.Item.ItemCount = count;
        netComponent.asyncRequest<CLPF.BankItemStoreAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_BANK_ITEM_STORE_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    { "Item", req.Item }
            //});
        });
    }

    /// <summary>
    /// 金库物品取出请求
    /// </summary>
    public void SendBankItemFetchReq(int itemId, int itemSubId, long count)
    {
        CLPF.BankItemFetchReq req = new CLPF.BankItemFetchReq();
        req.Item = new CLPF.ItemInfo();
        req.Item.ItemId = itemId;
        req.Item.ItemSubId = itemSubId;
        req.Item.ItemCount = count;
        netComponent.asyncRequest<CLPF.BankItemFetchAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_BANK_ITEM_FETCH_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    { "Item", req.Item }
            //});
        });
    }

    /// <summary>
    /// 金库物品赠送请求
    /// </summary>
    public void SendBankItemSendReq(int itemId, int itemSubId, long count, int userId)
    {
        CLPF.BankItemSendReq req = new CLPF.BankItemSendReq();
        req.Item = new CLPF.ItemInfo();
        req.Item.ItemId = itemId;
        req.Item.ItemSubId = itemSubId;
        req.Item.ItemCount = count;
        req.UserId = userId;
        netComponent.asyncRequest<CLPF.BankItemSendAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_BANK_ITEM_SEND_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    { "Item", req.Item }
            //});
        });
    }

    /// <summary>
    /// 金库物品日志查询请求
    /// </summary>
    public void SendBankItemLogQueryReq()
    {
        CLPF.BankItemLogQueryReq req = new CLPF.BankItemLogQueryReq();
        //netComponent.asyncRequest<CLPF.BankItemLogQueryAck>(req, rsp => 
        //{
        //    MessageCenter.Instance.SendMessage(MsgType.NET_BANK_ITEM_LOG_QUERY_ACK, this, rsp);
        //});
    }

    /// <summary>
    /// 查询玩家昵称请求
    /// </summary>
    public void SendPlayerNicknameQueryReq(int userId)
    {
        CLPF.PlayerNicknameQueryReq req = new CLPF.PlayerNicknameQueryReq();
        req.UserId = userId;
        //netComponent.asyncRequest<CLPF.PlayerNicknameQueryAck>(req, rsp => 
        //{
        //    MessageCenter.Instance.SendMessage(MsgType.NET_PLAYER_NICKNAME_QUERY_ACK, this, rsp);
        //});
    }

    /// <summary>
    /// 能量炮蓄力请求
    /// </summary>
    public void SendEnergyStoreReq()
    {
        CLFR.EnergyStoreReq req = new CLFR.EnergyStoreReq();
        //netComponent.asyncRequest<CLFR.EnergyStoreAck>(req, rsp => 
        //{
        //    FishingRoomController.ProcessEnergyStoreAck(rsp);
        //});
    }

    /// <summary>
    /// 能量炮发射请求
    /// </summary>
    public void SendEnergyShootReq(int angle, int[] idArray)
    {
        CLFR.EnergyShootReq req = new CLFR.EnergyShootReq();
        req.Angle = angle;
        //req.related_fish_len = (sbyte)idArray.Length;
        req.RelatedFishArray.AddRange(idArray);
        netComponent.asyncRequest<CLFR.EnergyShootAck>(req, rsp =>
        {
            //FishingRoomController.ProcessEnergyShootAck(rsp);
        });
    }

    /// <summary>
    /// 查询我的推广信息请求
    /// </summary>
    public void SendAgentQueryInfoReq()
    {
        CLPF.AgentQueryInfoReq req = new CLPF.AgentQueryInfoReq();
        netComponent.asyncRequest<CLPF.AgentQueryInfoAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_AGENT_QUERY_INFO_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询子账号数量请求
    /// </summary>
    public void SendAgentQuerySubAccountAmountReq()
    {
        CLPF.AgentQuerySubAccountAmountReq req = new CLPF.AgentQuerySubAccountAmountReq();
        netComponent.asyncRequest<CLPF.AgentQuerySubAccountAmountAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_AGENT_QUERY_SUB_AMOUNT_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 查询子账号的贡献列表请求
    /// </summary>
    public void SendAgentQueryContributionListReq(int page)
    {
        CLPF.AgentQueryContributionListReq req = new CLPF.AgentQueryContributionListReq();
        req.PageIndex = page;
        netComponent.asyncRequest<CLPF.AgentQueryContributionListAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_AGENT_QUERY_SUB_LIST_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    { "Page", page }
            //});
        });
    }

    /// <summary>
    /// 查询某个玩家详细贡献请求
    /// </summary>
    public void SendAgentQueryContributionUserReq(int userId, int page)
    {
        CLPF.AgentQueryContributionUserReq req = new CLPF.AgentQueryContributionUserReq();
        req.UserId = userId;
        req.PageIndex = page;
        netComponent.asyncRequest<CLPF.AgentQueryContributionUserAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_AGENT_QUERY_USER_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    { "UserId", userId },
            //    { "Page", page },
            //});
        });
    }

    /// <summary>
    /// 赠送邮件礼物请求
    /// </summary>
    public void SendCLPFMailGiftSendReq(int giftLength, CLPF.MailGiftData[] giftArray, int userId)
    {
        CLPF.MailGiftSendReq req = new CLPF.MailGiftSendReq();
        //req.gift_length = (sbyte)giftLength;
        req.GiftArray.AddRange(giftArray);
        req.DestUserId = userId;
        netComponent.asyncRequest<CLPF.MailGiftSendAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_MAIL_GIFT_SEND_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 礼物赠送日志查询请求
    /// </summary>
    public void SendCLPFMailGiftLogQueryReq()
    {
        CLPF.MailGiftLogQueryReq req = new CLPF.MailGiftLogQueryReq();
        netComponent.asyncRequest<CLPF.MailGiftLogQueryAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_MAIL_GIFT_LOG_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 聚宝盆游戏结算请求
    /// </summary>
    public void SendCLFRTreasureGameBalanceReq(int result_length, sbyte[] result_array)
    {
        CLFR.TreasureGameBalanceReq req = new CLFR.TreasureGameBalanceReq();
        //req.result_length = result_length;

        int[] result = new int[result_array.Length];

        for (int i = 0; i < result_array.Length; i++)
        {
            result[i] = (int)result_array[i];
        }

        req.ResultArray.AddRange(result);
        netComponent.asyncRequest<CLFR.TreasureGameBalanceAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_TREASURE_GAME_BALANCE_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 上次未结束的游戏查询请求
    /// </summary>
    public void SendLastGameQueryReq()
    {
        CLPF.LastGameQueryReq req = new CLPF.LastGameQueryReq();
        netComponent.asyncRequest<CLPF.LastGameQueryAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_LAST_GAME_QUERY_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 领取排行榜奖励请求
    /// </summary>
    public void SendRankRewardFetchReq(int rankType)
    {
        CLPF.RankRewardFetchReq req = new CLPF.RankRewardFetchReq();
        req.RankType = (sbyte)rankType;
        netComponent.asyncRequest<CLPF.RankRewardFetchAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_RANK_REWARD_FETCH_ACK, this, rsp, new Dictionary<string, object>()
            //         {
            //             {"rankType",rankType}
            //         });
        });
    }

    /// <summary>
    /// 弹头兑换魔力值请求
    /// </summary>
    public void SendMagicTradeInReq(int itemId, int itemSubId, long itemCount, long factor)
    {
        CLPF.MagicTradeInReq req = new CLPF.MagicTradeInReq();
        req.Item = new CLPF.ItemInfo();
        req.Item.ItemId = itemId;
        req.Item.ItemSubId = itemSubId;
        req.Item.ItemCount = itemCount;
        req.Factor = factor;
        netComponent.asyncRequest<CLPF.MagicTradeInAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_MAGIC_TRADE_IN_ACK, this, rsp, new Dictionary<string, object>()
            //         {
            //             {"ItemId",itemId},
            //             {"ItemSubId",itemSubId},
            //             {"Factor",factor},
            //         });
        });
    }

    /// <summary>
    /// 魔力值兑换弹头请求
    /// </summary>
    public void SendMagicTradeOutReq(long itemCount)
    {
        CLPF.MagicTradeOutReq req = new CLPF.MagicTradeOutReq();
        req.ItemCount = itemCount;
        netComponent.asyncRequest<CLPF.MagicTradeOutAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_MAGIC_TRADE_OUT_ACK, this, rsp, new Dictionary<string, object>()
            //{
            //    {"Count", itemCount}
            //});
        });
    }

    /// <summary>
    /// 弹头交换请求
    /// </summary>
    public void SendWarheadExchangeReq(int itemId, int itemSubId, long itemCount, int action)
    {
        CLPF.WarheadExchangeReq req = new CLPF.WarheadExchangeReq();
        req.Item = new CLPF.ItemInfo();
        req.Item.ItemId = itemId;
        req.Item.ItemSubId = itemSubId;
        req.Item.ItemCount = itemCount;
        req.Action = (sbyte)action;
        netComponent.asyncRequest<CLPF.WarheadExchangeAck>(req, rsp =>
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_WARHEAD_EXCHANGE_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 设置房间密码请求
    /// </summary>
    public void SendSetRoomPasswordReq(int password)
    {
        CLFR.SetRoomPasswordReq req = new CLFR.SetRoomPasswordReq();
        req.Password = password;
        netComponent.asyncRequest<CLFR.SetRoomPasswordAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_ROOM_SET_PASSWORD_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 发送邮件请求
    /// </summary>
    public void SendMailSendReq(int receiverId, string title, string content)
    {
        CLPF.MailSendReq req = new CLPF.MailSendReq();
        req.ReceiverId = receiverId;
        req.Title = title;
        req.Content = content;
        netComponent.asyncRequest<CLPF.MailSendAck>(req, rsp => 
        {
            //MessageCenter.Instance.SendMessage(MsgType.NET_MAIL_SEND_ACK, this, rsp);
        });
    }

    /// <summary>
    /// 号角轮盘能量兑换结果上报
    /// </summary>
    public void SendHornWheelResultRpt(int configId, long gunValue, int multiple, long currencyDelta, ItemInfo[] items)
    {
        CLFR.HornWheelResultRpt rpt = new CLFR.HornWheelResultRpt();
        rpt.FishConfigId = configId;
        rpt.GunValue = gunValue;
        rpt.Multiple = multiple;
        rpt.CurrencyDelta = currencyDelta;
        //rpt.item_len = (sbyte)items.Length;
        CLFR.ItemInfo[] Items = new CLFR.ItemInfo[items.Length];
        for (int i = 0; i < items.Length; i++)
        {
            var item = new CLFR.ItemInfo();
            item.ItemId = items[i].ItemID;
            item.ItemSubId = items[i].ItemSubID;
            item.ItemCount = items[i].ItemCount;
            Items[i] = item;
        }
        rpt.Items.AddRange(Items);
        netComponent.Send(rpt);
    }

    //#region 测试!!!
    //!!!测试用!!!召唤鱼潮
    public void SendFishTideForTestReq()
    {
        CLFR.FishTideForTestReq req = new CLFR.FishTideForTestReq();
        netComponent.asyncRequest<CLFR.FishTideForTestAck>(req, rsp =>
         {
             Debug.Log($"召唤鱼潮：{rsp.Errcode}");
         });
    }

    protected override void onApplicationQuit()
    {
        netComponent.Dispose();
    }
    //#endregion
}