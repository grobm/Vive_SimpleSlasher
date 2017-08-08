Shader "EvanMcCall/GhostShader" {
Properties {		
		_MainTex ("Diffuse(RGB) Spec(A)", 2D) = "white" {}
		_RimColor("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower("Rim Power", Range(0.5,8.0)) = 3.0
		_SpecColor("Specular Color", Color) = (0.5,0.5,0.5,1)
		_Shininess("Shininess", Range(0.01,1)) = 0.078125
	}
SubShader{
	Tags {"RenderType" = "Transparent" "Queue" = "Transparent" }

	// note that a vertex shader is specified here but its using the one above

	CGPROGRAM

	#pragma surface surf SimpleSpecular alpha //Run the surface - surf - SimpleSpecular and alpha functions
	float _Shininess;
			
	half4 LightingSimpleSpecular(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
		half3 h = normalize(lightDir + viewDir);	  //Normalizes the length of the vector to below 1 but retains the direction of the Vector
		half3 diff = max(0, dot(s.Normal, lightDir)); //Diff = the max between (0 and the product of the Euclidean magnitudes 
														//of the direction of the normal for the output texture (Z) and the cosine of the angle between them) 
														//Return 0 if larger then dot product
		float nh = max(0, dot(s.Normal, h));		  //nh = the max between 0 and the dot of SurfaceOutput normal and height
		float spec = pow(nh, 48.0);					  //returns nh to the power of 48
		half4 c;									  //RGBA Color
		c.rgb = (s.Albedo * _LightColor0.rgb * spec * s.Alpha * _Shininess * _SpecColor) * (atten * 2); //Speular color is calculated by taking the whiteness of the SurfaceOutput * colour of the current light for whichever pass you're doing * spec amount
		c.a = s.Alpha;								  //The alpha remains the current Alpha
		return c;
	}

	struct Input {
		float2 uv_MainTex;
		float3 viewDir;
	};

	sampler2D _MainTex;
	float4 _RimColor;
	float4 _RimPower;

	void surf(Input IN, inout SurfaceOutput o) {
		fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
		o.Albedo = c.rgb;
		half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
		o.Emission = _RimColor.rgb * pow(rim,_RimPower);
		o.Alpha = c.a + rim;
	}
	ENDCG
	UsePass "Outlined/Diffuse/OUTLINE"
	}
	FallBack "Diffuse"
}
