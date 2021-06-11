

using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using System.Linq;

//
public class ItemInfo
{
    public int ItemID;
    public int ItemSubID;
    public long ItemCount;

    /// <summary>
    /// 构造物品
    /// </summary>
    /// <param name="item_id">物品类型ID</param>
    /// <param name="item_sub_id">物品子ID</param>
    /// <param name="item_count">物品数量</param>
    public ItemInfo(int item_id, int item_sub_id, long item_count)
    {
        ItemID = item_id;
        ItemSubID = item_sub_id;
        ItemCount = item_count;
    }
}

public class ItemUsingInfo
{
    public ItemInfo itemInfo;
    public int cooldown;
    public ulong endTime;
    public int seatId;

    public ItemUsingInfo(int item_id, int item_sub_id, long item_count, int cd, ulong end_time, int seat_id)
    {
        itemInfo = new ItemInfo(item_id, item_sub_id, item_count);
        cooldown = cd;
        endTime = end_time;
        seatId = seat_id;
    }
}

public class GamePlayer
{
    public int UserID;
    public string NickName;
    public EnumPlayerGenderType Gender;
    public int Head;
    public int HeadFrame;
    public int Level;
    public long LevelExp;
    public int VIPLevel;
    public long VIPLevelExp;
    public string Phone;
    public long Currency;
    public long BindCurrency;
    public long Diamond;
    public long integral;
    public List<ItemInfo> ItemList;
    public int IsChangeName;
    public int GuildId;
    //是否有未处理的申请
    public int GuildJoinListState;
    public long UnLockGun;
    public int GunId;
    public uint MonthCardExpireTime;
    public int MonthCardHasFetched;
    public int FinishFirstRecharge;
    public int ReliefFinishCount;
    public int HasUnReadMail;
    public int FetchedFirstPackage;

    public GamePlayer(CLGT.LoginAck ack)
    {
        UserID = ack.UserId;
        NickName = ack.Nickname;
        IsChangeName = ack.NicknameMdf?1:0;
        Gender = (EnumPlayerGenderType)ack.Gender;
        Head = ack.Head;
        HeadFrame = ack.HeadFrame;
        Level = ack.Level;
        LevelExp = ack.LevelExp;
        VIPLevel = ack.VipLevel;
        VIPLevelExp = ack.VipLevelExp;
        Phone = ack.Phone;
        Currency = ack.Currency;
        BindCurrency = ack.BindCurrency;
        Diamond = ack.Diamond;
        integral = ack.Integral;
        ItemList = new List<ItemInfo>();
        foreach (var item in ack.Items)
        {
            var t = new ItemInfo(item.ItemId, item.ItemSubId, item.ItemCount);
            var p = ItemList.Find(a => a.ItemID == t.ItemID && a.ItemSubID == t.ItemSubID);
            if (!ReferenceEquals(p, null))
                p.ItemCount = t.ItemCount;
            else
                ItemList.Add(t);
        }
        TimeHelper.SetServerTimestamp((ulong)ack.ServerTimestamp * 1000);



    }

    private bool _tryGetParameterFromJson<T>(JObject paramsContainer, string paramName, out T value)
    {
        bool success = true;
        value = default(T);
        try
        {
            JToken token = paramsContainer[paramName];
            if (token == null)
                throw new Exception("成员不存在");
            value = token.ToObject<T>();
        }
        catch (System.Exception ex)
        {
            UnityEngine.Debug.LogWarning($"解析LoginAck数据失败，'{paramName}':{ex.Message}");
            success = false;
        }
        return success;
    }

    public long Integral
    {
        get
        {
            return integral / SysDefines.ScoreViewPara;
        }
    }

