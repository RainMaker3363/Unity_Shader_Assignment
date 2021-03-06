﻿Shader "Custom/EnviromentShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_BumpMap("Bumpmap", 2D) = "bump" {}
		_BumpScale("BumpSacle", Range(0,1)) = 0.05
		_Cube("Cubemap", CUBE) = "" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;
		samplerCUBE  _Cube;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir;
			float3 worldRefl;
			float3 worldNormal;
			INTERNAL_DATA
		};

		float fTime0_X;
		float flowspeed;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _BumpScale;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color * 0.5;
			//o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * 0.5;

			// 노말맵 계산을 해준다.
			//o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			//fTime0_X = lerp(1, 10, abs(unity_DeltaTime.w / 1.5f));
			
			float3 N = o.Normal;
			float3 I = normalize(IN.viewDir);
			float3 R = (2.0 * ((dot(I, N) * N) - I));

			float2 uv = float2(IN.uv_BumpMap.x, IN.uv_BumpMap.y + ((_Time.y) * 0.25));
			//o.Normal = UnpackNormal(tex2D(_BumpMap, uv));
			o.Normal = tex2D(_BumpMap, uv);


			//o.Normal.y *= -1;
			//o.Normal *= _BumpScale + R;
			//IN.worldNormal = o.Normal;
			
			// 큐브맵을 덮어준다.
			o.Emission = texCUBE(_Cube, IN.worldRefl * o.Normal * _BumpScale + R).rgb;
			//o.Emission = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal * _BumpScale + R)).rgb;
			//o.Emission = texCUBE(_Cube, IN.worldNormal).rgb;

			// Metallic and smoothness come from slider variables

			//o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
