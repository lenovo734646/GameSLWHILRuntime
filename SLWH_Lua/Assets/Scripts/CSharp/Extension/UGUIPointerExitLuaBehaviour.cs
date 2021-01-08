using UnityEngine;
using UnityEngine.EventSystems;
using System;
using XLua;
using XLuaExtension;

namespace XLuaExtension
{
    public class UGUIPointerExitLuaBehaviour : BaseLuaBehaviour<UGUIPointerExitLuaBehaviour>, IPointerExitHandler
    {
        private Action<LuaTable, PointerEventData> luaPointExit;
        private Action<PointerEventData> luaPointExit2;

        public static UGUIPointerExitLuaBehaviour Bind(GameObject go, Action<PointerEventData> func)
        {
            UGUIPointerExitLuaBehaviour behaviour = go.AddComponent<UGUIPointerExitLuaBehaviour>();
            behaviour.self = null;
            behaviour.luaPointExit2 += func;
            return behaviour;
        }

        public override void Init()
        {
            self.Get("PointExit", out luaPointExit);
        }


        public void OnPointerExit(PointerEventData eventData)
        {
            if (luaPointExit2 != null)
                luaPointExit2(eventData);
            if (luaPointExit != null)
                luaPointExit(self, eventData);
        }
    }
}

