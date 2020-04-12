using System.Collections;
using System.Collections.Generic;
using UnityEngine;

    [ExecuteInEditMode]
public class Test : MonoBehaviour
{

    [SerializeField]
    private Color color;

    [SerializeField]
    [Range(0, 360)]
    private float h;
    [SerializeField]
    [Range(0, 1)]
    private float s;
    [SerializeField]
    [Range(0, 1)]
    private float v;
    [Header("Actual Data")]
    [SerializeField]
    private float value;
    [SerializeField]
    [Range(0, 1)]
    private float r;
    [SerializeField]
    [Range(0, 1)]
    private float g;
    [SerializeField]
    [Range(0, 1)]
    private float b;
    [Header("Clamp Test")]
    [SerializeField]
    [Range(0, 2)]
    private float infClamp;
    [SerializeField]
    [Range(0, 2)]
    private float supClamp;
    [SerializeField]
    [Range(0, 2)]
    private float result;
    [SerializeField]
    [Range(0, 2)]
    private float inputValue;


    private void Update()
    {
        // Clamp: x > 0 -> x + |x/2| - x/2
        // ex: 0.5 -> 0.5 + (0.25 - 0.25) = 0.5, -0.5 -> -0.5 + (0.25 - (-0.25)) = 0
        // Clamp: x > 1 -> (x - 1) + |(x - 1)/2| - (x - 1)/2 + 1
        // ex: 0.5 -> -0.5 + (0.25 - (-0.25)) + 1 = 1, 2 -> 1 + (0.5 - 0.5) + 1 = 2

        // Clamp: x > v -> (x - v) + |(x - v)/2| - (x - v)/2 + v


        // Clamp: x < 0 -> -(-x + |-x/2| - (-x/2))
        // ex: -0.5 -> -(0.5 + 0.25 - 0.25) = 0.5, 0.5 -> -(-0.5 + 0.25 - (-0.25)) = 0
        // Clamp: x < 1 -> -(-(x - 1) + |-(x - 1)/2| - (-(x - 1)/2) - 1)
        // ex: -0.5 -> -(1.5 + 0.75 - 0.75 - 1) = 0.5, 1.5 -> -(-0.5 + 0.25 - (-0.25) - 1) = 1

        // Clamp: x < v -> -(-(x - v) + |-(x - v)/2| - (-(x - v)/2) - v)


        float pi = Mathf.PI;
        float newH = 360 - (h / 360f);
        color.a = 1;

        result = InfClamp(SupClamp(inputValue, supClamp), infClamp);
/*
        color.r = v * InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 0f / 3)) + 0.5f), 1), 0) + (v * (1 - InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 0f / 3)) + 0.5f), 1), 0))) * (1 - s);
        color.g = v * InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 1f / 3)) + 0.5f), 1), 0) + (v * (1 - InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 1f / 3)) + 0.5f), 1), 0))) * (1 - s);
        color.b = v * InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 2f / 3)) + 0.5f), 1), 0) + (v * (1 - InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 2f / 3)) + 0.5f), 1), 0))) * (1 - s);
        */
        float cs1 = InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 0f / 3)) + 0.5f), 1), 0);
        float cs2 = InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 1f / 3)) + 0.5f), 1), 0);
        float cs3 = InfClamp(SupClamp((Mathf.Cos(pi * 2 * (newH + 2f / 3)) + 0.5f), 1), 0);

        color.r = v * (1 + s * (cs1 - 1));
        color.g = v * (1 + s * (cs2 - 1));
        color.b = v * (1 + s * (cs3 - 1));

        value = color.r;
        if (color.g > value)
        {
            value = color.g;
        }
        if (color.b > value)
        {
            value = color.b;
        }
         
        r = color.r;
        g = color.g;
        b = color.b;
        

    }

    private float InfClamp(float x, float v)
    {
        return (x - v) + Mathf.Abs((x - v) / 2) -(x - v) / 2 + v;
    }

    private float SupClamp(float x, float v)
    {
        return -(-(x - v) + Mathf.Abs(-(x - v) / 2) - (-(x - v) / 2) - v);
    }


}
