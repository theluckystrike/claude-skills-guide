---
layout: default
title: "Claude Code for Unity HLSL Shader (2026)"
description: "Claude Code for Unity HLSL Shader — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-unity-hlsl-shader-development-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for Unity Shaders

Writing custom shaders in Unity means navigating three different shader pipelines (Built-in, URP, HDRP), learning HLSL syntax that differs subtly from plain DirectX HLSL, and understanding Unity's rendering architecture: SRP Batcher compatibility, multi-pass vs single-pass rendering, and the ShaderLab wrapper language. A shader that compiles but breaks SRP batching tanks your frame rate on mobile.

Claude Code generates ShaderLab/HLSL code that targets your specific render pipeline, follows SRP Batcher requirements (CBUFFER declarations), and implements common effects: dissolve, outline, triplanar mapping, vertex displacement, screen-space effects. It handles the #pragma and #include directives that Unity's shader compiler demands.

## The Workflow

### Step 1: Setup

```bash
# Unity 6 LTS with URP or HDRP package
# Create project via Unity Hub or CLI
# Ensure Shader Graph and render pipeline packages installed

mkdir -p Assets/Shaders/{URP,HDRP,Shared,Editor}
mkdir -p Assets/Materials
```

### Step 2: Custom URP Lit Shader with Dissolve Effect

```hlsl
// Assets/Shaders/URP/DissolveEffect.shader
Shader "Custom/DissolveEffect"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _NoiseMap ("Dissolve Noise", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0
        _EdgeWidth ("Edge Width", Range(0, 0.2)) = 0.05
        _EdgeColor ("Edge Color", Color) = (1, 0.5, 0, 1)
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // SRP Batcher compatible: all material properties in CBUFFER
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                float4 _NoiseMap_ST;
                half _DissolveAmount;
                half _EdgeWidth;
                half4 _EdgeColor;
                half _Metallic;
                half _Smoothness;
            CBUFFER_END

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float fogFactor : TEXCOORD3;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs posInputs =
                    GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normInputs =
                    GetVertexNormalInputs(input.normalOS);

                output.positionCS = posInputs.positionCS;
                output.positionWS = posInputs.positionWS;
                output.normalWS = normInputs.normalWS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.fogFactor = ComputeFogFactor(posInputs.positionCS.z);

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Sample noise for dissolve pattern
                half noise = SAMPLE_TEXTURE2D(
                    _NoiseMap, sampler_NoiseMap, input.uv).r;

                // Discard dissolved pixels
                clip(noise - _DissolveAmount);

                // Edge glow near dissolve boundary
                half edgeFactor = 1.0 - saturate(
                    (noise - _DissolveAmount) / _EdgeWidth);

                // Sample base texture
                half4 baseColor = SAMPLE_TEXTURE2D(
                    _BaseMap, sampler_BaseMap, input.uv) * _BaseColor;

                // URP lighting
                InputData lightingInput = (InputData)0;
                lightingInput.positionWS = input.positionWS;
                lightingInput.normalWS = normalize(input.normalWS);
                lightingInput.viewDirectionWS =
                    GetWorldSpaceNormalizeViewDir(input.positionWS);
                lightingInput.fogCoord = input.fogFactor;

                SurfaceData surfData = (SurfaceData)0;
                surfData.albedo = baseColor.rgb;
                surfData.metallic = _Metallic;
                surfData.smoothness = _Smoothness;
                surfData.normalTS = half3(0, 0, 1);
                surfData.occlusion = 1.0;
                surfData.alpha = 1.0;

                half4 litColor = UniversalFragmentPBR(
                    lightingInput, surfData);

                // Apply edge emission
                litColor.rgb = lerp(litColor.rgb,
                    _EdgeColor.rgb * 3.0, edgeFactor);

                litColor.rgb = MixFog(litColor.rgb, input.fogFactor);

                return litColor;
            }
            ENDHLSL
        }

        // Shadow caster pass for proper shadow casting
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex ShadowVert
            #pragma fragment ShadowFrag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                float4 _NoiseMap_ST;
                half _DissolveAmount;
                half _EdgeWidth;
                half4 _EdgeColor;
                half _Metallic;
                half _Smoothness;
            CBUFFER_END

            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings ShadowVert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(
                    input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _NoiseMap);
                return output;
            }

            half4 ShadowFrag(Varyings input) : SV_Target
            {
                half noise = SAMPLE_TEXTURE2D(
                    _NoiseMap, sampler_NoiseMap, input.uv).r;
                clip(noise - _DissolveAmount);
                return 0;
            }
            ENDHLSL
        }
    }
}
```

