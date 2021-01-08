using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

//使用 Invoke() 方法需要注意 3点：
//1：它应该在 脚本的生命周期里的（Start、Update、OnGUI、FixedUpdate、LateUpdate）中被调用；
//2：Invoke(); 不能接受含有参数的方法；
//3：在 Time.ScaleTime = 0; 时， Invoke() 无效，因为它不会被调用到
//4：只能调用到本类中的方法
//当Invoke被调用后，无论此对象Active为True还是False，在指定时间后，均会被触发（调用）指定的方法。
//Invoke被调用， 本质上是将方法推到系统调度器中统一执行
[RequireComponent(typeof(Button))]
public class ButtonLongPress : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerExitHandler
{
    [SerializeField]
    [Tooltip("How long must pointer be down on this object to trigger a long press")]
    private float holdTime = 1f;
    // 自己处理onClick事件，
    // 此脚本不会覆盖Button 的OnClick事件
    // 防止触发长按后再次触发onClick事件，请把Button的OnClick事件添加到此脚本中
    private bool held = false;
    public UnityEvent onClick = new UnityEvent();

    public UnityEvent onLongPress = new UnityEvent();

    private void OnEnable()
    {

    }

    public void OnPointerDown(PointerEventData eventData)
    {
        held = false;
        Invoke("OnLongPress", holdTime);
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        CancelInvoke("OnLongPress");

        if (!held)
            onClick.Invoke();
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        CancelInvoke("OnLongPress");
    }

    private void OnLongPress()
    {
        held = true;
        onLongPress.Invoke();
    }
}