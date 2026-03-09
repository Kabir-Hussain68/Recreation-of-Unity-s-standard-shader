#if !defined(MY_LIGHTMAPPING_INCLUDED)
#define MY_LIGHTMAPPING_INCLUDED

#include "UnityPBSLighting.cginc"
#include "UnityMetaPass.cginc"

float4 _Color;
sampler2D _MainTex, _DetailTex, _DetailMask;
float4 _MainTex_ST, _DetailTex_ST;

sampler2D _MetallicMap;
float _Metallic;
float _Smoothness;

sampler2D _EmissionMap;
float4 _Emission;

struct VertexData {
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
};

struct Interpolators {
	float4 pos : SV_POSITION;
	float4 uv : TEXCOORD0;
};

float GetMetallic(Interpolators i)
{
    #if defined(_METALLIC_MAP)
        return tex2D(_MetallicMap, i.uv.xy).r * _Metallic;
    #else
        return _Metallic;
    #endif
}

float GetSmoothness(Interpolators i)
{
    float smoothness = 1;
    #if defined(_SMOOTHNESS_ALBEDO)
        smoothness = tex2D(_MainTex, i.uv.xy).a;
    #elif defined(_SMOOTHNESS_METALLIC) && defined(_METALLIC_MAP)
        smoothness = tex2D(_MetallicMap, i.uv.xy).a;
    #endif
        return smoothness * _Smoothness;
}

float3 GetEmission(Interpolators i)
{
    #if defined(_EMISSION_MAP)
        return tex2D(_EmissionMap, i.uv.xy) * _Emission;
    #else   
        return _Emission;
    #endif
}

float GetDetailMask(Interpolators i)
{
    #if defined(_DETAIL_MASK)
        return tex2D(_DetailMask, i.uv.xy).a;
    #else
        return 1;
    #endif
}

float GetAlpha(Interpolators i)
{
    float alpha = _Color.a;
    #if !defined(_SMOOTHNESS_ALBEDO)
        alpha *= tex2D(_MainTex, i.uv.xy).a;
    #endif
    return alpha;
}

Interpolators LightmappingVertexProgram(VertexData v)
{
    Interpolators i;
    i.pos = UnityMetaVertexPosition(
        v.vertex, v.uv1, v.uv2, unity_LightmapST, unity_DynamicLightmapST
    );
    i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
    i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
    return i;
}

float4 LightmappingFragmentProgram(Interpolators i) : SV_TARGET
{
    UnityMetaInput surfaceData;
    surfaceData.Emission = GetEmission(i);

    float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
    float oneMinusReflectivity;
    surfaceData.Albedo = DiffuseAndSpecularFromMetallic(
        GetAlpha(i), GetMetallic(i),
        surfaceData.SpecularColor, oneMinusReflectivity
    );
    float roughness = SmoothnessToRoughness(GetSmoothness(i)) * 0.5;
    surfaceData.Albedo += surfaceData.SpecularColor * roughness;
    return UnityMetaFragment(surfaceData);
}

#endif