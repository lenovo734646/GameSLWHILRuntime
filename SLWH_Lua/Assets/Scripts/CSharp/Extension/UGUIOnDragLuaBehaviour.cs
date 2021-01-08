using UnityEngine;
using UnityEngine.EventSystems;
using System;
using XLua;
using XLuaExtension;

namespace XLuaExtension
{
    public class UGUIOnDragLuaBehaviour : BaseLuaBehaviour<UGUIOnBeginDragLuaBehaviour>, IDragHandler
    {
        private Action<LuaTable, PointerEventData> luaOnDrag;
        private Action<PointerEventData> luaOnDrag2;

        public static UGUIOnDragLuaBehaviour Bind(GameObject go, Action<PointerEventData> func)
        {
            UGUIOnDragLuaBehaviour behaviour = go.AddComponent<UGUIOnDragLuaBehaviour>();
            behaviour.self = null;
            behaviour.luaOnDrag2 += func;
            return behaviour;
        }

        public override void Init()
        {
            self.Get("OnDrag", out luaOnDrag);
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (luaOnDrag2 != null)
                luaOnDrag2(eventData);
            if (luaOnDrag != null)
                luaOnDrag(self, eventData);
        }
    }
}

