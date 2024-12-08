#ifndef _OCEAN_LIGHTING
#define _OCEAN_LIGHTING



void CalculateColorCustom_float(
     float3 fragmentPosition
    ,float3 normaldir
    ,float3 diffuseColor
    ,float3 ambientColor
    ,float3 specularColor
    ,float shininess
    ,float3 lightDirection
    ,float3 cameraPosition
    ,float lightIntensity
    ,float ambientStrength
    ,float refractiveIndex
    ,float highlightOffset
    ,float3 highlightColor
    ,out float4 FragmentColor)
{
   
    float3 viewDirection = normalize(cameraPosition - fragmentPosition);

    // ambient
    float3 ambient = ambientColor * diffuseColor;
  	
    // diffuse 
    float3 normal = normalize(normaldir);
    float3 lightDir = normalize(-lightDirection);
    float diff = max(dot(normal, lightDir), 0.0);
    float3 diffuse = diff * diffuseColor;

    //highlight
  
    float highlightMask = max((fragmentPosition.y - highlightOffset), 0.0);
    float distanceToPlayer = length(cameraPosition - fragmentPosition);
    float fadeFactor = max(1.0 - (distanceToPlayer / 200.0), 0);
    float3 highlight = highlightColor * highlightMask * fadeFactor;
    

    // Fresnel
    float fresnel = pow(1.0 - max(dot(viewDirection, normal), 0.15), 5.0);
    
    // specular
    float3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDirection, reflectDir), 0.0), shininess);
    float3 specular = spec * specularColor * fresnel;
    
    /*
    
    // refraction
    float ratio = 1.00 / refractiveIndex;
    vec3 I = normalize(FragPos - cameraPos);
    vec3 R = refract(I, normalize(Normal), ratio);
    vec3 refraction = (1.0 - fresnel) * texture(skybox, R).rgb;
    
    */
    float4 result = float4(ambient * ambientStrength +( diffuse + specular)*lightIntensity, 1);

  
    
    
    
    FragmentColor =  result;
}


#endif