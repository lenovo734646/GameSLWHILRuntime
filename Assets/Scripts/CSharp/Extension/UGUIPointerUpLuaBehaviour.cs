using UnityEngine;
using UnityEngine.EventSystems;
using System;
using XLua;
using XLuaExtension;

namespace XLuaExtension
{
    public class UGUIPointerUpLuaBehaviour : BaseLuaBehaviour<UGUIPointerUpLuaBehaviour>, IPointerUpHandler
    {
        private Action<LuaTable, PointerEventData> luaPointerUp;
        private Action<PointerEventData> luaPointerUp2;

        public static UGUIPointerUpLuaBehaviour Bind(GameObject go, Action<PointerEventData> func)
        {
            UGUIPointerUpLuaBehaviour behaviour = go.AddComponent<UGUIPointerUpLuaBehaviour>();
            behaviour.self = null;
            behaviour.luaPointerUp2 += func;
            return behaviour;
        }

        public override void Init()
        {
            self.Get("PointerUp", out luaPointerUp);
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            if (luaPointerUp2 != null)
                luaPointerUp2(eventData);
            if (luaPointerUp != null)
                luaPointerUp(self, eventData);
        }
    }
}

