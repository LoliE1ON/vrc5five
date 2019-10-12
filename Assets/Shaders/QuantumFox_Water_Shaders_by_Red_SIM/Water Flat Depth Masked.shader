// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "QuantumFox/Water/Flat Depth Masked"
{
	Properties
	{
		[Header(Colors)]
		_Tint("Tint", Color) = (0,0,0,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Opacity("Opacity", Range( 0 , 1)) = 0.5
		_Depth("Depth", Range( 0 , 100)) = 0.5
		_OpacityViewDistance("Opacity View Distance", Range( 1 , 1000)) = 300
		[Header(Normals)]
		_Normal("Normal", 2D) = "bump" {}
		_Normal2nd("Normal 2nd", 2D) = "bump" {}
		_NormalPower("Normal Power", Range( 0 , 1)) = 1
		_NormalPower2nd("Normal Power 2nd", Range( 0 , 1)) = 0.5
		[Header(Animations)]
		_RipplesSpeed("Ripples Speed", Range( 0 , 10)) = 1
		_RipplesSpeed2nd("Ripples Speed 2nd", Range( 0 , 10)) = 1
		_SpeedX("Speed X", Range( -10 , 10)) = 0
		_SpeedY("Speed Y", Range( -10 , 10)) = 0
		[IntRange]_EdgeMaskShiftpx("Edge Mask Shift (px)", Range( 0 , 5)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		ZWrite On
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Add
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 5.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float4 screenPos;
		};

		uniform sampler2D _Normal;
		uniform float _NormalPower;
		uniform float _RipplesSpeed;
		uniform float4 _Normal_ST;
		uniform sampler2D _Sampler0409;
		uniform float _SpeedX;
		uniform float _SpeedY;
		uniform sampler2D _Normal2nd;
		uniform float _NormalPower2nd;
		uniform float _RipplesSpeed2nd;
		uniform float4 _Normal2nd_ST;
		uniform sampler2D _Sampler0410;
		uniform float4 _Tint;
		uniform float _Smoothness;
		uniform float _Opacity;
		uniform float _OpacityViewDistance;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Depth;
		uniform float _EdgeMaskShiftpx;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float mulTime187 = _Time.y * _RipplesSpeed;
			float2 uv0_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float2 panner22 = ( mulTime187 * float2( -0.03,-0.03 ) + uv0_Normal);
			float mulTime395 = _Time.y * ( _SpeedX / (_Normal_ST.xy).x );
			float mulTime403 = _Time.y * ( _SpeedY / (_Normal_ST.xy).y );
			float2 appendResult402 = (float2(mulTime395 , mulTime403));
			float2 temp_output_422_0 = ( _Normal_ST.xy * appendResult402 );
			float2 panner19 = ( mulTime187 * float2( 0.04,0 ) + uv0_Normal);
			float mulTime323 = _Time.y * _RipplesSpeed2nd;
			float2 uv0_Normal2nd = i.uv_texcoord * _Normal2nd_ST.xy + _Normal2nd_ST.zw;
			float2 temp_output_397_0 = ( uv0_Normal2nd + float2( 0,0 ) );
			float2 panner320 = ( mulTime323 * float2( 0.03,0.03 ) + temp_output_397_0);
			float2 temp_output_423_0 = ( appendResult402 * _Normal2nd_ST.xy );
			float2 panner321 = ( mulTime323 * float2( -0.04,0 ) + temp_output_397_0);
			float3 NormalWater315 = BlendNormals( BlendNormals( UnpackScaleNormal( tex2D( _Normal, ( panner22 + temp_output_422_0 ) ), _NormalPower ) , UnpackScaleNormal( tex2D( _Normal, ( panner19 + temp_output_422_0 ) ), _NormalPower ) ) , BlendNormals( UnpackScaleNormal( tex2D( _Normal2nd, ( panner320 + temp_output_423_0 ) ), _NormalPower2nd ) , UnpackScaleNormal( tex2D( _Normal2nd, ( panner321 + temp_output_423_0 ) ), _NormalPower2nd ) ) );
			o.Normal = NormalWater315;
			o.Albedo = _Tint.rgb;
			o.Smoothness = _Smoothness;
			float3 ase_worldPos = i.worldPos;
			float smoothstepResult386 = smoothstep( 0.0 , 1.0 , (0.0 + (distance( (( ase_worldPos - _WorldSpaceCameraPos )).xz , float2( 0,0 ) ) - 0.0) * (1.0 - 0.0) / (_OpacityViewDistance - 0.0)));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth437 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPosNorm )));
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float DepthMaskDepth616 = _Depth;
			float smoothstepResult446 = smoothstep( 0.0 , 1.0 , saturate( (0.0 + (( eyeDepth437 - ase_grabScreenPos.a ) - 0.0) * (1.0 - 0.0) / (DepthMaskDepth616 - 0.0)) ));
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float temp_output_597_0 = ( 1.0 / _ScreenParams.y );
			float2 appendResult602 = (float2(0.0 , -temp_output_597_0));
			float2 ShiftDown614 = ( appendResult602 * _EdgeMaskShiftpx );
			float eyeDepth557 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( ( ase_grabScreenPosNorm + float4( ShiftDown614, 0.0 , 0.0 ) ) )));
			float2 appendResult603 = (float2(0.0 , temp_output_597_0));
			float2 ShiftUp613 = ( appendResult603 * _EdgeMaskShiftpx );
			float eyeDepth552 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( ( ase_grabScreenPosNorm + float4( ShiftUp613, 0.0 , 0.0 ) ) )));
			float temp_output_598_0 = ( 1.0 / _ScreenParams.x );
			float2 appendResult605 = (float2(temp_output_598_0 , 0.0));
			float2 ShiftRight611 = ( appendResult605 * _EdgeMaskShiftpx );
			float eyeDepth554 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( ( ase_grabScreenPosNorm + float4( ShiftRight611, 0.0 , 0.0 ) ) )));
			float DepthMaskUnderwater595 = saturate( ( saturate( sign( ( 1.0 - (0.0 + (( eyeDepth557 - ase_grabScreenPos.a ) - 0.0) * (1.0 - 0.0) / (DepthMaskDepth616 - 0.0)) ) ) ) * saturate( sign( ( 1.0 - (0.0 + (( eyeDepth552 - ase_grabScreenPos.a ) - 0.0) * (1.0 - 0.0) / (DepthMaskDepth616 - 0.0)) ) ) ) * saturate( sign( ( 1.0 - (0.0 + (0.0 - 0.0) * (1.0 - 0.0) / (DepthMaskDepth616 - 0.0)) ) ) ) * saturate( sign( ( 1.0 - (0.0 + (( eyeDepth554 - ase_grabScreenPos.a ) - 0.0) * (1.0 - 0.0) / (DepthMaskDepth616 - 0.0)) ) ) ) ) );
			o.Alpha = ( _Opacity * ( 1.0 - smoothstepResult386 ) * ( 1.0 - ( ( 1.0 - smoothstepResult446 ) * DepthMaskUnderwater595 ) ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
1927;32;1874;998;-470.2412;2144.78;1.685665;True;False
Node;AmplifyShaderEditor.CommentaryNode;521;-706.0343,-3971.916;Float;False;1305.877;575.3567;Edge Mask Shift;19;614;613;612;611;610;609;608;607;606;605;604;603;602;601;600;599;598;597;596;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenParams;596;-690.5875,-3740.124;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;597;-480.7881,-3775.437;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;601;-269.578,-3924.503;Float;False;Constant;_Zero;Zero;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;599;-270.2591,-3837.859;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;598;-477.7881,-3674.437;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;603;-81.53305,-3815.024;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;602;-85.759,-3906.954;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;605;-82.58969,-3630.114;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;606;-188.4849,-3513.089;Float;False;Property;_EdgeMaskShiftpx;Edge Mask Shift (px);14;1;[IntRange];Create;True;0;0;False;0;1;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;607;108.3146,-3906.766;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;610;110.4246,-3618.751;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;522;-703.9359,-3327.833;Float;False;2441.863;1078.123;Depth Mask for Ripples;40;621;535;533;523;558;547;560;537;595;594;593;588;590;589;591;583;584;585;582;577;580;578;579;576;570;571;572;562;561;567;564;552;557;554;544;548;551;541;543;536;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;608;113.5896,-3806.541;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;523;-656.6868,-3235.816;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;614;343.8686,-3900.834;Float;False;ShiftDown;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;611;349.8686,-3623.834;Float;False;ShiftRight;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;613;345.8686,-3807.834;Float;False;ShiftUp;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;432;326.7336,-262.1936;Float;False;1405.218;489.8901;Depth Refraction;8;441;440;439;438;437;436;433;616;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RelayNode;621;-385.9293,-3042.491;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;536;-442.0989,-2946.184;Float;False;614;ShiftDown;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;543;-444.6677,-2767.961;Float;False;613;ShiftUp;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;541;-433.6841,-2409.881;Float;False;611;ShiftRight;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;544;-189.0938,-2425.33;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;548;-195.3517,-2964.263;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GrabScreenPosition;533;-250.7659,-3232.364;Float;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;438;739.6227,112.8252;Float;False;Property;_Depth;Depth;4;0;Create;True;0;0;False;0;0.5;1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;551;-191.6873,-2783.239;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenDepthNode;554;-56.9752,-2419.179;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;616;1034.037,133.1465;Float;False;DepthMaskDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;552;-59.56871,-2777.088;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;557;-63.2332,-2958.112;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;535;4.891252,-3050.613;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;151;-716.3008,-2176.596;Float;False;2670.873;1213.648;Normals Generation and Animation;38;315;326;325;24;319;23;17;318;396;417;416;48;415;322;22;423;321;320;19;422;187;21;397;323;410;402;331;403;395;324;330;427;426;400;401;429;428;409;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;567;101.8889,-3124.069;Float;False;616;DepthMaskDepth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;564;158.9352,-2431.092;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;562;156.3412,-2789.001;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;561;152.6772,-2970.025;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;409;-654.3083,-2094.966;Float;False;17;1;0;SAMPLER2D;_Sampler0409;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.TFHCRemapNode;576;334.0842,-2466.279;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.25;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;401;-493.1061,-1827.876;Float;False;Property;_SpeedY;Speed Y;12;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;429;-397.6901,-2021.954;Float;False;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;570;331.4902,-2824.188;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.25;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;571;332.7872,-2646.53;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.25;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;400;-493.1061,-1903.876;Float;False;Property;_SpeedX;Speed X;11;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;572;327.8261,-3005.212;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.25;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;428;-398.6901,-2095.954;Float;False;True;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;426;-157.9533,-1905.023;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;577;547.2043,-2429.241;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;427;-159.2404,-1809.802;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;578;540.9463,-2968.174;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;579;544.6104,-2787.15;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;433;499.3743,-32.09965;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;580;545.9073,-2609.492;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;585;716.0323,-2429.241;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;583;709.7743,-2968.174;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-111.9275,-1591.571;Float;False;Property;_RipplesSpeed;Ripples Speed;9;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;324;143.4197,-1420.992;Float;False;0;318;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;331;-91.43336,-1083.286;Float;False;Property;_RipplesSpeed2nd;Ripples Speed 2nd;10;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;403;-6.795111,-1813.008;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;395;-8.286322,-1884.929;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;582;713.4384,-2787.15;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;436;743.1566,-212.1641;Float;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;390;282.2306,-849.9135;Float;False;1461.211;418.619;Fade out distance;9;372;371;383;386;379;381;376;374;377;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SignOpNode;584;714.7354,-2609.492;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;437;791.1566,-36.16414;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;323;216.6448,-1077.606;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;402;240.2048,-1840.008;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;397;411.3367,-1411.901;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;589;829.8594,-2790.735;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;590;836.8594,-2968.735;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;591;834.8594,-2432.735;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;187;212.6087,-1585.886;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;410;-652.4905,-1708.684;Float;False;318;1;0;SAMPLER2D;_Sampler0410;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SaturateNode;588;836.8594,-2609.735;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;439;1047.157,-20.16417;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;372;316.962,-645.1572;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;371;394.0252,-784.2607;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;143.9139,-2135.175;Float;False;0;17;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;423;621.8347,-1728.734;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;321;582.1996,-1291.77;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.04,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;593;1046.518,-2745.114;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;320;579.8986,-1408.46;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.03,0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;19;584.6157,-2000.709;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.04,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;422;616.6877,-1857.411;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;22;582.1606,-2113.922;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.03,-0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;440;1315.282,-5.596604;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.25;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;377;588.7331,-717.3549;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;396;801.4038,-2113.971;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;415;801.7588,-2000.203;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;48;489.0466,-1583.145;Float;False;Property;_NormalPower;Normal Power;7;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;509.4568,-1079.188;Float;False;Property;_NormalPower2nd;Normal Power 2nd;8;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;416;803.3218,-1408.733;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;417;804.5358,-1292.272;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;594;1200.258,-2679.417;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;374;737.7332,-716.3549;Float;False;True;False;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;441;1523.553,-5.937486;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;931.7438,-1920.838;Float;True;Property;_Normal;Normal;5;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;318;935.6488,-1215.191;Float;True;Property;_Normal2nd;Normal 2nd;6;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;446;1801.504,-52.52217;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;319;935.1887,-1412.649;Float;True;Property;_TextureSample3;Texture Sample 3;6;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;318;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;931.2837,-2118.297;Float;True;Property;_Normal2;Normal2;5;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;17;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;595;1408.312,-2743.999;Float;False;DepthMaskUnderwater;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;376;965.733,-711.3549;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;824.7332,-573.3548;Float;False;Property;_OpacityViewDistance;Opacity View Distance;3;0;Create;True;0;0;False;0;300;300;1;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;24;1246.156,-2022.605;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;325;1246.471,-1323.134;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;615;1980.776,-567.9772;Float;False;595;DepthMaskUnderwater;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;617;1964.443,-644.8909;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;379;1145.733,-710.3548;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;386;1341.952,-708.9368;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;618;2271.645,-632.4808;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;326;1497.444,-1818.994;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;619;2406.501,-636.5368;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;431;1900.16,-825.612;Float;False;Property;_Opacity;Opacity;2;0;Create;True;0;0;False;0;0.5;0.22;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;383;1518.254,-709.1152;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;1709.844,-1824.446;Float;False;NormalWater;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;609;112.5346,-3709.481;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;560;157.6382,-2611.343;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;600;-278.6125,-3686.985;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;620;2561.794,-762.7046;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;368;2139.697,-905.4615;Float;False;Property;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;0;0.417;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;558;-58.27214,-2599.43;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;604;-82.58969,-3723.098;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;612;347.8686,-3718.834;Float;False;ShiftLeft;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;2202.455,-980.6006;Float;False;315;NormalWater;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;547;-190.3906,-2605.582;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;537;-448.1193,-2574.904;Float;False;612;ShiftLeft;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;392;2206.688,-1152.184;Float;False;Property;_Tint;Tint;0;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2790.751,-1027.1;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;QuantumFox/Water/Flat Depth Masked;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;True;False;Back;1;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;13;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;597;1;596;2
WireConnection;599;0;597;0
WireConnection;598;1;596;1
WireConnection;603;0;601;0
WireConnection;603;1;597;0
WireConnection;602;0;601;0
WireConnection;602;1;599;0
WireConnection;605;0;598;0
WireConnection;605;1;601;0
WireConnection;607;0;602;0
WireConnection;607;1;606;0
WireConnection;610;0;605;0
WireConnection;610;1;606;0
WireConnection;608;0;603;0
WireConnection;608;1;606;0
WireConnection;614;0;607;0
WireConnection;611;0;610;0
WireConnection;613;0;608;0
WireConnection;621;0;523;0
WireConnection;544;0;621;0
WireConnection;544;1;541;0
WireConnection;548;0;621;0
WireConnection;548;1;536;0
WireConnection;551;0;621;0
WireConnection;551;1;543;0
WireConnection;554;0;544;0
WireConnection;616;0;438;0
WireConnection;552;0;551;0
WireConnection;557;0;548;0
WireConnection;535;0;533;4
WireConnection;564;0;554;0
WireConnection;564;1;535;0
WireConnection;562;0;552;0
WireConnection;562;1;535;0
WireConnection;561;0;557;0
WireConnection;561;1;535;0
WireConnection;576;0;564;0
WireConnection;576;2;567;0
WireConnection;429;0;409;0
WireConnection;570;0;562;0
WireConnection;570;2;567;0
WireConnection;571;2;567;0
WireConnection;572;0;561;0
WireConnection;572;2;567;0
WireConnection;428;0;409;0
WireConnection;426;0;400;0
WireConnection;426;1;428;0
WireConnection;577;0;576;0
WireConnection;427;0;401;0
WireConnection;427;1;429;0
WireConnection;578;0;572;0
WireConnection;579;0;570;0
WireConnection;580;0;571;0
WireConnection;585;0;577;0
WireConnection;583;0;578;0
WireConnection;403;0;427;0
WireConnection;395;0;426;0
WireConnection;582;0;579;0
WireConnection;584;0;580;0
WireConnection;437;0;433;0
WireConnection;323;0;331;0
WireConnection;402;0;395;0
WireConnection;402;1;403;0
WireConnection;397;0;324;0
WireConnection;589;0;582;0
WireConnection;590;0;583;0
WireConnection;591;0;585;0
WireConnection;187;0;330;0
WireConnection;588;0;584;0
WireConnection;439;0;437;0
WireConnection;439;1;436;4
WireConnection;423;0;402;0
WireConnection;423;1;410;0
WireConnection;321;0;397;0
WireConnection;321;1;323;0
WireConnection;593;0;590;0
WireConnection;593;1;589;0
WireConnection;593;2;588;0
WireConnection;593;3;591;0
WireConnection;320;0;397;0
WireConnection;320;1;323;0
WireConnection;19;0;21;0
WireConnection;19;1;187;0
WireConnection;422;0;409;0
WireConnection;422;1;402;0
WireConnection;22;0;21;0
WireConnection;22;1;187;0
WireConnection;440;0;439;0
WireConnection;440;2;616;0
WireConnection;377;0;371;0
WireConnection;377;1;372;0
WireConnection;396;0;22;0
WireConnection;396;1;422;0
WireConnection;415;0;19;0
WireConnection;415;1;422;0
WireConnection;416;0;320;0
WireConnection;416;1;423;0
WireConnection;417;0;321;0
WireConnection;417;1;423;0
WireConnection;594;0;593;0
WireConnection;374;0;377;0
WireConnection;441;0;440;0
WireConnection;17;1;415;0
WireConnection;17;5;48;0
WireConnection;318;1;417;0
WireConnection;318;5;322;0
WireConnection;446;0;441;0
WireConnection;319;1;416;0
WireConnection;319;5;322;0
WireConnection;23;1;396;0
WireConnection;23;5;48;0
WireConnection;595;0;594;0
WireConnection;376;0;374;0
WireConnection;24;0;23;0
WireConnection;24;1;17;0
WireConnection;325;0;319;0
WireConnection;325;1;318;0
WireConnection;617;0;446;0
WireConnection;379;0;376;0
WireConnection;379;2;381;0
WireConnection;386;0;379;0
WireConnection;618;0;617;0
WireConnection;618;1;615;0
WireConnection;326;0;24;0
WireConnection;326;1;325;0
WireConnection;619;0;618;0
WireConnection;383;0;386;0
WireConnection;315;0;326;0
WireConnection;609;0;604;0
WireConnection;609;1;606;0
WireConnection;560;0;558;0
WireConnection;560;1;535;0
WireConnection;600;0;598;0
WireConnection;620;0;431;0
WireConnection;620;1;383;0
WireConnection;620;2;619;0
WireConnection;558;0;547;0
WireConnection;604;0;600;0
WireConnection;604;1;601;0
WireConnection;612;0;609;0
WireConnection;547;0;621;0
WireConnection;547;1;537;0
WireConnection;0;0;392;0
WireConnection;0;1;369;0
WireConnection;0;4;368;0
WireConnection;0;9;620;0
ASEEND*/
//CHKSM=3A1392C35C44B9847B4446B1579F428E6AB96552