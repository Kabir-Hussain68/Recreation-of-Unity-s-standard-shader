Shader "Custom/Lightmapping"
{
    Properties
    {
    }
    SubShader
    {
        Pass
        {
            Tags 
            {
                "LightMode" = "Meta"
            } 

            Cull Off

            CGPROGRAM

            #pragma vertex LightmappingVertexProgram
            #pragma fragment LightmappingFragmentProgram

			#pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
			#pragma shader_feature _EMISSION_MAP
			#pragma shader_feature _DETAIL_MASK
			#pragma shader_feature _DETAIL_ALBEDO_MAP

            #include "Lightmapping.cginc"
            
            ENDCG

        }
    }

}
