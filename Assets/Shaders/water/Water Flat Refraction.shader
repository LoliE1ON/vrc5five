// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "QuantumFox/Water/Flat Refraction"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,0)
		_Tint("Tint", Color) = (0,0,0,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Normal("Normal", 2D) = "bump" {}
		_Normal2nd("Normal 2nd", 2D) = "bump" {}
		_NormalPower("Normal Power", Range( 0 , 1)) = 1
		_NormalPower2nd("Normal Power 2nd", Range( 0 , 1)) = 0.5
		_RefractionDistortion("Refraction Distortion", Range( 0 , 2)) = 0.01
		_RipplesSpeed("Ripples Speed", Range( 0 , 10)) = 1
		_RipplesSpeed2nd("Ripples Speed 2nd", Range( 0 , 10)) = 1
		_SpeedX("Speed X", Range( -10 , 10)) = 0
		_SpeedY("Speed Y", Range( -10 , 10)) = 0
		[Toggle]_UseOpacityViewDistance("Use Opacity View Distance", Float) = 0
		_OpacityViewDistanceClose("Opacity View Distance Close", Range( 1 , 1000)) = 30
		_OpacityViewDistanceFar("Opacity View Distance Far", Range( 1 , 1000)) = 300
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
		uniform float _RefractionDistortion;
		uniform float4 _Color;
		uniform float _Smoothness;
		uniform float _UseOpacityViewDistance;
		uniform float _OpacityViewDistanceClose;
		uniform float _OpacityViewDistanceFar;


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
			float2 NormalShift237 = (( temp_output_326_0 * _RefractionDistortion )).xy;
			float4 screenColor223 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xy + NormalShift237 ));
			o.Emission = ( screenColor223 * _Color ).rgb;
			o.Smoothness = _Smoothness;
			float3 ase_worldPos = i.worldPos;
			float smoothstepResult386 = smoothstep( 0.0 , 1.0 , (0.0 + (distance( (( ase_worldPos - _WorldSpaceCameraPos )).xz , float2( 0,0 ) ) - _OpacityViewDistanceClose) * (1.0 - 0.0) / (_OpacityViewDistanceFar - _OpacityViewDistanceClose)));
			o.Alpha = lerp(1.0,( 1.0 - smoothstepResult386 ),_UseOpacityViewDistance);
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
1927;32;1874;998;-575.8018;1600.467;1.383667;True;False
Node;AmplifyShaderEditor.CommentaryNode;151;-2909.847,-1646.241;Float;False;3102.678;1214.179;Normals Generation and Animation;42;237;358;315;98;389;326;325;24;319;318;17;23;322;417;48;416;415;396;19;423;422;320;22;321;410;187;402;397;323;21;395;324;403;331;330;426;427;429;428;400;401;409;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureTransformNode;409;-2863.437,-1564.611;Float;False;17;1;0;SAMPLER2D;_Sampler0409;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;401;-2702.235,-1297.521;Float;False;Property;_SpeedY;Speed Y;11;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;400;-2702.235,-1373.521;Float;False;Property;_SpeedX;Speed X;10;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;428;-2607.819,-1565.599;Float;False;True;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;429;-2606.819,-1491.599;Float;False;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;427;-2368.368,-1279.447;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;426;-2367.082,-1374.668;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-2321.055,-1061.216;Float;False;Property;_RipplesSpeed;Ripples Speed;8;0;Create;True;0;0;False;0;1;0.41;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;331;-2299.097,-552.931;Float;False;Property;_RipplesSpeed2nd;Ripples Speed 2nd;9;0;Create;True;0;0;False;0;1;2.11;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;403;-2215.924,-1282.653;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;324;-2065.709,-890.6371;Float;False;0;318;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;395;-2217.415,-1354.574;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-2065.215,-1604.821;Float;False;0;17;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;323;-1992.484,-547.251;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;397;-1797.792,-881.546;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;402;-1968.924,-1309.653;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;187;-1996.52,-1055.531;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;410;-2861.619,-1178.329;Float;False;318;1;0;SAMPLER2D;_Sampler0410;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.PannerNode;320;-1629.23,-878.1051;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.03,0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;422;-1592.441,-1327.056;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;423;-1587.294,-1198.379;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;19;-1624.513,-1470.354;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.03,0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;321;-1626.929,-761.4152;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.04,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;22;-1626.968,-1583.567;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.04,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;396;-1407.725,-1583.616;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1720.082,-1052.79;Float;False;Property;_NormalPower;Normal Power;5;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;416;-1405.807,-878.3781;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;417;-1404.593,-761.9172;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-1699.672,-548.8328;Float;False;Property;_NormalPower2nd;Normal Power 2nd;6;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;415;-1407.37,-1469.848;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;17;-1277.385,-1390.483;Float;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;318;-1273.48,-684.8356;Float;True;Property;_Normal2nd;Normal 2nd;4;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;319;-1273.94,-882.2941;Float;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;318;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-1277.845,-1587.942;Float;True;Property;_Normal2;Normal2;3;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;17;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;390;282.2306,-849.9135;Float;False;1461.211;418.619;Fade out distance;10;372;371;383;386;379;381;376;374;377;430;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BlendNormalsNode;325;-962.6577,-792.7792;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;24;-962.9726,-1492.25;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;371;394.0252,-784.2607;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;372;316.962,-645.1572;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;389;-875.5095,-589.8431;Float;False;Property;_RefractionDistortion;Refraction Distortion;7;0;Create;True;0;0;False;0;0.01;0.01;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;326;-711.6845,-1288.639;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;377;588.7331,-717.3549;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-452.5603,-1289.005;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;374;737.7332,-716.3549;Float;False;True;False;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;150;894.0531,-1171.357;Float;False;840.6733;261.7677;Final Refracted Image;5;223;96;238;165;220;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;358;-278.4183,-1289.981;Float;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;381;826.7332,-520.3548;Float;False;Property;_OpacityViewDistanceFar;Opacity View Distance Far;14;0;Create;True;0;0;False;0;300;300;1;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;430;790.8016,-605.4443;Float;False;Property;_OpacityViewDistanceClose;Opacity View Distance Close;13;0;Create;True;0;0;False;0;30;300;1;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;376;965.733,-711.3549;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;220;914.9148,-1118.258;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;237;-69.60783,-1290.165;Float;False;NormalShift;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;379;1145.733,-710.3548;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;165;1158.214,-1119.054;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;238;1151.897,-1022.511;Float;False;237;NormalShift;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;386;1341.952,-708.9368;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;1384.316,-1114.786;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;393;1793.322,-916.4568;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;383;1518.254,-709.1152;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;-455.0525,-1398.849;Float;False;NormalWater;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenColorNode;223;1525.913,-1121.245;Float;False;Global;_GrabScreen0;Grab Screen 0;-1;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;369;2367.866,-1018.132;Float;False;315;NormalWater;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;392;2370.24,-1197.198;Float;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;431;1966.802,-735.4443;Float;False;Property;_UseOpacityViewDistance;Use Opacity View Distance;12;0;Create;True;0;0;False;0;0;2;0;FLOAT;1;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;394;2066.177,-980.8381;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;368;2332.447,-863.4475;Float;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;False;0;0;0.564;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2683.271,-1026.086;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;QuantumFox/Water/Flat Refraction;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;True;False;Back;1;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;15;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;428;0;409;0
WireConnection;429;0;409;0
WireConnection;427;0;401;0
WireConnection;427;1;429;0
WireConnection;426;0;400;0
WireConnection;426;1;428;0
WireConnection;403;0;427;0
WireConnection;395;0;426;0
WireConnection;323;0;331;0
WireConnection;397;0;324;0
WireConnection;402;0;395;0
WireConnection;402;1;403;0
WireConnection;187;0;330;0
WireConnection;320;0;397;0
WireConnection;320;1;323;0
WireConnection;422;0;409;0
WireConnection;422;1;402;0
WireConnection;423;0;402;0
WireConnection;423;1;410;0
WireConnection;19;0;21;0
WireConnection;19;1;187;0
WireConnection;321;0;397;0
WireConnection;321;1;323;0
WireConnection;22;0;21;0
WireConnection;22;1;187;0
WireConnection;396;0;22;0
WireConnection;396;1;422;0
WireConnection;416;0;320;0
WireConnection;416;1;423;0
WireConnection;417;0;321;0
WireConnection;417;1;423;0
WireConnection;415;0;19;0
WireConnection;415;1;422;0
WireConnection;17;1;415;0
WireConnection;17;5;48;0
WireConnection;318;1;417;0
WireConnection;318;5;322;0
WireConnection;319;1;416;0
WireConnection;319;5;322;0
WireConnection;23;1;396;0
WireConnection;23;5;48;0
WireConnection;325;0;319;0
WireConnection;325;1;318;0
WireConnection;24;0;23;0
WireConnection;24;1;17;0
WireConnection;326;0;24;0
WireConnection;326;1;325;0
WireConnection;377;0;371;0
WireConnection;377;1;372;0
WireConnection;98;0;326;0
WireConnection;98;1;389;0
WireConnection;374;0;377;0
WireConnection;358;0;98;0
WireConnection;376;0;374;0
WireConnection;237;0;358;0
WireConnection;379;0;376;0
WireConnection;379;1;430;0
WireConnection;379;2;381;0
WireConnection;165;0;220;0
WireConnection;386;0;379;0
WireConnection;96;0;165;0
WireConnection;96;1;238;0
WireConnection;383;0;386;0
WireConnection;315;0;326;0
WireConnection;223;0;96;0
WireConnection;431;1;383;0
WireConnection;394;0;223;0
WireConnection;394;1;393;0
WireConnection;0;0;392;0
WireConnection;0;1;369;0
WireConnection;0;2;394;0
WireConnection;0;4;368;0
WireConnection;0;9;431;0
ASEEND*/
//CHKSM=840A8C7DDC0ACEFCB81BD2D2A1004345C9D7394D