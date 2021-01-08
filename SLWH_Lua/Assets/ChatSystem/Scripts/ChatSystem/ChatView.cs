using Com.TheFallenGames.OSA.Core;
using Com.TheFallenGames.OSA.DataHelpers;
using OSAHelper;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SP
{
    public class ChatView : MonoBehaviour
    {
        public OSAScrollView view;
        public ChatCustomParam customParams;
        public SimpleDataHelper<ChatMsgData> Data { get; private set; }

        public void Awake()
        {
            view.StartCallback = Init;
            view.UpdateViewsHolderCallback = UpdateViewsHolder;
            view.ChangeItemsCountCallback = ChangeItemsCount;
            view.CreateViewsHolderCallback = CreateViewsHolder; 
        }
        public void Init(object view)
        {
            Data = new SimpleDataHelper<ChatMsgData>(this.view);
        }


        public ItemViewHolder CreateViewsHolder(object[] paramters_)
        {
            var itemIndex = (int)paramters_[1];
            var _Params = view.Parameters;

            var inst = new ItemViewHolder();
            ChatItemViewHolder vh = new ChatItemViewHolder();
            vh.Init(inst);
            //visibleItems.Insert(itemIndex, vh);
            
            inst.Init(_Params.ItemPrefab, _Params.Content, itemIndex);
            inst.bindData = vh;
            //

            return inst;
        }

        public void UpdateViewsHolder(object[] paramters_)
        {
            var newOrRecycled = (ItemViewHolder)paramters_[1];
            ChatMsgData data = Data[newOrRecycled.ItemIndex];
            newOrRecycled.UpdateFromModelCallback?.Invoke(new object[] { this, data, customParams, view.GetItemsCount()});

            print("UpdateViewsHolder");
            //if (data.HasPendingVisualSizeChange)
            {
                newOrRecycled.MarkForRebuild();
                view.ScheduleComputeTwinPass(true); // size fitter
            }
        }

        public void ChangeItemsCount(object[] paramters_)
        {
            //var changeMode = (ItemCountChangeMode)paramters_[1];
            //var itemsCount = (int)paramters_[2];
            //if (changeMode == ItemCountChangeMode.RESET)
            //{

            //}
        }
        //
        public int GetItemsCount()
        {
            return view.GetItemsCount();
        }

        public void SmoothScrollTo(int itemIndex,
            float duration,
            float normalizedOffsetFromViewportStart = 0f,
            float normalizedPositionOfItemPivotToUse = 0f,
            Func<float, bool> onProgress = null,
            Action onDone = null,
            bool overrideCurrentScrollingAnimation = false)
        {
            view.SmoothScrollTo(itemIndex, duration, normalizedOffsetFromViewportStart, normalizedPositionOfItemPivotToUse,
                onProgress, onDone, overrideCurrentScrollingAnimation);
        }

        public void ScrollToBottom(float duration = 0.1f)
        {
            var index = GetItemsCount()-1;
            SmoothScrollTo(index, duration);
        }

        public ChatItemViewHolder GetItemViewsHolder(int index)
        {
            //if (index >= visibleItems.Count)
            //    return null;
            //return visibleItems[index];
            return (ChatItemViewHolder)view.GetItemViewsHolder(index).bindData;
        }

         // OnDestroy 中自动调用
        public void Dispose(object view)
        {
            // first call
        }

        private void OnDestroy()
        {
            // second call
        }
    }


}