    //设置金币
    public void SetCurrency(long currency)
    {
        if (Currency != currency)
        {
            var oldValue = Currency;
            Currency = currency;

            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_CURRENCY_CHANGED,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", currency},
                });
        }
    }

    //设置钻石
    public void SetDiamond(long diamond)
    {
        if (Diamond != diamond)
        {
            var oldValue = Diamond;
            Diamond = diamond;

            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_DIAMOND_CHANGED,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", diamond},
                });
        }
    }



    //获取背包中的道具
    public ItemInfo GetItem(int id, int subId)
    {
        var item = ItemList.Find(a => a.ItemID == id && a.ItemSubID == subId);
        return item;
    }

    //解锁最大炮倍数变化
    public void SetUnLockGun(long unLockGun, long delta)
    {
        if (UnLockGun != unLockGun)
        {
            var oldValue = UnLockGun;
            UnLockGun = unLockGun;

            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_UNLOCKGUN_CHANGED,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", unLockGun},
                    {"Delta", delta},
                });
        }
    }

    //切换炮台
    public void SwitchGun(int gunId)
    {
        if (GunId != gunId)
        {
            GunId = gunId;
        }
    }

    //资源强同步
    public void SyncResource(long diamond, long currency, long _integral)
    {
        if (Diamond != diamond)
            DeltaDiamond(diamond - Diamond);

        if (Currency != currency)
            DeltaCurrency(currency - Currency);

        if (integral != _integral)
            DeltaIntegral(_integral - integral);
    }

    //金币增量 0表示需要加 1表示不需要处理 默认大厅
    public void DeltaCurrency(long delta, int reason = 0)
    {
        if (0 != delta)
        {
            var oldValue = Currency;
            Currency += delta;
            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_CURRENCY_CHANGED,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", Currency},
                    {"Delta",    delta },
                    {"Reason",   reason},
                });
        }
    }

    /// <summary>
    /// 绑金增量
    /// </summary>
    /// <param name="delta">变化量</param>
    /// <param name="reason">0表示需要加 1表示不需要处理 默认大厅</param>
    public void DeltaBindCurrency(long delta,int reason = 0)
    {
        if (0!= delta)
        {
            var oldValue = BindCurrency;
            BindCurrency += delta;
            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_BINDCURRENCY_CHANGED,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", BindCurrency},
                    {"Delta",    delta },
                    {"Reason",   reason},
                });
        }
    }


    //钻石增量
    public void DeltaDiamond(long delta,int reason = 0)
    {
        if (0 != delta)
        {
            var oldValue = Diamond;
            Diamond += delta;
            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_DIAMOND_CHANGED,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", Diamond},
                    {"Delta",    delta},
                    {"Reason",   reason},
                });
        }
    }

    //积分增量
    public void DeltaIntegral(long delta)
    {
        if (0 != delta)
        {
            var oldValue = Integral;
            integral += delta;
            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_INTEGRAL_CHANGED,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", Integral},
                });
        }
    }

    //设置新头像
    public void SetNewHead(int headId)
    {
        if (Head != headId)
        {
            var oldValue = Head;
            Head = headId;
            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_HEADID,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", headId},
                });
        }
    }

    //设置新昵称
    public void SetNickName(string nickName)
    {
        if (!NickName.Equals(nickName))
        {
            var oldValue = NickName;
            NickName = nickName;
            IsChangeName = 1;
            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_NICKNAME,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"OldValue", oldValue},
                    {"NewValue", nickName},
                });
        }
    }

    //vip经验变化
    public void SetVipLevel(int vipLevel, long vipLevelExp)
    {
        var vipLevelChange = VIPLevel != vipLevel;
        VIPLevel = vipLevel;
        VIPLevelExp = vipLevelExp;
        MessageCenter.Instance.SendMessage(
            MsgType.CLIENT_PLAYER_VIPLEVEL,
            this,
            null,
            new Dictionary<string, object>()
            {
                {"VIPLevel", vipLevel},
                {"VIPLevelExp", vipLevelExp},
                {"VIPLevelChange", vipLevelChange},
            });
    }

    //公会ID变化
    public void SetGuildId(int id)
    {
        if (GuildId != id)
        {
            GuildId = id;
            MessageCenter.Instance.SendMessage(
                MsgType.CLIENT_PLAYER_GUILDID,
                this,
                null,
                new Dictionary<string, object>()
                {
                    {"NewValue", id},
                });
        }
    }

    //经验变化
    public void SetLevelExp(long exp)
    {
        LevelExp = exp;
        MessageCenter.Instance.SendMessage(
            MsgType.CLIENT_PLAYER_LEVELEXP,
            this,
            null,
            new Dictionary<string, object>()
            {
                {"Exp",exp}
            });
    }


}

