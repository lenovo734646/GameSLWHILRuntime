using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;

using ILRuntime.CLR.TypeSystem;
using ILRuntime.CLR.Method;
using ILRuntime.Runtime.Enviorment;
using ILRuntime.Runtime.Intepreter;
using ILRuntime.Runtime.Stack;
using ILRuntime.Reflection;
using ILRuntime.CLR.Utils;

namespace ILRuntime.Runtime.Generated
{
    unsafe class AssemblyCommon_AddressablesLoader_Binding_LoadTask_1_GameObject_Binding
    {
        public static void Register(ILRuntime.Runtime.Enviorment.AppDomain app)
        {
            BindingFlags flag = BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly;
            MethodBase method;
            Type[] args;
            Type type = typeof(AssemblyCommon.AddressablesLoader.LoadTask<UnityEngine.GameObject>);
            args = new Type[]{};
            method = type.GetMethod("Instantiate", flag, null, args, null);
            app.RegisterCLRMethodRedirection(method, Instantiate_0);


        }


        static StackObject* Instantiate_0(ILIntepreter __intp, StackObject* __esp, IList<object> __mStack, CLRMethod __method, bool isNewObj)
        {
            ILRuntime.Runtime.Enviorment.AppDomain __domain = __intp.AppDomain;
            StackObject* ptr_of_this_method;
            StackObject* __ret = ILIntepreter.Minus(__esp, 1);

            ptr_of_this_method = ILIntepreter.Minus(__esp, 1);
            AssemblyCommon.AddressablesLoader.LoadTask<UnityEngine.GameObject> instance_of_this_method = (AssemblyCommon.AddressablesLoader.LoadTask<UnityEngine.GameObject>)typeof(AssemblyCommon.AddressablesLoader.LoadTask<UnityEngine.GameObject>).CheckCLRTypes(StackObject.ToObject(ptr_of_this_method, __domain, __mStack), (CLR.Utils.Extensions.TypeFlags)0);
            __intp.Free(ptr_of_this_method);

            var result_of_this_method = instance_of_this_method.Instantiate();

            return ILIntepreter.PushObject(__ret, __mStack, result_of_this_method);
        }



    }
}