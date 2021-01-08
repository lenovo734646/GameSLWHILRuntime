using UnityEngine;
using UnityEngine.EventSystems;
using System;
using XLua;
using XLuaExtension;

namespace XLuaExtension
{
    public class UGUIPointerDownLuaBehaviour : BaseLuaBehaviour<UGUIPointerDownLuaBehaviour>, IPointerDownHandler
    {
        private Action<LuaTable, PointerEventData> luaPointerDown;
        private Action<PointerEventData> luaPointerDown2;

        public static UGUIPointerDownLuaBehaviour Bind(GameObject go, Action<PointerEventData> func)
        {
            UGUIPointerDownLuaBehaviour behaviour = go.AddComponent<UGUIPointerDownLuaBehaviour>();
            behaviour.self = null;
            behaviour.luaPointerDown2 += func;
            return behaviour;
        }

        public override void Init()
        {
            self.Get("PointerDown", out luaPointerDown);
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            if (luaPointerDown2 != null)
                luaPointerDown2(eventData);
            if (luaPointerDown != null)
                luaPointerDown(self, eventData);
        }
    }
}

