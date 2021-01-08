using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LuaAPI = XLua.LuaDLL.Lua;

namespace XLua {
    public partial class LuaTable : LuaBase {

        public LuaTable NewTable<TKey>(TKey key) {
#if THREAD_SAFE || HOTFIX_ENABLE
            lock (luaEnv.luaEnvLock)
            {
#endif
            var L = luaEnv.L;
            int oldTop = LuaAPI.lua_gettop(L);
            var translator = luaEnv.translator;

            LuaAPI.lua_getref(L, luaReference);
            translator.PushByType(L, key);
            LuaAPI.lua_newtable(L);

            if (0 != LuaAPI.xlua_psettable(L, -3)) {
                luaEnv.ThrowExceptionFromError(oldTop);
            }
            LuaAPI.lua_settop(L, oldTop);

            var t = Get<TKey,LuaTable>(key);

#if THREAD_SAFE || HOTFIX_ENABLE
            }
#endif
            return t;
        }

    }
}