### Step 3: Material Setup Script

```csharp
// Assets/Editor/SetupDissolveMaterial.cs
using UnityEngine;
using UnityEditor;

public class SetupDissolveMaterial : MonoBehaviour
{
    [MenuItem("Tools/Create Dissolve Material")]
    static void CreateMaterial()
    {
        Shader shader = Shader.Find("Custom/DissolveEffect");
        Debug.Assert(shader != null, "DissolveEffect shader not found");

        Material mat = new Material(shader);
        mat.SetColor("_BaseColor", Color.white);
        mat.SetFloat("_DissolveAmount", 0f);
        mat.SetFloat("_EdgeWidth", 0.05f);
        mat.SetColor("_EdgeColor", new Color(1f, 0.5f, 0f, 1f));
        mat.SetFloat("_Metallic", 0f);
        mat.SetFloat("_Smoothness", 0.5f);

        AssetDatabase.CreateAsset(mat, "Assets/Materials/DissolveMat.mat");
        Debug.Log("Dissolve material created");
    }
}
```

### Step 4: Test in Editor

```bash
# Open Unity project and verify shader compiles
# Window > Analysis > Frame Debugger to verify SRP Batcher compatibility
# Expected: shader shows "SRP Batcher: compatible" in inspector

# Animate dissolve amount for testing
# In C# script: material.SetFloat("_DissolveAmount", Mathf.PingPong(Time.time * 0.3f, 1f));
```

## CLAUDE.md for Unity Shaders

```markdown
# Unity Shader Development Rules

## Standards
- ShaderLab syntax (Unity 6 LTS)
- HLSL (not Cg — deprecated since 2019)
- URP or HDRP pipeline (never mix)

## File Formats
- .shader (ShaderLab + HLSL)
- .hlsl (shared include files)
- .shadergraph (visual shader editor)
- .compute (compute shaders)

## Libraries
- URP ShaderLibrary (Core.hlsl, Lighting.hlsl)
- HDRP ShaderLibrary (different includes)
- Unity built-in: UnityCG.cginc (legacy only)

## Testing
- Compile on all target platforms (check error log)
- Frame Debugger: verify SRP Batcher compatibility
- GPU profiler: verify batch count not increased
- Test on lowest target hardware (mobile: check half precision)

## Performance Rules
- All material properties in CBUFFER for SRP Batcher
- Use half precision where possible on mobile
- Minimize texture samples per fragment
- Shadow caster pass must clip dissolved pixels
```

## Common Pitfalls

- **SRP Batcher incompatibility:** If material properties are not declared in a CBUFFER_START/CBUFFER_END block, the SRP Batcher cannot batch the shader, causing draw call explosion. Claude Code always generates CBUFFER-compatible property declarations.
- **Missing shadow caster pass:** A dissolving object that does not have a shadow caster pass with the same clip() logic casts a full shadow even when partially dissolved. Claude Code generates matching shadow passes for every visual effect.
- **Wrong include paths:** URP uses `Packages/com.unity.render-pipelines.universal/ShaderLibrary/`, not the old `UnityCG.cginc`. Claude Code uses the correct include paths for your target pipeline.

## Related

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for Blender Python Scripting](/claude-code-blender-python-scripting-2026/)
- [Claude Code for Unity Game Development](/claude-skills-for-unity-game-development-workflow/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Godot GDScript Development (2026)](/claude-code-godot-gdscript-development-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
