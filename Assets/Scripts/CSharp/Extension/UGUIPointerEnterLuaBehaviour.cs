using UnityEngine;
using UnityEngine.EventSystems;
using System;
using XLua;
using XLuaExtension;

namespace XLuaExtension
{
    public class UGUIPointerEnterLuaBehaviour : BaseLuaBehaviour<UGUIPointerEnterLuaBehaviour>, IPointerEnterHandler
    {
        private Action<LuaTable, PointerEventData> luaPointEnter;
        private Action<PointerEventData> luaPointEnter2;

        public static UGUIPointerEnterLuaBehaviour Bind(GameObject go, Action<PointerEventData> func)
        {
            UGUIPointerEnterLuaBehaviour behaviour = go.AddComponent<UGUIPointerEnterLuaBehaviour>();
            behaviour.self = null;
            behaviour.luaPointEnter2 += func;
            return behaviour;
        }

        public override void Init()
        {
            self.Get("PointEnter", out luaPointEnter);
        }

        public void OnPointerEnter(PointerEventData eventData)
        {
            if (luaPointEnter2 != null)
                luaPointEnter2(eventData);
            if (luaPointEnter != null)
                luaPointEnter(self, eventData);
        }
    }
}

