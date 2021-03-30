

-- 之前的方案不行，重新兼容回去
local sharedMap =
{
    Add = function(self, name, obj)
        self[name] = obj
    end,
}
g_Env.sharedMap = sharedMap

