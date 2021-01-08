using UnityEngine;
using UnityEngine.EventSystems;
using System;
using XLua;
using XLuaExtension;

namespace XLuaExtension
{
    public class UGUIOnEndDragLuaBehaviour : BaseLuaBehaviour<UGUIOnEndDragLuaBehaviour>, IEndDragHandler
    {
        private Action<LuaTable, PointerEventData> luaOnEndDrag;
        private Action<PointerEventData> luaOnEndDrag2;

        public static UGUIOnEndDragLuaBehaviour Bind(GameObject go, Action<PointerEventData> func)
        {
            UGUIOnEndDragLuaBehaviour behaviour = go.AddComponent<UGUIOnEndDragLuaBehaviour>();
            behaviour.self = null;
            behaviour.luaOnEndDrag2 += func;
            return behaviour;
        }

        public override void Init()
        {
            self.Get("OnEndDrag", out luaOnEndDrag);
        }

        public void OnEndDrag(PointerEventData eventData)
        {
            if (luaOnEndDrag2 != null)
                luaOnEndDrag2(eventData);
            if (luaOnEndDrag != null)
                luaOnEndDrag(self, eventData);
        }
    }
}

