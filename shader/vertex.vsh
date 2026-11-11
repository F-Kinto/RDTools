attribute highp vec3 qt_Vertex;
attribute highp vec2 texCoord;

uniform mat4 u_modelMatrix;
uniform mat4 u_viewMatrix;
uniform mat4 u_projectMatrix;
//uniform float m_offsetX;
//uniform float m_scale;
//uniform float m_offsetY;

varying vec2 v_texCoord;
void main(void)
{
    gl_Position = u_projectMatrix * u_viewMatrix * u_modelMatrix * vec4(qt_Vertex/*qt_Vertex.x* m_scale+ m_offsetX, qt_Vertex.y*m_scale + m_offsetY, qt_Vertex.z*/,1.0f);
    v_texCoord = texCoord;
}