public class TaskInfo
{
    public int MainType;            //任务主类型: 1普通任务 2成就任务
    public int Id;                  //任务Id
    public int TaskType;            //任务类型: 普通任务(1每日任务 2每周任务) 成就任务(1累计登录 2捕鱼能手 3倍率达人 4竞技高手)
    public int CompleteNum;         //完成数量
    public int NeedNum;             //需完成数量
    public string Desc;             //任务描述
    public List<ItemInfo> Rewards;  //奖励
    public bool CompleteFlag;       //是否已完成并领取奖励

    public TaskInfo(int mainType, int id, int taskType, int completeNum, int needNum, string desc, List<ItemInfo> rewards)
    {
        MainType = mainType;
        Id = id;
        TaskType = taskType;
        CompleteNum = completeNum;
        NeedNum = needNum;
        Desc = desc;
        Rewards = rewards;
        CompleteFlag = false;
    }
}

public class ActiveInfo
{
    public int DailyActiveValue;        //日活跃值
    public int WeeklyActiveValue;       //周活跃值
    public List<int> CompleteIdList;    //已领取奖励

    public ActiveInfo(int daily, int weekly, List<int> complete)
    {
        DailyActiveValue = daily;
        WeeklyActiveValue = weekly;
        CompleteIdList = complete;
    }
}

public class ShakeNumberInfo
{
    public int NumberLength;            //已摇了几天的数字
    public List<int> NumberList;        //已摇到的数字(下标0-6表示1-7天)
    public List<int> BoxStateList;      //宝箱状态,下标同上,0未领取1已领取2未解锁
    public int ActFlag;                 //当日是否已摇数字 1是0否
    public int FetchedFlag;             //本轮是否已领取 1是0否2未解锁

    public ShakeNumberInfo(int numberLength, List<int> numberList, List<int> boxStateList, int actFlag, int fetchedFlag)
    {
        NumberLength = numberLength;
        NumberList = numberList;
        BoxStateList = boxStateList;
        ActFlag = actFlag;
        FetchedFlag = fetchedFlag;
    }
}

public class WelfarePigInfo
{
    public int Welfare;
    public uint ExpireTime;
    public int IsFetched;
    public int IsBroken;
    public int BrokenCount;

    public WelfarePigInfo(int welfare, uint expireTime, int isFetched, int isBroken, int brokenCount)
    {
        Welfare = welfare;
        ExpireTime = expireTime;
        IsFetched = isFetched;
        IsBroken = isBroken;
        BrokenCount = brokenCount;
    }
}

public class InvestGunInfo
{
    public int MaxRechargeId;
    public int MaxGunValue;
    public List<int> FinishedList;

    public InvestGunInfo(int maxRechargeId, int maxGunValue, int[] finishedArray)
    {
        MaxRechargeId = maxRechargeId;
        MaxGunValue = maxGunValue;
        FinishedList = new List<int>();
        Array.ForEach(finishedArray, f => { FinishedList.Add(f); });
    }
}

public class InvestCostInfo
{
    public int IsRecharged;         //是否已完成充值 1是0否
    public long TotalCost;
    public List<int> FinishedList;

    public InvestCostInfo(int isRecharged, long totalCost, int[] finishedArray)
    {
        IsRecharged = isRecharged;
        TotalCost = totalCost;
        FinishedList = new List<int>();
        Array.ForEach(finishedArray, f => { FinishedList.Add(f); });
    }
}