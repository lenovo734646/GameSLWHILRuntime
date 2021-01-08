using UnityEngine;
using UnityEngine.EventSystems;
using System;
using XLua;
using XLuaExtension;

namespace XLuaExtension
{
    public class UGUIOnBeginDragLuaBehaviour : BaseLuaBehaviour<UGUIOnBeginDragLuaBehaviour>, IBeginDragHandler
    {
        private Action<LuaTable, PointerEventData> luaOnBeginDrag;
        private Action<PointerEventData> luaOnBeginDrag2;

        public static UGUIOnBeginDragLuaBehaviour Bind(GameObject go, Action<PointerEventData> func)
        {
            UGUIOnBeginDragLuaBehaviour behaviour = go.AddComponent<UGUIOnBeginDragLuaBehaviour>();
            behaviour.self = null;
            behaviour.luaOnBeginDrag2 += func;
            return behaviour;
        }

        public override void Init()
        {
            self.Get("OnBeginDrag", out luaOnBeginDrag);
        }

        public void OnBeginDrag(PointerEventData eventData)
        {
            if (luaOnBeginDrag2 != null)
                luaOnBeginDrag2(eventData);
            if (luaOnBeginDrag != null)
                luaOnBeginDrag(self, eventData);
        }
    }
}

