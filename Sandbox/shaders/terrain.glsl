#shader vertex
#version 330 core

layout(location = 0) in vec3 aPosition;
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTexCoord;
layout(location = 3) in vec2 aStats;

uniform mat4 uViewProjection;
uniform mat4 uTransform;

out vec3 vPosition;
out vec3 vNormal;
out vec2 vTexCoord;
out vec3 vWorldPosition;
out vec2 vStats;

void main()
{
    vPosition = aPosition;
    vNormal = aNormal;
    vTexCoord = aTexCoord;
    gl_Position = uViewProjection * uTransform * vec4(aPosition, 1.0);
    vWorldPosition = vec3(uTransform * vec4(aPosition, 1.0));
	vStats = aStats;
}

#shader fragment
#version 330 core

layout(location = 0) out vec4 color;

in vec3 vPosition;
in vec3 vNormal;
in vec2 vTexCoord;
in vec3 vWorldPosition;
in vec2 vStats;

uniform sampler2D uTexture0;
uniform sampler2D uTexture1;
uniform sampler2D uTexture2;
uniform sampler2D uTexture3;
uniform vec4 uTextureCutoffs;

void main()
{
    float ambientStrength = 0.1f;
    vec3 ambient = ambientStrength * vec3(1.0f, 1.0f, 1.0f);

    vec3 n = normalize(vNormal);
    vec3 lightDir = normalize(vec3(0.0f, 0.0f, 5.0f) - vWorldPosition);
    float diff = max(dot(n, lightDir), 0.0);
    vec3 diffuse = diff * vec3(1.0f, 1.0f, 1.0f);

    vec4 texMix;
    float ratio;

    if (vPosition.z < uTextureCutoffs.g) {
        ratio = (vPosition.z - uTextureCutoffs.r) / (uTextureCutoffs.g - uTextureCutoffs.r);
        texMix = mix(texture( uTexture0, vTexCoord ), texture( uTexture1, vTexCoord ), ratio);
    } else if (vPosition.z < uTextureCutoffs.b) {
        ratio = (vPosition.z - uTextureCutoffs.g) / (uTextureCutoffs.b - uTextureCutoffs.g);
        texMix = mix(texture( uTexture1, vTexCoord ), texture( uTexture2, vTexCoord ), ratio);
    } else if (vPosition.z < uTextureCutoffs.a) {
        ratio = (vPosition.z - 0.15f) / (uTextureCutoffs.a - 0.15f);
        ratio = max(0.0f, ratio);
		texMix = mix(texture( uTexture2, vTexCoord ), vec4(0.65, 0.35, 0.0, 1.0), 0.5 - vStats.x/2);
        texMix = mix(texMix, texture( uTexture3, vTexCoord ), ratio);
	} else {
        texMix = texture( uTexture3, vTexCoord );
    }

    color = vec4(ambient + diffuse, 1.0f) * texMix;
}
