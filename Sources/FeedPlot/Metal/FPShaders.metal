#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct FPVertexIn {
    vector_float3 dataPoint;
    vector_float4 color;
};

struct FPVertexOut {
    vector_float4 position [[position]];
    vector_float4 color;
    float size[[point_size]];
};

struct FPVertexUniforms {
    float startX;
    float endX;
    float startY;
    float endY;
    float startZ;
    float endZ;
    float size;
};

vertex FPVertexOut FPVertexShader(const constant FPVertexIn *vertexArray [[ buffer(0) ]],
                              unsigned int vid [[vertex_id]],
                              constant FPVertexUniforms& uniforms [[ buffer(9) ]]) {

    FPVertexIn input = vertexArray[vid];
    FPVertexOut output;

    // Scale to a percentage of the X and Y axis ranges
    float scaledX = (input.dataPoint.x - uniforms.startX) / (uniforms.endX - uniforms.startX);
    float scaledY = (input.dataPoint.y - uniforms.startY) / (uniforms.endY - uniforms.startY);
    float scaledZ = (input.dataPoint.z - uniforms.startZ) / (uniforms.endZ - uniforms.startZ);

    // Move into Metal -1/1 coordinates
    // Scale slightly less than exact to ensure points at axis limits are visible
    output.position = vector_float4(scaledX * 1.975 - 1, scaledY * 1.975 - 1, scaledZ, 1);
    output.color = input.color;
    output.size = uniforms.size;
    return output;
}

fragment vector_float4 FPFragmentShader(FPVertexOut interpolated [[stage_in]]) {
    return interpolated.color;
}
