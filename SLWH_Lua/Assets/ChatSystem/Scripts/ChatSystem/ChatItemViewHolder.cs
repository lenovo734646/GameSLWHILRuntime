using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using frame8.Logic.Misc.Other.Extensions;
using System;
using Com.TheFallenGames.OSA.CustomParams;
using OSAHelper;

namespace SP
{
    public class ChatItemViewHolder
    {
        ChatMsgView view;
        //
        public ItemViewHolder viewHolder;

        public void Init(ItemViewHolder vh)
        {
            viewHolder = vh;
            viewHolder.CollectViewsCallback = CollectView;
            viewHolder.MarkForRebuildCallback = MarkForRebuild;
            viewHolder.UnmarkForRebuildCallback = UnmarkForRebuild;
            viewHolder.UpdateFromModelCallback = UpdateFromModel;
            
        }

        public void CollectView(object[] paramters)
        {
            var root = viewHolder.root;
            view = root.GetComponent<ChatMsgView>();
        }

        public void UpdateFromModel(object[] paramters_)
        {
            var data = (ChatMsgData)paramters_[1];
            //var parameters = (ChatCustomParam)paramters_[2];
            //var itemCount = (int)paramters_[3];
            //var time = (float)paramters_[4];
            //
            view.UpdateFromData(data);
        }

        //
        public void MarkForRebuild(object[] paramters)
        {
            if (view.sizeFitter)
                view.sizeFitter.enabled = true;
        }
        public void UnmarkForRebuild(object[] paramters)
        {
            if (view.sizeFitter)
                view.sizeFitter.enabled = false;
        }
    }

    [Serializable]
    public class ChatCustomParam
    {
        public Sprite[] availableIcons;
    }
}

