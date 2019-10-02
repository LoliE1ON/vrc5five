// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "QuantumFox/Water/Flat Refraction Depth"
{
	Properties
	{
		[Header(Colors)]
		_Color("Color", Color) = (1,1,1,0)
		_Tint("Tint", Color) = (0,0,0,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_DepthColor("Depth Color", Color) = (0.2172361,0.3014706,0.2596439,0)
		_Depth("Depth", Range( 0 , 100)) = 0.5
		_OpacityViewDistance("Opacity View Distance", Range( 1 , 1000)) = 300
		[Header(Normals)]
		_Normal("Normal", 2D) = "bump" {}
		_Normal2nd("Normal 2nd", 2D) = "bump" {}
		_NormalPower("Normal Power", Range( 0 , 1)) = 1
		_NormalPower2nd("Normal Power 2nd", Range( 0 , 1)) = 0.5
		_RefractionDistortion("Refraction Distortion", Range( 0 , 2)) = 0.01
		[Header(Animations)]
		_RipplesSpeed("Ripples Speed", Range( 0 , 10)) = 1
		_RipplesSpeed2nd("Ripples Speed 2nd", Range( 0 , 10)) = 1
		_SpeedX("Speed X", Range( -10 , 10)) = 0
		_SpeedY("Speed Y", Range( -10 , 10)) = 0
		[Header(Fixes)]
		_DepthSmoothing("Depth Smoothing", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Add
		GrabPass{ }
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 5.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
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
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthSmoothing;
		uniform float _RefractionDistortion;
		uniform float4 _Color;
		uniform float4 _DepthColor;
		uniform float _Depth;
		uniform float _Smoothness;
		uniform float _OpacityViewDistance;


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
			float2 panner22 = ( mulTime187 * float2( -0.04,0 ) + uv0_Normal);
			float mulTime395 = _Time.y * ( _SpeedX / (_Normal_ST.xy).x );
			float mulTime403 = _Time.y * ( _SpeedY / (_Normal_ST.xy).y );
			float2 appendResult402 = (float2(mulTime395 , mulTime403));
			float2 temp_output_422_0 = ( _Normal_ST.xy * appendResult402 );
			float2 panner19 = ( mulTime187 * float2( 0.03,0.03 ) + uv0_Normal);
			float mulTime323 = _Time.y * _RipplesSpeed2nd;
			float2 uv0_Normal2nd = i.uv_texcoord * _Normal2nd_ST.xy + _Normal2nd_ST.zw;
			float2 temp_output_397_0 = ( uv0_Normal2nd + float2( 0,0 ) );
			float2 panner320 = ( mulTime323 * float2( 0.03,0.03 ) + temp_output_397_0);
			float2 temp_output_423_0 = ( appendResult402 * _Normal2nd_ST.xy );
			float2 panner321 = ( mulTime323 * float2( -0.04,0 ) + temp_output_397_0);
			float3 temp_output_326_0 = BlendNormals( BlendNormals( UnpackScaleNormal( tex2D( _Normal, ( panner22 + temp_output_422_0 ) ), _NormalPower ) , UnpackScaleNormal( tex2D( _Normal, ( panner19 + temp_output_422_0 ) ), _NormalPower ) ) , BlendNormals( UnpackScaleNormal( tex2D( _Normal2nd, ( panner320 + temp_output_423_0 ) ), _NormalPower2nd ) , UnpackScaleNormal( tex2D( _Normal2nd, ( panner321 + temp_output_423_0 ) ), _NormalPower2nd ) ) );
			float3 NormalWater315 = temp_output_326_0;
			o.Normal = NormalWater315;
			o.Albedo = _Tint.rgb;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float eyeDepth167 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos )));
			float2 NormalShift237 = (( temp_output_326_0 * saturate( (0.0 + (( eyeDepth167 - ase_screenPos.w ) - 0.0) * (1.0 - 0.0) / (_DepthSmoothing - 0.0)) ) * _RefractionDistortion )).xy;
			float4 screenColor223 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xy + NormalShift237 ));
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth527 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( ( ase_screenPosNorm + float4( NormalShift237, 0.0 , 0.0 ) ) )));
			float4 lerpResult448 = lerp( ( screenColor223 * _Color ) , _DepthColor , saturate( (0.0 + (( eyeDepth527 - ase_grabScreenPos.a ) - 0.0) * (1.0 - 0.0) / (_Depth - 0.0)) ));
			o.Emission = lerpResult448.rgb;
			o.Smoothness = _Smoothness;
			float3 ase_worldPos = i.worldPos;
			float smoothstepResult386 = smoothstep( 0.0 , 1.0 , (0.0 + (distance( (( ase_worldPos - _WorldSpaceCameraPos )).xz , float2( 0,0 ) ) - 0.0) * (1.0 - 0.0) / (_OpacityViewDistance - 0.0)));
			o.Alpha = ( 1.0 - smoothstepResult386 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
1927;32;1874;998;1572.549;2258.689;2.647448;True;False
Node;AmplifyShaderEditor.CommentaryNode;151;-3653.02,-1909.336;Float;False;3686.834;1339.161;Normals Generation and Animation;42;409;315;237;358;98;326;389;325;24;17;318;319;23;415;416;417;396;322;48;19;22;321;320;187;21;397;410;323;402;331;324;330;403;395;400;401;422;423;426;427;428;429;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureTransformNode;409;-3345.777,-1827.706;Float;False;17;1;0;SAMPLER2D;_Sampler0409;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.ComponentMaskNode;429;-3089.159,-1754.694;Float;False;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;428;-3090.159,-1828.694;Float;False;True;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;400;-3184.575,-1636.616;Float;False;Property;_SpeedX;Speed X;11;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;401;-3184.575,-1560.616;Float;False;Property;_SpeedY;Speed Y;12;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;427;-2850.709,-1542.542;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;426;-2849.422,-1637.763;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;324;-2548.049,-1153.732;Float;False;0;318;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;330;-2803.396,-1324.311;Float;False;Property;_RipplesSpeed;Ripples Speed;9;0;Create;True;0;0;False;0;1;0.41;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;331;-2781.438,-816.0256;Float;False;Property;_RipplesSpeed2nd;Ripples Speed 2nd;10;0;Create;True;0;0;False;0;1;2.11;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;403;-2698.264,-1545.748;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;395;-2699.755,-1617.669;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;410;-3343.959,-1441.424;Float;False;318;1;0;SAMPLER2D;_Sampler0410;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleAddOpNode;397;-2280.132,-1144.641;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;323;-2474.824,-810.3456;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;402;-2451.264,-1572.748;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;187;-2478.86,-1318.626;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;236;-1939.773,-477.1721;Float;False;972.9725;344.809;Regular Depth For Smoothing;6;232;167;229;230;168;166;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-2547.555,-1867.915;Float;False;0;17;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;422;-2074.781,-1590.151;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;22;-2109.308,-1846.662;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.04,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;320;-2111.57,-1141.2;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.03,0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;19;-2106.853,-1733.449;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.03,0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;321;-2109.269,-1024.51;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.04,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;166;-1901.664,-428.3296;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;423;-2069.634,-1461.474;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;416;-1888.147,-1141.473;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2202.422,-1315.885;Float;False;Property;_NormalPower;Normal Power;6;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-2182.012,-811.9274;Float;False;Property;_NormalPower2nd;Normal Power 2nd;7;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;167;-1707.031,-426.2231;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;417;-1886.933,-1025.012;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;415;-1889.71,-1732.943;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;396;-1890.065,-1846.711;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;23;-1760.185,-1851.037;Float;True;Property;_Normal2;Normal2;4;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;17;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;-1759.725,-1653.578;Float;True;Property;_Normal;Normal;4;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;319;-1756.28,-1145.389;Float;True;Property;_TextureSample3;Texture Sample 3;5;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;318;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;229;-1905.017,-233.2215;Float;False;Property;_DepthSmoothing;Depth Smoothing;15;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;318;-1755.82,-947.9305;Float;True;Property;_Normal2nd;Normal 2nd;5;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;168;-1489.354,-422.8807;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;230;-1332.777,-423.4864;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.25;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;24;-1445.313,-1755.345;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;325;-1444.998,-1055.874;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;232;-1147.774,-423.8273;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;326;-1194.025,-1551.734;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-1357.85,-852.9377;Float;False;Property;_RefractionDistortion;Refraction Distortion;8;0;Create;True;0;0;False;0;0.01;0.01;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-934.9008,-1552.1;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;358;-559.7008,-1555.793;Float;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;390;634.7104,-832.9492;Float;False;1461.211;418.619;Fade out distance;9;372;371;383;386;379;381;376;374;377;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;534;684.6469,-261.3635;Float;False;1405.218;489.8901;Depth Refraction;9;524;529;527;528;526;525;445;533;532;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;237;-350.89,-1555.977;Float;False;NormalShift;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;372;669.4418,-628.1929;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;150;744.9668,-1326.149;Float;False;1341.654;394.7715;Final Refracted Image;5;96;238;165;220;223;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;371;746.5051,-767.2964;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenPosInputsNode;525;733.0696,-131.334;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;524;736.1156,38.57394;Float;False;237;NormalShift;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;220;774.6955,-1135.613;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;377;941.213,-700.3906;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;526;989.0696,-35.334;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenDepthNode;527;1149.07,-35.334;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;374;1090.213,-699.3906;Float;False;True;False;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;528;1101.07,-211.334;Float;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;238;1011.677,-1039.866;Float;False;237;NormalShift;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;165;1017.994,-1136.409;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;376;1318.213,-694.3906;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;445;1275.536,84.65534;Float;False;Property;_Depth;Depth;14;0;Create;True;0;0;False;0;0.5;1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;529;1405.07,-19.33403;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;1177.213,-556.3905;Float;False;Property;_OpacityViewDistance;Opacity View Distance;3;0;Create;True;0;0;False;0;300;300;1;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;1245.575,-1132.141;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;223;1461.064,-1146.246;Float;False;Global;_GrabScreen0;Grab Screen 0;-1;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;379;1498.213,-693.3905;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;393;2225.837,-872.2025;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;532;1673.195,-4.766465;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.25;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;-937.3928,-1661.944;Float;False;NormalWater;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;386;1694.432,-691.9725;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;394;2534.1,-926.2949;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;533;1881.466,-5.107347;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;449;2193.646,-628.5821;Float;False;Property;_DepthColor;Depth Color;13;0;Create;True;0;0;False;0;0.2172361,0.3014706,0.2596439,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;392;2441.833,-1358.481;Float;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;368;2376.903,-1106.15;Float;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;False;0;0;0.564;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;448;2764.632,-900.7882;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;383;1870.734,-692.1509;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;2440.589,-1184.089;Float;False;315;NormalWater;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3003.825,-1028.898;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;QuantumFox/Water/Flat Refraction Depth;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;True;False;Back;1;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;16;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;429;0;409;0
WireConnection;428;0;409;0
WireConnection;427;0;401;0
WireConnection;427;1;429;0
WireConnection;426;0;400;0
WireConnection;426;1;428;0
WireConnection;403;0;427;0
WireConnection;395;0;426;0
WireConnection;397;0;324;0
WireConnection;323;0;331;0
WireConnection;402;0;395;0
WireConnection;402;1;403;0
WireConnection;187;0;330;0
WireConnection;422;0;409;0
WireConnection;422;1;402;0
WireConnection;22;0;21;0
WireConnection;22;1;187;0
WireConnection;320;0;397;0
WireConnection;320;1;323;0
WireConnection;19;0;21;0
WireConnection;19;1;187;0
WireConnection;321;0;397;0
WireConnection;321;1;323;0
WireConnection;423;0;402;0
WireConnection;423;1;410;0
WireConnection;416;0;320;0
WireConnection;416;1;423;0
WireConnection;167;0;166;0
WireConnection;417;0;321;0
WireConnection;417;1;423;0
WireConnection;415;0;19;0
WireConnection;415;1;422;0
WireConnection;396;0;22;0
WireConnection;396;1;422;0
WireConnection;23;1;396;0
WireConnection;23;5;48;0
WireConnection;17;1;415;0
WireConnection;17;5;48;0
WireConnection;319;1;416;0
WireConnection;319;5;322;0
WireConnection;318;1;417;0
WireConnection;318;5;322;0
WireConnection;168;0;167;0
WireConnection;168;1;166;4
WireConnection;230;0;168;0
WireConnection;230;2;229;0
WireConnection;24;0;23;0
WireConnection;24;1;17;0
WireConnection;325;0;319;0
WireConnection;325;1;318;0
WireConnection;232;0;230;0
WireConnection;326;0;24;0
WireConnection;326;1;325;0
WireConnection;98;0;326;0
WireConnection;98;1;232;0
WireConnection;98;2;389;0
WireConnection;358;0;98;0
WireConnection;237;0;358;0
WireConnection;377;0;371;0
WireConnection;377;1;372;0
WireConnection;526;0;525;0
WireConnection;526;1;524;0
WireConnection;527;0;526;0
WireConnection;374;0;377;0
WireConnection;165;0;220;0
WireConnection;376;0;374;0
WireConnection;529;0;527;0
WireConnection;529;1;528;4
WireConnection;96;0;165;0
WireConnection;96;1;238;0
WireConnection;223;0;96;0
WireConnection;379;0;376;0
WireConnection;379;2;381;0
WireConnection;532;0;529;0
WireConnection;532;2;445;0
WireConnection;315;0;326;0
WireConnection;386;0;379;0
WireConnection;394;0;223;0
WireConnection;394;1;393;0
WireConnection;533;0;532;0
WireConnection;448;0;394;0
WireConnection;448;1;449;0
WireConnection;448;2;533;0
WireConnection;383;0;386;0
WireConnection;0;0;392;0
WireConnection;0;1;369;0
WireConnection;0;2;448;0
WireConnection;0;4;368;0
WireConnection;0;9;383;0
ASEEND*/
//CHKSM=30992F45090CAA6823C5877ADB0D3AA760373499