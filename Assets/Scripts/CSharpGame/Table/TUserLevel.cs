using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;

public class TUserLevel
{
    /// <summary>
    /// 等级
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// 升级所需经验
    /// </summary>
    public long NeedExp { get; set; }

    /// <summary>
    /// 升级奖励金币
    /// </summary>
    public long Gold { get; set; }

    /// <summary>
    /// 升级奖励钻石
    /// </summary>
    public long Diamond { get; set; }

    /// <summary>
    /// 升级赠送物品
    /// 格式：[[id,子id,数量],...]
    /// </summary>
    public JArray Rewards { get; set; }
}

public static class TUserLevelHelper
{
    public static readonly string TableName = "UserLevel";
    public static readonly Type TableType = typeof(TUserLevel);

    public static Dictionary<int, TUserLevel> DataMap;

    public static void LoadData(List<object> rows)
    {
        DataMap = new Dictionary<int, TUserLevel>();
        foreach (var t in rows.Cast<TUserLevel>())
            DataMap[t.Id] = t;
    }

    public static TUserLevel GetRow(int id)
    {
        TUserLevel r = null;
        return DataMap.TryGetValue(id, out r) ? r : null;
    }
}
