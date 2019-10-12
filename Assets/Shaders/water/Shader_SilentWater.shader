// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Silent/Clear Water"
{
	Properties
	{
    	[Header(Main)]
		_Tint("Tint", Color) = (1,1,1,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.95
		_Metallic("Metallic", Range( 0 , 1)) = 0
    	[Header(Waves)]
		[Normal]_Wave("Wave", 2D) = "bump" {}
		_WaveStrength("Wave Strength", Range( -2 , 2)) = 1
		_WaveScrollX("Wave Scroll X", Range( -1 , 1)) = 0
		_WaveScrollY("Wave Scroll Y", Range( -1 , 1)) = 0
		_WaveScrollSpeed("Wave Scroll Speed", Range( -1 , 1)) = 0
		[Normal]_Wave2("Wave 2", 2D) = "bump" {}
		_Wave2Strength("Wave 2 Strength", Range( -2 , 2)) = 1
		_Wave2ScrollX("Wave 2 Scroll X", Range( -1 , 1)) = 0
		_Wave2ScrollY("Wave 2 Scroll Y", Range( -1 , 1)) = 0
		_Wave2ScrollSpeed("Wave 2 Scroll Speed", Range( -1 , 1)) = 0
		_WaveReflectionDistortion("Wave Reflection Distortion", Range( 0 , 1)) = 0
    	[Header(Foam)]
		_Foam("Foam Texture", 2D) = "black" {}
		[HDR]_FoamColour("Foam Colour", Color) = (1,1,1,1)
		_foamMin("Foam End", Range( 0 , 1)) = 0
		_foamMax("Foam Start", Range( 0 , 1)) = 0
    	[Header(Depth)]
		_DepthColour("Depth Colour", Color) = (0,0,0,1)
		_DepthDistance("Depth Distance", Range( 0 , 100)) = 100
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Int) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		GrabPass{ }
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float eyeDepth;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform int _CullMode;
		uniform sampler2D _CameraDepthTexture;
		uniform float4 _Tint;
		uniform float _DepthDistance;
		uniform sampler2D _GrabTexture;
		uniform float _WaveStrength;
		uniform sampler2D _Wave;
		uniform half _WaveScrollSpeed;
		uniform half _WaveScrollX;
		uniform half _WaveScrollY;
		uniform float4 _Wave_ST;
		uniform float _Wave2Strength;
		uniform sampler2D _Wave2;
		uniform half _Wave2ScrollSpeed;
		uniform half _Wave2ScrollX;
		uniform half _Wave2ScrollY;
		uniform float4 _Wave2_ST;
		uniform float _WaveReflectionDistortion;
		uniform float _foamMin;
		uniform float _foamMax;
		uniform sampler2D _Foam;
		uniform float4 _Foam_ST;
		uniform float4 _FoamColour;
		uniform float4 _DepthColour;
		uniform float _Metallic;
		uniform float _Smoothness;


		int inInMirror(  )
		{
			return unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f;
		}


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float mulTime120 = _Time.y * _WaveScrollSpeed;
			float2 appendResult114 = (float2(_WaveScrollX , _WaveScrollY));
			float2 uv_Wave = i.uv_texcoord * _Wave_ST.xy + _Wave_ST.zw;
			float2 panner17 = ( mulTime120 * appendResult114 + uv_Wave);
			float mulTime119 = _Time.y * _Wave2ScrollSpeed;
			float2 appendResult115 = (float2(_Wave2ScrollX , _Wave2ScrollY));
			float2 uv_Wave2 = i.uv_texcoord * _Wave2_ST.xy + _Wave2_ST.zw;
			float2 panner24 = ( mulTime119 * appendResult115 + uv_Wave2);
			float3 finalNormals170 = BlendNormals( UnpackScaleNormal( tex2D( _Wave, panner17 ) ,_WaveStrength ) , UnpackScaleNormal( tex2D( _Wave2, panner24 ) ,_Wave2Strength ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float3 ase_worldPos = i.worldPos;
			float temp_output_272_0 = saturate( ( 1.0 / distance( _WorldSpaceCameraPos , ase_worldPos ) ) );
			float closeness295 = temp_output_272_0;
			float screenDepth315 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth315 = abs( ( screenDepth315 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( ( ( 1.0 - closeness295 ) * 0.5 ) + 0.1 ) ) );
			float depthFadeToSurface314 = distanceDepth315;
			float temp_output_139_0 = saturate( depthFadeToSurface314 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float cameraDepthFade26 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / length( ase_worldViewDir.y ));
			float cameraDepthFade38 = saturate( ( cameraDepthFade26 * 0.01 ) );
			float screenDepth35 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth35 = abs( ( screenDepth35 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( length( ase_worldViewDir.y ) + _DepthDistance ) ) );
			int localinInMirror291 = inInMirror();
			float depthFade74 = ( distanceDepth35 + localinInMirror291 );
			float temp_output_51_0 = saturate( depthFade74 );
			float finalOpacity221 = ( temp_output_139_0 * saturate( ( _Tint.a + cameraDepthFade38 + temp_output_51_0 ) ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 temp_output_200_0 = ddx( ase_worldNormal );
			float dotResult203 = dot( temp_output_200_0 , temp_output_200_0 );
			float3 temp_output_201_0 = ddy( ase_worldNormal );
			float dotResult204 = dot( temp_output_201_0 , temp_output_201_0 );
			float geomRoughnessFactor209 = ( 1.0 - pow( saturate( max( dotResult203 , dotResult204 ) ) , 0.3333333 ) );
			float3 lerpResult218 = lerp( float3( 0,0,0 ) , finalNormals170 , ( finalOpacity221 * _WaveReflectionDistortion * geomRoughnessFactor209 * temp_output_272_0 ));
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 temp_output_217_0 = ( float4( lerpResult218 , 0.0 ) + ase_grabScreenPosNorm );
			float4 screenColor29 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( temp_output_217_0 ) );
			float4 temp_cast_4 = (0.0).xxxx;
			#ifdef UNITY_PASS_FORWARDADD
				float4 staticSwitch332 = temp_cast_4;
			#else
				float4 staticSwitch332 = screenColor29;
			#endif
			float4 grabPass149 = staticSwitch332;
			float2 uv_Foam = i.uv_texcoord * _Foam_ST.xy + _Foam_ST.zw;
			float2 panner48 = ( 1.0 * _Time.y * float2( 0.1,0.1 ) + uv_Foam);
			float4 finalFoam191 = ( saturate( ( ( ( depthFade74 - _foamMin ) * closeness295 ) / ( ( _foamMax - _foamMin ) * closeness295 ) ) ) * tex2D( _Foam, panner48 ) * _FoamColour );
			float4 lerpResult56 = lerp( ( ( _Tint * grabPass149 ) + finalFoam191 ) , _DepthColour , ( _DepthColour.a * temp_output_51_0 ));
			float4 lerpResult128 = lerp( grabPass149 , lerpResult56 , temp_output_139_0);
			SurfaceOutputStandard s213 = (SurfaceOutputStandard ) 0;
			s213.Albedo = float3( 0,0,0 );
			s213.Normal = WorldNormalVector( i , finalNormals170 );
			s213.Emission = float3( 0,0,0 );
			s213.Metallic = _Metallic;
			s213.Smoothness = min( _Smoothness , geomRoughnessFactor209 );
			s213.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi213 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g213 = UnityGlossyEnvironmentSetup( s213.Smoothness, data.worldViewDir, s213.Normal, float3(0,0,0));
			gi213 = UnityGlobalIllumination( data, s213.Occlusion, s213.Normal, g213 );
			#endif

			float3 surfResult213 = LightingStandard ( s213, viewDir, gi213 ).rgb;
			surfResult213 += s213.Emission;

			float4 lerpResult260 = lerp( float4( 0,0,0,0 ) , ( lerpResult128 + float4( surfResult213 , 0.0 ) ) , finalOpacity221);
			c.rgb = lerpResult260.rgb;
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
			o.Normal = float3(0,0,1);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float3 ase_worldPos = i.worldPos;
			float temp_output_272_0 = saturate( ( 1.0 / distance( _WorldSpaceCameraPos , ase_worldPos ) ) );
			float closeness295 = temp_output_272_0;
			float screenDepth315 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth315 = abs( ( screenDepth315 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( ( ( 1.0 - closeness295 ) * 0.5 ) + 0.1 ) ) );
			float depthFadeToSurface314 = distanceDepth315;
			float temp_output_139_0 = saturate( depthFadeToSurface314 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float cameraDepthFade26 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / length( ase_worldViewDir.y ));
			float cameraDepthFade38 = saturate( ( cameraDepthFade26 * 0.01 ) );
			float screenDepth35 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth35 = abs( ( screenDepth35 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( length( ase_worldViewDir.y ) + _DepthDistance ) ) );
			int localinInMirror291 = inInMirror();
			float depthFade74 = ( distanceDepth35 + localinInMirror291 );
			float temp_output_51_0 = saturate( depthFade74 );
			float finalOpacity221 = ( temp_output_139_0 * saturate( ( _Tint.a + cameraDepthFade38 + temp_output_51_0 ) ) );
			float mulTime120 = _Time.y * _WaveScrollSpeed;
			float2 appendResult114 = (float2(_WaveScrollX , _WaveScrollY));
			float2 uv_Wave = i.uv_texcoord * _Wave_ST.xy + _Wave_ST.zw;
			float2 panner17 = ( mulTime120 * appendResult114 + uv_Wave);
			float mulTime119 = _Time.y * _Wave2ScrollSpeed;
			float2 appendResult115 = (float2(_Wave2ScrollX , _Wave2ScrollY));
			float2 uv_Wave2 = i.uv_texcoord * _Wave2_ST.xy + _Wave2_ST.zw;
			float2 panner24 = ( mulTime119 * appendResult115 + uv_Wave2);
			float3 finalNormals170 = BlendNormals( UnpackScaleNormal( tex2D( _Wave, panner17 ) ,_WaveStrength ) , UnpackScaleNormal( tex2D( _Wave2, panner24 ) ,_Wave2Strength ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 temp_output_200_0 = ddx( ase_worldNormal );
			float dotResult203 = dot( temp_output_200_0 , temp_output_200_0 );
			float3 temp_output_201_0 = ddy( ase_worldNormal );
			float dotResult204 = dot( temp_output_201_0 , temp_output_201_0 );
			float geomRoughnessFactor209 = ( 1.0 - pow( saturate( max( dotResult203 , dotResult204 ) ) , 0.3333333 ) );
			float3 lerpResult218 = lerp( float3( 0,0,0 ) , finalNormals170 , ( finalOpacity221 * _WaveReflectionDistortion * geomRoughnessFactor209 * temp_output_272_0 ));
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 temp_output_217_0 = ( float4( lerpResult218 , 0.0 ) + ase_grabScreenPosNorm );
			float4 screenColor29 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( temp_output_217_0 ) );
			float4 temp_cast_1 = (0.0).xxxx;
			#ifdef UNITY_PASS_FORWARDADD
				float4 staticSwitch332 = temp_cast_1;
			#else
				float4 staticSwitch332 = screenColor29;
			#endif
			float4 grabPass149 = staticSwitch332;
			o.Emission = ( ( 1.0 - finalOpacity221 ) * grabPass149 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.x = customInputData.eyeDepth;
				o.customPack1.yz = customInputData.uv_texcoord;
				o.customPack1.yz = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.eyeDepth = IN.customPack1.x;
				surfIN.uv_texcoord = IN.customPack1.yz;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
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
Version=15401
522;92;1398;651;2915.178;1012.459;1.0175;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;270;-4687,-861;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;269;-4767,-1005;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;172;-4019.792,874.2968;Float;False;1285;342.8;;11;225;35;247;244;58;243;74;294;291;314;315;Depth Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.DistanceOpNode;267;-4472,-874;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;173;-3984.462,1482.766;Float;False;963.072;202.254;;6;38;28;27;26;233;232;Camera Depth Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;243;-3985,927;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;279;-4298.162,-888.9142;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;232;-3969.305,1534.306;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LengthOpNode;244;-3808,928;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;272;-4175,-877;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-3978.102,1109.694;Float;False;Property;_DepthDistance;Depth Distance;21;0;Create;True;0;0;False;0;100;1.5;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;233;-3826.276,1586.196;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;247;-3616,928;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;210;-3993.113,-517.6009;Float;False;1972;457.4999;For specular AA;10;209;208;207;206;203;205;204;202;201;200;Geometric Roughness Factor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;-3820.993,1253.459;Float;False;295;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-4175.075,-768.3459;Float;False;closeness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;26;-3710.526,1558.554;Float;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;291;-3255.129,989.4487;Float;False;return unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f@;0;False;0;inInMirror;False;False;0;1;INT;0
Node;AmplifyShaderEditor.DepthFade;35;-3485,929;Float;False;True;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;321;-3662.993,1251.459;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;202;-3943.421,-316.5603;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;294;-3086.521,920.8829;Float;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DdxOpNode;200;-3602.021,-344.4519;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DdyOpNode;201;-3596.021,-233.452;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;325;-3491.993,1259.459;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-3480.093,1558.249;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-2955.455,918.8064;Float;False;depthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-1172.466,281.9634;Float;False;74;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;204;-3338.021,-254.452;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;203;-3333.021,-374.4518;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;28;-3353.557,1558.4;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;324;-3348.993,1262.459;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;169;-4010.134,16.29915;Float;False;1988.149;784.2443;Generate normals;22;113;117;118;112;111;109;170;19;22;8;24;123;17;122;115;119;23;18;152;141;114;120;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-3970.909,486.6537;Half;False;Property;_Wave2ScrollX;Wave 2 Scroll X;10;0;Create;True;0;0;False;0;0;0.128;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-3970.909,282.6537;Half;False;Property;_WaveScrollX;Wave Scroll X;5;0;Create;True;0;0;False;0;0;0.061;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;205;-3080.021,-369.4518;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-3971.733,635.7255;Half;False;Property;_Wave2ScrollSpeed;Wave 2 Scroll Speed;12;0;Create;True;0;0;False;0;0;0.478;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;51;-904.406,290.293;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-3968.909,353.6536;Half;False;Property;_WaveScrollY;Wave Scroll Y;6;0;Create;True;0;0;False;0;0;0.066;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-3971.317,416.6535;Half;False;Property;_WaveScrollSpeed;Wave Scroll Speed;7;0;Create;True;0;0;False;0;0;-0.567;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-3222.911,1552.909;Float;False;cameraDepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-1128.67,-270.0518;Float;False;Property;_Tint;Tint;0;0;Create;True;0;0;False;0;1,1,1,0;0.5514706,0.5514706,0.5514706,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;315;-3200.203,1115.672;Float;False;True;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-3969.317,556.6537;Half;False;Property;_Wave2ScrollY;Wave 2 Scroll Y;11;0;Create;True;0;0;False;0;0;0.119;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1096,140;Float;False;38;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;206;-2905.021,-359.4518;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;115;-3611.909,503.4537;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;119;-3488.326,660.8664;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-3489.897,512.1833;Float;False;0;22;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-719.7869,-35.51941;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;114;-3612.909,336.4537;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-668.7638,-474.0236;Float;False;314;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;120;-3500.326,423.8663;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-3471.896,242.7833;Float;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-2975.608,1108.72;Float;False;depthFadeToSurface;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;207;-2620.021,-323.4519;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.3333333;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;24;-3241.896,554.1833;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.1,-0.05;False;1;FLOAT;0.05;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;41;-563.7002,27.70447;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;17;-3246.496,313.1833;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;139;-229.3799,-221.8316;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-3279.184,675.6748;Float;False;Property;_Wave2Strength;Wave 2 Strength;9;0;Create;True;0;0;False;0;1;-1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-3285.115,461.1092;Float;False;Property;_WaveStrength;Wave Strength;4;0;Create;True;0;0;False;0;1;1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;-61.82141,48.88068;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;208;-2444.021,-335.4519;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;242;-3992.019,-1264.411;Float;False;1964;729.8;For underwater;16;218;30;29;251;253;49;217;223;215;219;222;266;300;301;332;333;Grab Pass;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;8;-2938.089,311.2726;Float;True;Property;_Wave;Wave;3;1;[Normal];Create;True;0;0;False;0;7e48a27a7c3a47c4fb744d596d256978;b0f741d31156b5a40a42dc6cc4e8eabf;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-2940.469,503.0291;Float;True;Property;_Wave2;Wave 2;8;1;[Normal];Create;True;0;0;False;0;7e48a27a7c3a47c4fb744d596d256978;b0f741d31156b5a40a42dc6cc4e8eabf;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;219;-3966.228,-907.7805;Float;False;Property;_WaveReflectionDistortion;Wave Reflection Distortion;13;0;Create;True;0;0;False;0;0;0.137;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-3965.038,-985.9588;Float;False;221;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;209;-2277.118,-346.0005;Float;False;geomRoughnessFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;530.9764,223.116;Float;False;finalOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;193;-2671.407,865.0432;Float;False;1517;848;;19;280;191;43;94;42;72;48;53;93;47;92;91;96;97;95;327;328;329;331;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;-3983.228,-1147.16;Float;False;209;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;19;-2457.896,400.1832;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-3677.829,-957.8582;Float;False;4;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-2238.952,396.9818;Float;False;finalNormals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;-3962.326,-1061.004;Float;False;170;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-2595.877,935.053;Float;False;74;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2621.877,1024.052;Float;False;Property;_foamMin;Foam End;17;0;Create;False;0;0;False;0;0;0.111;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-2628.877,1118.053;Float;False;Property;_foamMax;Foam Start;18;0;Create;False;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;30;-3851.059,-790.1231;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;218;-3457.631,-1094.252;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;327;-2341.315,1146.734;Float;False;295;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;-2342.049,961.3599;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;92;-2338.378,1057.137;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-2641.247,1231.172;Float;False;0;42;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;217;-2658.941,-718.7766;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;328;-2094.315,935.734;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;329;-2092.315,1056.734;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;333;-2535.65,-942.2516;Float;False;Constant;_Float1;Float 1;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;29;-2486.135,-799.2603;Float;False;Global;_GrabScreen0;Grab Screen 0;5;0;Create;True;0;0;False;0;Object;-1;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;48;-2397.805,1243.202;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;93;-1893.379,1030.138;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;332;-2296.538,-954.4619;Float;False;Property;_Addpass;Add pass?;29;0;Fetch;True;0;0;False;0;0;0;0;False;UNITY_PASS_FORWARDADD;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;94;-1764.38,1032.138;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;280;-2015.763,1504.494;Float;False;Property;_FoamColour;Foam Colour;15;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;42;-2200.778,1212.635;Float;True;Property;_Foam;Foam;14;0;Create;True;0;0;False;0;0395b2e2f8bd404489fbdd5d0640431e;9f4e5dbce52c3d549a62050c70c608be;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-2260.756,-725.3028;Float;False;grabPass1;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;241;-1044.95,-78.36148;Float;False;49;0;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1656.933,1180.557;Float;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;52;-648.9909,138.6899;Float;False;Property;_DepthColour;Depth Colour;20;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;192;-680.8459,-120.9327;Float;False;191;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;191;-1428.713,1227.982;Float;False;finalFoam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-843.7742,-189.0846;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;7;66.3954,309.9192;Float;False;Property;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;0.95;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-385.3701,250.4218;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-470.6645,-188.3357;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;70.1459,393.1124;Float;False;209;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;211;531.1459,122.1124;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-59.82116,-128.9663;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;457.2377,-23.5946;Float;False;170;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-125.627,-302.8554;Float;False;49;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;163.8069,4.832649;Float;False;Property;_Metallic;Metallic;2;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;370.7047,-192.3962;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;213;760.1786,-43.11932;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;174;2783.594,-431.3829;Float;False;2204.06;1397.66;;29;82;86;85;88;37;81;36;76;87;67;9;25;70;69;100;99;98;102;259;168;177;179;188;189;155;178;180;197;199;Scraps;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;283;846.2562,304.3807;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;263;1021.282,-171.6645;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;176;-832.7255,1430.985;Float;False;1999.3;776;;16;145;175;144;80;148;157;153;154;149;77;146;147;165;142;166;284;Vertex offset for waves;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;839.1249,178.6357;Float;False;49;0;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;72;-1959.431,1418.602;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;157;112.3418,1759.22;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-2207.908,1413.845;Float;False;38;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;166;124.5697,1989.163;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-87.54906,1916.36;Float;False;Property;_HeightScale;Height Scale;23;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;149;-781.7371,1764.982;Float;False;0;142;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;87;3229.244,253.3494;Float;False;3;0;FLOAT;0;False;1;FLOAT;10;False;2;FLOAT;-9;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;284.5697,1797.162;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;253;-2265.186,-635.9329;Float;False;screenDepth1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-766.3858,1891.103;Float;False;141;0;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;9;2848.427,-341.4815;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;189;4389.907,63.48355;Float;False;Property;_UseTessellation;Use Tessellation;26;0;Fetch;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;282;1178.256,304.3807;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;141;-3454.581,74.16081;Float;False;mainUVScrollXY;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-776.0864,1978.043;Float;False;152;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;185;-3377.886,1898.235;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;225;-3632,1103;Float;False;depthDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;99;3259.436,757.4616;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;153;-479.675,1746.665;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;183;-3795.597,1751.647;Float;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;146;412.5693,1733.162;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-87.20265,1989.163;Float;False;38;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;-2847.289,-1036.62;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;67;3808.843,238.5665;Float;False;3;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;3662.416,178.9606;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;182;-3987.597,1751.647;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;25;3087.745,-323.5251;Float;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;300;-3279.289,-1060.62;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;36;3376.871,112.8667;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;144;165.9363,1560.379;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;894.446,1621.914;Float;False;finalHeightVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;165;284.5697,1973.163;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.75;False;2;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-766.0098,-291.8351;Float;False;295;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;4117.909,-64.51652;Float;False;175;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;199;4469.492,407.836;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;259;4677.907,-32.51652;Float;False;Global;_GrabScreen1;Grab Screen 1;27;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;197;4124.494,457.836;Float;False;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;3079.735,715.0616;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;326;-683.7815,721.7351;Float;False;Property;_CullMode;Cull Mode;27;1;[Enum];Create;True;0;1;UnityEngine.Rendering.CullMode;True;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;536.3393,318.7927;Float;False;74;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;179;3941.909,-160.5165;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;319;-542.0098,-304.8351;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;331;-1881.315,1278.734;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;260;1173.673,185.7954;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-507.4075,-573.0392;Float;False;Property;_Float0;Edge Fade;19;0;Create;False;0;0;False;0;0.1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;186;-3199.886,1759.235;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;3485.736,783.0616;Float;False;waveOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;168;4389.907,-96.51649;Float;False;Property;_UseTessellation;Use Tessellation;25;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;187;-3013.886,1796.235;Float;False;False;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;2807.488,283.1704;Float;False;Property;_FoamPower;Foam Power;16;0;Create;True;0;0;False;0;3;3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;37;3245.253,109.4427;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;142;-195.4304,1717.162;Float;True;Property;_Height;Height;22;0;Create;True;0;0;False;0;None;111d6c7bba262844b9d4f718e8d0198f;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;184;-3587.597,1751.647;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;155;4101.909,175.4835;Float;False;1;0;FLOAT;32;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NegateNode;86;3574.416,276.9604;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;88;3445.834,274.1714;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;3279.342,-310.4996;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;180;4101.909,303.4836;Float;False;1;0;FLOAT;1024;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;2920.227,122.6717;Float;False;74;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-3307.809,168.2128;Float;False;mainUVScrollSpeed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;145;583.5695,1582.161;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;188;4021.909,31.4836;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;178;4389.907,239.4837;Float;False;Property;_UseTessellation;Use Tessellation;25;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;102;2840.962,826.7126;Float;False;Property;_VertexDistortionStrength;Vertex Distortion Strength;24;0;Create;True;0;0;False;0;0;0.016;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;904.022,503.7049;Float;False;314;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;707.395,1477.233;Float;False;38;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;69;3433.088,-311.6137;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;251;-2483.702,-631.8203;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;3083.743,156.2577;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1521.053,50.89421;Float;False;True;7;Float;ASEMaterialInspector;0;0;CustomLighting;Silent/Clear Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;32;497.4;1100;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;True;326;-1;0;False;-1;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;267;0;269;0
WireConnection;267;1;270;0
WireConnection;279;1;267;0
WireConnection;244;0;243;2
WireConnection;272;0;279;0
WireConnection;233;0;232;2
WireConnection;247;0;244;0
WireConnection;247;1;58;0
WireConnection;295;0;272;0
WireConnection;26;0;233;0
WireConnection;35;0;247;0
WireConnection;321;0;320;0
WireConnection;294;0;35;0
WireConnection;294;1;291;0
WireConnection;200;0;202;0
WireConnection;201;0;202;0
WireConnection;325;0;321;0
WireConnection;27;0;26;0
WireConnection;74;0;294;0
WireConnection;204;0;201;0
WireConnection;204;1;201;0
WireConnection;203;0;200;0
WireConnection;203;1;200;0
WireConnection;28;0;27;0
WireConnection;324;0;325;0
WireConnection;205;0;203;0
WireConnection;205;1;204;0
WireConnection;51;0;75;0
WireConnection;38;0;28;0
WireConnection;315;0;324;0
WireConnection;206;0;205;0
WireConnection;115;0;112;0
WireConnection;115;1;113;0
WireConnection;119;0;118;0
WireConnection;10;0;5;4
WireConnection;10;1;39;0
WireConnection;10;2;51;0
WireConnection;114;0;109;0
WireConnection;114;1;111;0
WireConnection;120;0;117;0
WireConnection;314;0;315;0
WireConnection;207;0;206;0
WireConnection;24;0;23;0
WireConnection;24;2;115;0
WireConnection;24;1;119;0
WireConnection;41;0;10;0
WireConnection;17;0;18;0
WireConnection;17;2;114;0
WireConnection;17;1;120;0
WireConnection;139;0;136;0
WireConnection;214;0;139;0
WireConnection;214;1;41;0
WireConnection;208;0;207;0
WireConnection;8;1;17;0
WireConnection;8;5;122;0
WireConnection;22;1;24;0
WireConnection;22;5;123;0
WireConnection;209;0;208;0
WireConnection;221;0;214;0
WireConnection;19;0;8;0
WireConnection;19;1;22;0
WireConnection;223;0;222;0
WireConnection;223;1;219;0
WireConnection;223;2;266;0
WireConnection;223;3;272;0
WireConnection;170;0;19;0
WireConnection;218;1;215;0
WireConnection;218;2;223;0
WireConnection;91;0;95;0
WireConnection;91;1;96;0
WireConnection;92;0;97;0
WireConnection;92;1;96;0
WireConnection;217;0;218;0
WireConnection;217;1;30;0
WireConnection;328;0;91;0
WireConnection;328;1;327;0
WireConnection;329;0;92;0
WireConnection;329;1;327;0
WireConnection;29;0;217;0
WireConnection;48;0;47;0
WireConnection;93;0;328;0
WireConnection;93;1;329;0
WireConnection;332;1;29;0
WireConnection;332;0;333;0
WireConnection;94;0;93;0
WireConnection;42;1;48;0
WireConnection;49;0;332;0
WireConnection;43;0;94;0
WireConnection;43;1;42;0
WireConnection;43;2;280;0
WireConnection;191;0;43;0
WireConnection;31;0;5;0
WireConnection;31;1;241;0
WireConnection;66;0;52;4
WireConnection;66;1;51;0
WireConnection;44;0;31;0
WireConnection;44;1;192;0
WireConnection;211;0;7;0
WireConnection;211;1;212;0
WireConnection;56;0;44;0
WireConnection;56;1;52;0
WireConnection;56;2;66;0
WireConnection;128;0;50;0
WireConnection;128;1;56;0
WireConnection;128;2;139;0
WireConnection;213;1;171;0
WireConnection;213;3;6;0
WireConnection;213;4;211;0
WireConnection;283;0;221;0
WireConnection;263;0;128;0
WireConnection;263;1;213;0
WireConnection;72;0;53;0
WireConnection;157;0;142;1
WireConnection;166;0;80;0
WireConnection;87;0;36;0
WireConnection;147;0;157;0
WireConnection;147;1;148;0
WireConnection;147;2;165;0
WireConnection;253;0;251;0
WireConnection;189;1;188;0
WireConnection;282;0;283;0
WireConnection;282;1;261;0
WireConnection;141;0;114;0
WireConnection;185;0;184;0
WireConnection;225;0;58;0
WireConnection;99;0;98;0
WireConnection;99;1;102;0
WireConnection;153;0;149;0
WireConnection;153;2;77;0
WireConnection;153;1;154;0
WireConnection;183;0;182;0
WireConnection;146;0;144;2
WireConnection;146;1;147;0
WireConnection;67;0;85;0
WireConnection;85;0;36;0
WireConnection;85;1;86;0
WireConnection;25;0;9;0
WireConnection;300;0;218;0
WireConnection;300;1;30;0
WireConnection;36;0;37;0
WireConnection;175;0;145;0
WireConnection;165;0;166;0
WireConnection;199;0;197;0
WireConnection;319;0;316;0
WireConnection;260;1;263;0
WireConnection;260;2;221;0
WireConnection;186;0;184;0
WireConnection;186;1;185;0
WireConnection;100;0;99;0
WireConnection;168;1;179;0
WireConnection;168;0;177;0
WireConnection;187;0;186;0
WireConnection;37;0;81;0
WireConnection;142;1;153;0
WireConnection;184;0;183;0
WireConnection;86;0;88;0
WireConnection;88;0;87;0
WireConnection;70;0;25;0
WireConnection;152;0;120;0
WireConnection;145;0;144;1
WireConnection;145;1;146;0
WireConnection;145;2;144;3
WireConnection;178;1;180;0
WireConnection;178;0;155;0
WireConnection;69;0;70;0
WireConnection;251;0;217;0
WireConnection;81;0;76;0
WireConnection;81;1;82;0
WireConnection;0;2;282;0
WireConnection;0;13;260;0
ASEEND*/
//CHKSM=6F5A9BAFA3C6F3CECA779D855B8AC7767D0C5F86