//
//  Shader.metal
//  Noise
//
//  Created by William Vabrinskas on 6/22/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Light {
    packed_float3 color;
    float ambientIntensity;
    packed_float3 direction;
    float diffuseIntensity;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
    Light light;
};

struct VertexIn {
    packed_float3 position;
    packed_float4 color;
    packed_float3 normal;
};

struct VertexOut {
    float4 position [[position]];  //1
    float4 color;
    float3 normal;
};

vertex VertexOut basic_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],const device Uniforms& uniforms [[ buffer(1) ]], unsigned int vid [[ vertex_id ]]) {
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    VertexIn VertexIn = vertex_array[vid];
    
    VertexOut VertexOut;
    VertexOut.position = proj_Matrix * mv_Matrix * float4(VertexIn.position,1);
    VertexOut.color = VertexIn.color;
    VertexOut.normal = (mv_Matrix * float4(VertexIn.normal, 0.0)).xyz;
    
    return VertexOut;
}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]], const device Uniforms& uniforms [[ buffer(1) ]]) {
    Light light = uniforms.light;
    float4 ambientColor = float4(light.color * light.ambientIntensity, 1);
    float diffuseFactor = max(0.0,dot(interpolated.normal, light.direction)); // 1
    float4 diffuseColor = float4(light.color * light.diffuseIntensity * diffuseFactor ,1.0); // 2
    
    return interpolated.color * (ambientColor + diffuseColor);
}
