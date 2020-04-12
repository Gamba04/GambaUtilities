Shader "Gamba/ImageEffects"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}

    // HSV
        [Toggle] _Hue("Hue", Float) = 0
        _HueAmount("    Amount", Range(-1,1)) = 0
        [Space(10)]
        [Toggle] _Saturation("Saturation", Float) = 0
        _SatAmount("    Amount", Range(-1,1)) = 0
        [Space(10)]
        [Toggle] _Value("Value", Float) = 0
        _ValAmount("    Amount", Range(-1,1)) = 0
        [Space(10)]
        [Space(20)]

        [Toggle] _Contrast("Contrast", Float) = 0
        _ContrAmount("    Amount", Range(0,5)) = 0
        [Space(10)]
        [Toggle] _Luminosity("Luminosity", Float) = 0
        _LumAmount("    Amount", Range(-2,2)) = 0
        [Space(10)]
        [Toggle] _Pixelate("Pixelate", Float) = 0
        _Pixelation("    Pixelation", Range(1,200)) = 10
        [Space(10)]
        [Toggle] _Cell("Cell Shade", Float) = 0
        _CellPasses("    Passes", Range(1,200)) = 10
        [Space(10)]
        [Toggle] _Blur("Blur", Float) = 0
        _BlurAmount("    Amount", Range(0,100)) = 0
        [Toggle] _ShadowToning("Shadow Toning", Float) = 0
        _ShadowColor("    Color", Color) = (0,0,0,0)
        _ShadowAmount("    Amount", Range(0,1)) = 0
        _ShadowTresh("    Tresshold", Range(0,1)) = 0
        [Space(10)]
        [Toggle] _HighlightToning("Highlight Toning", Float) = 0
        _HighlightColor("    Color", Color) = (0,0,0,0)
        _HighlightAmount("    Amount", Range(0,1)) = 0
        _HighlightTresh("    Tresshold", Range(0,1)) = 0
        [Space(10)]
        [Toggle] _Border("Border", Float) = 0
        _BorderAmount("    Amount", Range(0,1)) = 0
        [Space(10)]
        [Toggle] _Noise("Strange Noise?", Float) = 0
        _NoiseAmount("    Amount", Range(0,1)) = 0
        
        

    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                // HSV
                bool _Hue;
                float _HueAmount;
                bool _Saturation;
                float _SatAmount;
                bool _Value;
                float _ValAmount;
                // Effects
                bool  _Contrast;
                float _ContrAmount;
                bool  _Luminosity;
                float _LumAmount;
                bool _Pixelate;
                uint _Pixelation;
                bool _Cell;
                int _CellPasses;
                bool _Blur;
                float _BlurAmount;
                bool _ShadowToning;
                float _ShadowAmount;
                float _ShadowTresh;
                fixed4 _ShadowColor;
                bool _HighlightToning;
                float _HighlightAmount;
                float _HighlightTresh;
                fixed4 _HighlightColor;
                bool _Border;
                float _BorderAmount;
                bool _Noise;
                float _NoiseAmount;
                
                float nextRand = 1243.123;
                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }
                float GetValue(fixed4 col)
                {
                    float v = 0;

                    v = col.r;
                    if (col.g > v)
                    {
                        v = col.g;
                    }
                    if (col.b > v)
                    {
                        v = col.b;
                    }
                    return v;
                }

                float GetSaturation(fixed4 col, float v)
                {
                    float s = 0;

                    if (!(col.r == col.g && col.g == col.b))
                    {
                        float maxDifference = 0;
                        if (v - col.r > maxDifference)
                        {
                            maxDifference = v - col.r;
                        }
                        if (v - col.g > maxDifference)
                        {
                            maxDifference = v - col.g;
                        }
                        if (v - col.b > maxDifference)
                        {
                            maxDifference = v - col.b;
                        }

                        s = maxDifference / v;
                    }
                    return s;
                }

                float GetHue(fixed4 col)
                {
                    float h = 0;

                    if (!(col.r == col.g && col.g == col.b))
                    {
                        if (col.r >= col.g && col.g >= col.b)
                        {
                            h = (1.0 / 6) * (col.g - col.b) / (col.r - col.b);
                        }
                        if (col.g >= col.r && col.r >= col.b)
                        {
                            h = (1.0 / 6) * (2 - (col.r - col.b) / (col.g - col.b));
                        }
                        if (col.g >= col.b && col.b >= col.r)
                        {
                            h = (1.0 / 6) * (2 + (col.b - col.r) / (col.g - col.r));
                        }
                        if (col.b >= col.g && col.g >= col.r)
                        {
                            h = (1.0 / 6) * (4 - (col.g - col.r) / (col.b - col.r));
                        }
                        if (col.b >= col.r && col.r >= col.g)
                        {
                            h = (1.0 / 6) * (4 + (col.r - col.g) / (col.b - col.g));
                        }
                        if (col.r >= col.b && col.b >= col.g)
                        {
                            h = (1.0 / 6) * (6 - (col.b - col.g) / (col.r - col.g));
                        }

                        h = 1 - h;
                    }

                    return h;
                }

                fixed4 ClampCol(fixed4 col)
                {
                    if (col.r > 1) col.r = 1;
                    if (col.r < 0) col.r = 0;

                    if (col.g > 1) col.g = 1;
                    if (col.g < 0) col.g = 0;

                    if (col.b > 1) col.b = 1;
                    if (col.b < 0) col.b = 0;

                    return col;
                }

                float Magnitude3(fixed4 col) 
                {
                    return sqrt(col.r * col.r + col.g * col.g + col.b * col.b);
                }

                float Magnitude2(float2 f2) 
                {
                    return sqrt(f2.x * f2.x + f2.y * f2.y);
                }

                float Random(float a, float b, float num) 
                {
                    float keyboardSmash = 1234.4902340923480932;

                    nextRand = sin(_Time) * num *keyboardSmash;
                    return sin(nextRand) * (b - a) + a;
                }


                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv);
                    fixed4 previousCol = col;

                    //Image Post Process Effects -------------------------------------------------------------------------------------------------------------------------------------------

                    if (_Pixelate) //-----------Pixelate
                    {
                        uint pixelation = _Pixelation;
                        uint Upasses = 1920 / pixelation;
                        uint Vpasses = 1080 / pixelation;
                        float u = i.uv.x * Upasses;
                        float v = i.uv.y * Vpasses;
                        float2 newUV = float2(floor(u) / Upasses, floor(v) / Vpasses);
                        col = tex2D(_MainTex, newUV);
                    }

                    if (_Blur)
                    {
                        if (_BlurAmount != 0)
                        {
                            fixed4 av = fixed4(0, 0, 0, 0);
                            float count = 0;
                            for (int x = 0; x < _BlurAmount; x++)
                            {
                                for (int y = 0; y < _BlurAmount; y++)
                                {
                                    float2 dif = float2(x, y) - float2(0.5, 0.5) * _BlurAmount;
                                    if (dif.x * dif.x + dif.y * dif.y < _BlurAmount * _BlurAmount)
                                    {
                                        count++;
                                        av += tex2D(_MainTex, i.uv + float2((x - 0.5 * _BlurAmount) / 1920.0, (y - 0.5 * _BlurAmount) / 1080.0));
                                    }
                                }
                            }

                            col = fixed4(av.r, av.g, av.b, 1) / count;
                        }
                    }

                    float v = GetValue(col);

                    float s = GetSaturation(col, v);

                    float h = GetHue(col);

                    if (_Contrast) 
                    {
                        _ContrAmount = 1 - _ContrAmount;
                        col += (fixed4(0.5, 0.5, 0.5, 1) - col) * _ContrAmount;
                    }

                    if (_Luminosity) //-----------Luminosity
                    {
                        col.r += _LumAmount;
                        col.g += _LumAmount;
                        col.b += _LumAmount;
                    }

                    if (_ShadowToning) 
                    {
                        if (v < _ShadowTresh) 
                        {
                            col += (_ShadowColor - col) * _ShadowAmount * (_ShadowTresh - v);
                        }
                    }

                    if (_HighlightToning) 
                    {
                        if (v > _HighlightTresh)
                        {
                            col += (_HighlightColor - col) * _HighlightAmount * (v - _HighlightTresh);
                        }
                    }

                    if (_Border)
                    {
                        _BorderAmount = 1 - _BorderAmount;
                        if (Magnitude3(tex2D(_MainTex, i.uv + float2(1.0 / 1920, 0)) - col) > _BorderAmount) 
                        { 
                            col = fixed4(0, 0, 0, 1);
                        }
                    }

                    if (_Noise)
                    {
                        fixed4 fx = tex2D(_MainTex, i.uv + float2( Random(-1, 1, col.r), Random(-1, 1, col.g)) + float2(0.2,0.2));
                        col += (fx - col) * _NoiseAmount;
                    }


                    // Color Modification -------------------------------------------------------------------------------------------------------------------------------------------

                    //Get color data
                    const float pi = 3.1415926538;
                    
                    col = ClampCol(col);

                    v = GetValue(col);

                    s = GetSaturation(col, v);

                    h = GetHue(col);

                    // Edit color data -------------------------------------------------------------------------------------------------------------------------------------------
                    
                if (_Hue) //-----------Hue
                {
                    h += _HueAmount;
                }
                if (_Saturation) //-----------Saturation
                {
                    s += _SatAmount;
                    if (s < 0) s = 0;
                    if (s > 1) s = 1;
                }
                if (_Value) //-----------Value
                {
                    v += _ValAmount;
                    if (v < 0) v = 0;
                    if (v > 1) v = 1;
                }
                // HSV modification effects
                if (_Cell)
                {
                    v = round(v * _CellPasses) / _CellPasses;
                }
                // Build final color -------------------------------------------------------------------------------------------------------------------------------------------

                if (_Hue || _Saturation || _Value || _Cell) 
                {
                    float rcs = cos(pi * 2 * (h + 0.0 / 3)) + 0.5;
                    rcs = (rcs + abs(rcs)) / 2;
                    rcs = -(-(rcs - 1) + abs(-(rcs - 1) / 2) - (-(rcs - 1) / 2) - 1);

                    float gcs = cos(pi * 2 * (h + 1.0 / 3)) + 0.5;
                    gcs = (gcs + abs(gcs)) / 2;
                    gcs = -(-(gcs - 1) + abs(-(gcs - 1) / 2) - (-(gcs - 1) / 2) - 1);

                    float bcs = cos(pi * 2 * (h + 2.0 / 3)) + 0.5;
                    bcs = (bcs + abs(bcs)) / 2;
                    bcs = -(-(bcs - 1) + abs(-(bcs - 1) / 2) - (-(bcs - 1) / 2) - 1);

                    col.r = v * (1 + s * (rcs - 1));
                    col.g = v * (1 + s * (gcs - 1));
                    col.b = v * (1 + s * (bcs - 1));
                }

               /* if (_Cell)
                {
                    float smoothAmount = 10;
                    fixed4 av = fixed4(0, 0, 0, 0);
                    float count = 0;
                    for (int x = 0; x < smoothAmount; x++)
                    {
                        for (int y = 0; y < smoothAmount; y++)
                        {
                            float2 dif = float2(x, y) - float2(0.5, 0.5) * smoothAmount;
                            if (dif.x * dif.x + dif.y * dif.y < smoothAmount * smoothAmount)
                            {
                                count++;
                                av += tex2D(_MainTex, i.uv + float2((x - 0.5 * smoothAmount) / 1920.0, (y - 0.5 * smoothAmount) / 1080.0));
                            }
                        }
                    }

                    col = fixed4(av.r, av.g, av.b, 1) / count;

                }*/
                return col;
                }

                

                


                ENDCG
            }
        }
}
