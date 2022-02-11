using System;

using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Serialization;
using UnityEngine.UI;

[AddComponentMenu("UGUIExpend/UITouch", 30)]
public class UITouch : Button//Selectable, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    [Serializable]
    public class TouchEvent : UnityEvent
    {
        public PointerEventData eventData = default;
    }

    [SerializeField]
    private TouchEvent m_OnTouchDown = new TouchEvent();

    [SerializeField]
    private TouchEvent m_OnTouchUp = new TouchEvent();

    [SerializeField]
    private TouchEvent m_OnTouchExit = new TouchEvent();

    [SerializeField]
    private TouchEvent m_OnBeginSlide = new TouchEvent();

    [SerializeField]
    private TouchEvent m_OnSlide = new TouchEvent();

    [SerializeField]
    private TouchEvent m_OnEndSlide = new TouchEvent();

    protected UITouch() { }
    public TouchEvent OnTouchDown
    {
        get { return this.m_OnTouchDown; }
        set { m_OnTouchDown = value; }
    }

    public TouchEvent OnTouchUp
    {
        get { return this.m_OnTouchUp; }
        set { this.m_OnTouchUp = value; }
    }

    public TouchEvent OnTouchExit
    {
        get { return m_OnTouchExit; }
        set { m_OnTouchExit = value; }
    }

    public TouchEvent OnBeginSlider
    {
        get { return m_OnBeginSlide; }
        set { m_OnBeginSlide = value; }
    }

    public TouchEvent OnSlider
    {
        get { return m_OnSlide; }
        set { m_OnSlide = value; }
    }
    public TouchEvent OnEndSlider
    {
        get { return m_OnEndSlide; }
        set { m_OnEndSlide = value; }
    }

    protected override void OnDestroy() {
         m_OnTouchDown.RemoveAllListeners();
         m_OnTouchUp.RemoveAllListeners();
         m_OnTouchExit.RemoveAllListeners();
         m_OnBeginSlide.RemoveAllListeners();
         m_OnSlide.RemoveAllListeners();
         m_OnEndSlide.RemoveAllListeners();
    }

    private void touchDownOption(PointerEventData eventData)
    {
        if (!IsActive() || !IsInteractable())
        {
            return;
        }
        UISystemProfilerApi.AddMarker("UITouch.OnTouchDown", this);
        m_OnTouchDown.eventData = eventData;
        m_OnTouchDown.Invoke();
    }

    private void touchExitOption(PointerEventData eventData)
    {
        if (!IsActive() || !IsInteractable())
        {
            return;
        }
        UISystemProfilerApi.AddMarker("UITouch.OnTouchExit", this);
        m_OnTouchExit.eventData = eventData;
        m_OnTouchExit.Invoke();
    }

    private void touchUpOption(PointerEventData eventData)
    {
        if (!IsActive() || !IsInteractable())
        {
            return;
        }
        UISystemProfilerApi.AddMarker("UITouch.OnTouchUp", this);
        m_OnTouchUp.eventData = eventData;
        m_OnTouchUp.Invoke();
    }

    private void slideOption(PointerEventData eventData)
    {
        if (!IsActive() || !IsInteractable())
        {
            return;
        }
        UISystemProfilerApi.AddMarker("UITouch.OnSlider", this);
        m_OnSlide.eventData = eventData;
        m_OnSlide.Invoke();
    }
    private void beginSlideOption(PointerEventData eventData)
    {
        if (!IsActive() || !IsInteractable())
        {
            return;
        }
        UISystemProfilerApi.AddMarker("UITouch.OnSlider", this);
        m_OnBeginSlide.eventData = eventData;
        m_OnBeginSlide.Invoke();
    }
    private void endSlideOption(PointerEventData eventData)
    {
        if (!IsActive() || !IsInteractable())
        {
            return;
        }
        UISystemProfilerApi.AddMarker("UITouch.OnSlider", this);
        m_OnEndSlide.eventData = eventData;
        m_OnEndSlide.Invoke();
    }
    public override void OnPointerDown(PointerEventData eventData)
    {
        base.OnPointerDown(eventData);
        if (eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }
        touchDownOption(eventData);
    }
    public override void OnPointerUp(PointerEventData eventData)
    {
        base.OnPointerUp(eventData);
        if (eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }
        touchUpOption(eventData);
    }
    public override void OnPointerExit(PointerEventData eventData)
    {
        base.OnPointerExit(eventData);
        if (eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }
        touchExitOption(eventData);
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }
        beginSlideOption(eventData);
        //throw new NotImplementedException();
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }
        slideOption(eventData);
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }
        endSlideOption(eventData);
    }
}
