// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_2173"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_IlmTex("IlmTex", 2D) = "white" {}
		_MainColor("Main Color", Color) = (1,1,1,1)
		_ShadowColor("ShadowColor", Color) = (0.7,0.7,0.8,1)
		_SpecularColor("SpecularColor", Color) = (0.7,0.7,0.8,1)
		_RimColor("RimColor", Color) = (0.7,0.7,0.8,1)
		_ShadowRange("ShadowRange", Range( 0 , 1)) = 0.5
		_ShadowSmooth("Shadow Smooth", Range( 0 , 1)) = 0.2
		_ShadowRange("ShadowRange", Range( 0 , 1)) = 0.9
		_SpecularGloss("SpecularGloss", Range( 0.001 , 8)) = 4
		_SpecularMulti("SpecularMulti", Range( 0 , 1)) = 0.4
		_RimMin("RimMin", Range( 0 , 1)) = 0
		_RimMax("RimMax", Range( 0 , 1)) = 0
		_RimSmooth("RimSmooth", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
			float3 viewDir;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _MainColor;
		uniform float4 _ShadowColor;
		uniform float _ShadowSmooth;
		uniform float _ShadowRange;
		uniform sampler2D _IlmTex;
		uniform float4 _IlmTex_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _SpecularGloss;
		uniform float4 _SpecularColor;
		uniform float _SpecularMulti;
		uniform float4 _RimColor;
		uniform float _RimSmooth;
		uniform float _RimMin;
		uniform float _RimMax;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_IlmTex = i.uv_texcoord * _IlmTex_ST.xy + _IlmTex_ST.zw;
			float4 tex2DNode50 = tex2D( _IlmTex, uv_IlmTex );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult22 = dot( ase_normWorldNormal , ase_worldlightDir );
			float halfLambert25 = ( ( dotResult22 * 0.5 ) + 0.5 );
			float threshold56 = ( 0.5 * ( tex2DNode50.g + halfLambert25 ) );
			float temp_output_39_0 = ( _ShadowRange - threshold56 );
			float smoothstepResult37 = smoothstep( 0.0 , _ShadowSmooth , temp_output_39_0);
			float ramp57 = smoothstepResult37;
			float4 lerpResult42 = lerp( _MainColor , _ShadowColor , ramp57);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 normalizeResult61 = normalize( ( ase_worldlightDir + i.viewDir ) );
			float dotResult66 = dot( ase_normWorldNormal , normalizeResult61 );
			float SpecularSize71 = pow( max( 0.0 , dotResult66 ) , _SpecularGloss );
			float specularMask72 = tex2DNode50.b;
			float specularInstinty81 = tex2DNode50.r;
			float4 specular86 = (( SpecularSize71 >= ( 1.0 - ( specularMask72 * _ShadowRange ) ) ) ? ( _SpecularColor * specularInstinty81 * _SpecularMulti ) :  float4( 0,0,0,0 ) );
			float dotResult98 = dot( i.viewDir , ase_normWorldNormal );
			float f101 = ( 1.0 - saturate( dotResult98 ) );
			float smoothstepResult114 = smoothstep( _RimMin , _RimMax , f101);
			float smoothstepResult115 = smoothstep( 0.0 , _RimSmooth , smoothstepResult114);
			float rim117 = smoothstepResult115;
			float3 rimColor109 = ( (_RimColor).rgb * _RimColor.a * rim117 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( ( ( lerpResult42 * tex2D( _MainTex, uv_MainTex ) ) + specular86 + float4( rimColor109 , 0.0 ) ) * float4( ase_lightColor.rgb , 0.0 ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers xbox360 xboxone n3ds wiiu 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17700
-1232;104;1920;960;497.8967;-3910.28;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;27;-702.4573,895.8065;Inherit;False;1559.023;935.7424;Comment;6;7;20;22;23;24;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;7;-328.3181,1497.714;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;20;-322.8221,1648.549;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;22;30.12181,1573.019;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-1092.609,3845.735;Inherit;False;1226.014;504.8877;Comment;9;114;112;111;101;100;99;98;96;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;257.122,1573.019;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;466.1215,1671.019;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;96;-1042.016,4044.356;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;94;-1042.609,3895.734;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;68;-354.0573,3375.939;Inherit;False;1447.522;405.3762;NdH;10;71;69;70;67;63;66;61;62;64;65;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;51;-342.8004,2668.118;Inherit;False;1385.229;663.8774;Comment;6;50;53;55;56;72;81;R=高光强度 G=阴影阈值 B=高光范围;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;64;-289.2429,3625.532;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;65;-304.0573,3460.774;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;632.5656,1671.862;Inherit;False;halfLambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;98;-804.0157,4014.356;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-47.48133,3603.826;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-293.0811,2944.041;Inherit;False;25;halfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-307.8005,2721.118;Inherit;True;Property;_IlmTex;IlmTex;1;0;Create;True;0;0;False;0;-1;None;ac6f0e62b2195f5409f20a3bd4b1da3e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;99;-637.0156,4012.356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;61;138.6953,3601.523;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-327.4549,1942.88;Inherit;False;Property;_ShadowRange;ShadowRange;7;0;Create;True;0;0;False;0;0.5;0.636;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;55.31884,2923.242;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;63;108.4467,3425.939;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-444.0154,3986.356;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;66;368.2573,3601.285;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-293.5792,3983.355;Inherit;False;f;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-499.9753,4263.563;Inherit;False;Property;_RimMax;RimMax;12;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;234.7188,2897.242;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;40;-21.4746,2321.681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-500.4075,4192.436;Inherit;False;Property;_RimMin;RimMin;11;0;Create;True;0;0;False;0;0;0.841;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;508.7489,3706.472;Inherit;False;Property;_SpecularGloss;SpecularGloss;9;0;Create;True;0;0;False;0;4;0.3;0.001;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;41;565.7253,2380.879;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;31.56445,2793.58;Inherit;False;specularMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;424.5189,2892.041;Inherit;False;threshold;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;67;528.2578,3577.285;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;43;674.2495,2225.772;Inherit;False;730.9739;356.2561;Ramp;6;5;37;38;39;49;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;116;80.90035,4335.304;Inherit;False;Property;_RimSmooth;RimSmooth;13;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;108;382.6079,4386.272;Inherit;False;1079.837;350.8452;Comment;5;107;106;105;103;109;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;114;-42.19091,4216.55;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;729.7426,2466.028;Inherit;False;Property;_ShadowSmooth;Shadow Smooth;8;0;Create;True;0;0;False;0;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;694.9267,2356.209;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;31.89679,2720.413;Inherit;False;specularInstinty;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;115;453.9005,4218.304;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;1215.628,3288.563;Inherit;False;72;specularMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;103;432.608,4436.272;Inherit;False;Property;_RimColor;RimColor;6;0;Create;True;0;0;False;0;0.7,0.7,0.8,1;0.3120756,1,0.09019607,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;69;698.749,3576.472;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;1129.985,3393.428;Inherit;False;Property;_ShadowRange;ShadowRange;8;0;Fetch;True;0;0;False;0;0.9;0.636;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;703.0866,4216.194;Inherit;False;rim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;1146.607,3613.965;Inherit;False;Property;_SpecularMulti;SpecularMulti;10;0;Create;True;0;0;False;0;0.4;0.296;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;85;1152.289,3762.783;Inherit;False;Property;_SpecularColor;SpecularColor;5;0;Create;True;0;0;False;0;0.7,0.7,0.8,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;37;1262.223,2419.617;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;881.749,3573.472;Inherit;False;SpecularSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;1423.985,3374.428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;1150.136,3687.321;Inherit;False;81;specularInstinty;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;105;643.4445,4437.117;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;1084.494,2661.006;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;None;124cec12e69d8f942b18beaf4723b438;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;949.4445,4511.117;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;16;1378.697,2648.628;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;1607.672,3610.395;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;1453.025,2419.96;Inherit;False;ramp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;1567.728,3181.463;Inherit;False;71;SpecularSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-320.7272,2024.856;Inherit;False;Property;_MainColor;Main Color;3;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-318.3341,2212.921;Inherit;False;Property;_ShadowColor;ShadowColor;4;0;Create;True;0;0;False;0;0.7,0.7,0.8,1;0.09878961,0.237291,0.5660378,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;75;1570.628,3266.563;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;1201.617,4503.182;Inherit;False;rimColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;42;1767.829,2161.347;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCCompareGreaterEqual;73;1835.102,3184.662;Inherit;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;59;1843.277,2644.758;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;1957.07,2428.842;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;2042.584,3310.557;Inherit;False;109;rimColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;2039.692,3178.586;Inherit;False;specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;2482.982,2855.048;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;89;2696.359,2937.491;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;2866.135,2850.192;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCCompareGreater;29;216.9266,1860.239;Inherit;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;1233.021,1857.5;Inherit;False;color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;90;2850.919,2295.651;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;434.4446,4622.117;Inherit;False;101;f;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;31;711.7889,1954.854;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;616.2773,1860.626;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;36;1012.181,1856.325;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;713.1852,2182.728;Inherit;False;25;halfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;855.5952,1859.729;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;47;1064.74,2274.496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-318.8574,1856.256;Inherit;False;25;halfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;1274.74,2274.496;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;45;1449.599,2233.683;Inherit;True;Property;_RampTex;RampTex;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4267.525,1915.229;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Toon_2173;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;10;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;ps4;psp2;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;22;0;7;0
WireConnection;22;1;20;0
WireConnection;23;0;22;0
WireConnection;24;0;23;0
WireConnection;25;0;24;0
WireConnection;98;0;94;0
WireConnection;98;1;96;0
WireConnection;62;0;65;0
WireConnection;62;1;64;0
WireConnection;99;0;98;0
WireConnection;61;0;62;0
WireConnection;54;0;50;2
WireConnection;54;1;53;0
WireConnection;100;1;99;0
WireConnection;66;0;63;0
WireConnection;66;1;61;0
WireConnection;101;0;100;0
WireConnection;55;1;54;0
WireConnection;40;0;4;0
WireConnection;41;0;40;0
WireConnection;72;0;50;3
WireConnection;56;0;55;0
WireConnection;67;1;66;0
WireConnection;114;0;101;0
WireConnection;114;1;111;0
WireConnection;114;2;112;0
WireConnection;39;0;41;0
WireConnection;39;1;56;0
WireConnection;81;0;50;1
WireConnection;115;0;114;0
WireConnection;115;2;116;0
WireConnection;69;0;67;0
WireConnection;69;1;70;0
WireConnection;117;0;115;0
WireConnection;37;0;39;0
WireConnection;37;2;5;0
WireConnection;71;0;69;0
WireConnection;78;0;76;0
WireConnection;78;1;77;0
WireConnection;105;0;103;0
WireConnection;106;0;105;0
WireConnection;106;1;103;4
WireConnection;106;2;117;0
WireConnection;16;0;1;0
WireConnection;80;0;85;0
WireConnection;80;1;82;0
WireConnection;80;2;79;0
WireConnection;57;0;37;0
WireConnection;75;1;78;0
WireConnection;109;0;106;0
WireConnection;42;0;2;0
WireConnection;42;1;3;0
WireConnection;42;2;57;0
WireConnection;73;0;74;0
WireConnection;73;1;75;0
WireConnection;73;2;80;0
WireConnection;59;0;16;0
WireConnection;58;0;42;0
WireConnection;58;1;59;0
WireConnection;86;0;73;0
WireConnection;87;0;58;0
WireConnection;87;1;86;0
WireConnection;87;2;110;0
WireConnection;88;0;87;0
WireConnection;88;1;89;1
WireConnection;29;0;26;0
WireConnection;29;1;4;0
WireConnection;29;2;2;0
WireConnection;29;3;3;0
WireConnection;34;0;36;0
WireConnection;90;0;88;0
WireConnection;30;0;29;0
WireConnection;36;0;32;0
WireConnection;32;0;30;0
WireConnection;32;1;31;1
WireConnection;47;0;39;0
WireConnection;49;0;47;0
WireConnection;45;1;49;0
WireConnection;0;13;90;0
ASEEND*/
//CHKSM=E4FA929993DDCF779DCAFB6BEC988BF859F05283