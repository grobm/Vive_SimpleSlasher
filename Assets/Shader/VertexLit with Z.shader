// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Transparent/VertexLit with Z" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_SpecColor("Spec Color", Color) = (1,1,1,0)
		_Emission("Emissive Color", Color) = (0,0,0,0)
		_Shininess("Shininess", Range(0.1, 1)) = 0.7
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
	}

		CGINCLUDE
#include "UnityCG.cginc"

	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f {
		float4 pos : POSITION;
		float4 color : COLOR;
	};

	uniform float _Outline;
	uniform float4 _OutlineColor;

	v2f vert(appdata v) {
		// just make a copy of incoming vertex data but scaled according to normal direction
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
		float2 offset = TransformViewToProjection(norm.xy);

		o.pos.xy += offset * o.pos.z * _Outline;
		o.color = _OutlineColor;
		return o;
	}
	ENDCG



		SubShader{


		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		// Render into depth buffer only
		Pass{
		ColorMask 0
	}
		// Render normally
		Pass{
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Material{
		Diffuse[_Color]
		Ambient[_Color]
		Shininess[_Shininess]
		Specular[_SpecColor]
		Emission[_Emission]
	}
		Lighting On
		SetTexture[_MainTex]{
		Combine texture * primary DOUBLE, texture * primary
	}
	}
	}
}