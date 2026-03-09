// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SurfaceShader" 
{
    Properties
    {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "White " {}
    }

    SubShader
    {
        Pass 
        {
            CGPROGRAM
            
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            #include "UnityCG.cginc"

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            struct Interpolator
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                //float3 localPosition : TEXCOORD0;
            };

            struct VertexData
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolator VertexProgram(VertexData v)
            {
                Interpolator i;
                //i.localPosition = v.position.xyz;
                i.position = UnityObjectToClipPos(v.position);
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return i;
            }

            float4 FragmentProgram(Interpolator i) : SV_TARGET
            {
                return tex2D(_MainTex, i.uv) * _Tint;
            }

            ENDCG
        }
    }
}