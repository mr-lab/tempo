














float4 YellowMoney(float2 uv, sampler2D Textureinput, float speed)
{
float4 txt1=tex2D(Textureinput,uv);
float lum = dot(txt1.rgb, float3 (0.2126, 0.2152, 0.4722));
float3 metal = float3(lum,lum,lum);
metal.r = lum * pow(1.46*lum, 4.0);
metal.g = lum * pow(1.46*lum, 4.0);
metal.b = lum * pow(0.86*lum, 4.0);
float2 tuv = uv;
uv *= 2.5;
float time = (_Time/4)*speed;
float a = time * 50;
float n = sin(a + 2.0 * uv.x) + sin(a - 2.0 * uv.x) + sin(a + 2.0 * uv.y) + sin(a + 5.0 * uv.y);
n = fmod(((5.0 + n) / 5.0), 1.0);
n += tex2D(Textureinput, tuv).r * 0.21 + tex2D(Textureinput, tuv).g * 0.4 + tex2D(Textureinput, tuv).b * 0.2;
n=fmod(n,1.0);
float tx = n * 6.0;
float r = clamp(tx - 2.0, 0.0, 1.0) + clamp(2.0 - tx, 0.0, 1.0);
float4 ComputedResult=float4(1.0, 1.0, 1.0,r);
ComputedResult.rgb=metal.rgb+(1-ComputedResult.a);
ComputedResult.rgb=ComputedResult.rgb/2+dot(ComputedResult.rgb, float3 (0.1126, 0.4552, 0.1722));
ComputedResult.rgb-=float3(0.0,0.1,0.45);
ComputedResult.rg+=0.025;
ComputedResult.a=txt1.a;
return ComputedResult; 
}









float2 UpdownPongPing(float2 uv, float offsetx, float offsety, float zoomx, float zoomy, float speed)
{
float time = sin(_Time * 100* speed)  * 0.1;
speed *= time * 25;
uv += float2(offsetx, offsety)*speed;
uv = uv * float2(zoomx, zoomy);
return uv;
}
 










float4 GlowLight(sampler2D TextureIN, float2 uv, float NumberofSamples, float size, float3 colorIn, float intensity, float2 pos,float fade)
{
int samples = NumberofSamples;
int samples2 = samples *0.5;
float4 ret = float4(0, 0, 0, 0);
float count = 0;
for (int iy = -samples2; iy < samples2; iy++)
{
for (int ix = -samples2; ix < samples2; ix++)
{
float2 uv2 = float2(ix, iy);
uv2 /= samples;
uv2 *= size*0.1;
uv2 += float2(-pos.x,pos.y);
uv2 = saturate(uv+uv2);
ret += tex2D(TextureIN, uv2);
count++;
}
}
ret = lerp(float4(0, 0, 0, 0), ret / count, intensity);
ret.rgb = colorIn;
float4 m = ret;
float4 b = tex2D(TextureIN, uv);
ret = lerp(ret, b, b.a);
ret = lerp(m,ret,fade);
return ret;
}





//killit with fire

float Fracin (float2 c, float seed)
{
return frac(43.*sin(c.x+7.*c.y)*seed);
}

float Floorout (float2 p, float seed)
{
float2 i = floor(p), w = p-i, j = float2 (1.,0.);
w = w*w*(3.-w-w);
return lerp(lerp(Fracin(i, seed), Fracin(i+j, seed), w.x), lerp(Fracin(i+j.yx, seed), Fracin(i+1., seed), w.x), w.y);
}

float Loopinout (float2 p, float seed)
{
float m = 0., f = 2.;
for ( int i=0; i<9; i++ ){ m += Floorout(f*p, seed)/f; f+=f; }
return m;
}

float4 FireIT(float4 txt, float2 uv, float value, float seed, float HDR)
{
float t = frac(value*0.9999);
float4 c = smoothstep(t / 1.2, t + .1, Loopinout(3.5*uv, seed));
c = txt*c;
c.r = lerp(c.r, c.r*120.0*(1 - c.a), value);
c.g = lerp(c.g, c.g*40.0*(1 - c.a), value);
c.b = lerp(c.b, c.b*5.0*(1 - c.a) , value);
c.rgb = lerp(saturate(c.rgb),c.rgb,HDR);
return c;
}





//uvzoom 
float2 ZoomUV(float2 uv, float zoom, float posx, float posy, float radius, float speed)
{
float2 center = float2(posx, posy);
uv -= center;
zoom -= radius * 0.1;
zoom += sin(_Time * speed * 20) * 0.1 * radius;
uv = uv * zoom;
uv += center;
return uv;
}



//Shake
float2 ShakeUV(float2 uv, float offsetx, float offsety, float zoomx, float zoomy, float speed)
{
float time = sin(_Time * speed * 5000 * zoomx);
float time2 = sin(_Time * speed * 5000 * zoomy);
uv += float2(offsetx * time, offsety * time2);
return uv;
}
 


//ZoomNoPong 
float2 SimplezoomUV(float2 uv, float zoom, float posx, float posy)
{
float2 center = float2(posx, posy);
uv -= center;
uv = uv * zoom;
uv += center;
return uv;
}
 








 //shine bright like a diamond

float4 Shine(float4 txt, float2 uv, float pos, float size, float smooth, float intensity, float speed)
{
pos = pos + 0.5+sin(_Time*20*speed)*0.5;
uv = uv - float2(pos, 0.5);
float a = atan2(uv.x, uv.y) + 1.4, r = Pi;
float d = cos(floor(0.5 + a / r) * r - a) * length(uv);
float dist = 1.0 - smoothstep(size, size + smooth, d);
txt.rgb += dist*intensity;
return txt;
}












float4 SilverAlphaChannel(float2 uv, sampler2D txt, float speed)
{
float4 txt1=tex2D(txt,uv);
float lum = dot(txt1.rgb, float3 (0.4126, 0.8152, 0.1722));
float3 metal = float3(lum,lum,lum);
metal.r = lum * pow(0.66*lum, 4.0);
metal.g = lum * pow(0.66*lum, 4.0);
float2 tuv = uv;
uv *= 2.5;
float time = (_Time/4)*speed;
float a = time * 50;
float n = sin(a + 2.0 * uv.x) + sin(a - 2.0 * uv.x) + sin(a + 2.0 * uv.y) + sin(a + 5.0 * uv.y);
n = fmod(((5.0 + n) / 5.0), 1.0);
n += tex2D(txt, tuv).r * 0.21 + tex2D(txt, tuv).g * 0.4 + tex2D(txt, tuv).b * 0.2;
n=fmod(n,1.0);
float tx = n * 6.0;
float r = clamp(tx - 2.0, 0.0, 1.0) + clamp(2.0 - tx, 0.0, 1.0);
float4 ComputedResult=float4(1.0, 1.0, 1.0,r);
ComputedResult.rgb=metal.rgb+(1-ComputedResult.a);
ComputedResult.rgb=0.05+ComputedResult.rgb*0.5+dot(ComputedResult.rgb, float3 (0.2126, 0.2152, 0.1722))*0.5;
ComputedResult.a=txt1.a;
return ComputedResult; 
}






float4 SciFiEnergy(float4 txt, float2 uv, float _Fade, float speed)
{
float _TimeX=_Time.y * speed;
float a = 1.1 + _TimeX * 2.25;
float b = 0.5 + _TimeX * 1.77;
float c = 8.4 + _TimeX * 1.58;
float d = 610 + _TimeX * 2.03;
float x1 = 2.0 * uv.x;
float n = sin(a + x1) + sin(b - x1) + sin(c + 2.0 * uv.y) + sin(d + 5.0 * uv.y);
n = XModNumber(((5.0 + n) / 5.0), 1.0);
float4 nx=txt;
n += nx.r * 0.2 + nx.g * 0.4 + nx.b * 0.2;
float4 ret=float4(RGBColorSpecTrum(n),txt.a);
return lerp(txt,ret,_Fade);
}


















//FireDislapce2D



inline float XModNumber(float x,float Modin)
{
return x - floor(x * (1.0 / Modin)) * Modin;
}





float3 RGBColorSpecTrum(float t)
{
t= XModNumber(t,1.0);
float tx = t * 8;
float r = clamp(tx - 4.0, 0.0, 1.0) + clamp(2.0 - tx, 0.0, 1.0);
float g = tx < 2.0 ? clamp(tx, 0.0, 1.0) : clamp(4.0 - tx, 0.0, 1.0);
float b = tx < 4.0 ? clamp(tx - 2.0, 0.0, 1.0) : clamp(6.0 - tx, 0.0, 1.0);
return float3(r, g, b);
}













float Pi=3.1415926535;

float2 MoveUVWithRotation(float2 uv, float4 rgba, float value, float value2)
{
float angle = value2 * Pi;
float dist = rgba.r;
 
float2 uv2 = uv+mul(float2(dist-0.5, dist-0.5), float2x2(cos(angle), -sin(angle), sin(angle), cos(angle)));
return lerp(uv, uv2, value);
}







float4 BlendMask(float4 Source, float4 Mask, float blend)
{
float4 o = Source; 
o.a = Mask.a + Source.a * (1 - Mask.a);
o.rgb = (Mask.rgb * overlay.a + Source.rgb * Source.a * (1 - Mask.a)) * (o.a+0.000000095);
o.a = saturate(o.a);
o = lerp(Source, o, blend);
return o;
}
float4 Color_BlendLutGrad(float4 rgba, float4 a, float4 b, float4 c, float4 d, float offset, float fade, float speed)
{
float gray = (rgba.r + rgba.g + rgba.b) / 3;
gray += offset+(speed*_Time*20);
float4 result = a + b * cos(6.28318 * (c * gray + d));
result.a = rgba.a;
result.rgb = lerp(rgba.rgb, result.rgb, fade);
return result;
}



float4 Moving2wayMotion(float2 uv,sampler2D source,float x, float y, float value, float motion, float motion2)
{
float t=_Time.y;
float2 mov =float2(x*t,y*t)*motion;
float2 mov2 =float2(x*t*2,y*t*2)*motion2;
float4 rgba=tex2D(source, uv + mov);
float4 rgba2=tex2D(source, uv + mov2);
float r=(rgba2.r+rgba2.g+rgba2.b)/3;
r*=rgba2.a;
uv+=mov2*0.25;
return tex2D(source,lerp(uv,uv+float2(rgba.r*x,rgba.g*y),value*r));
}



float4 GlowLightVariant(sampler2D source, float2 uv, float precision, float size, float4 color, float intensity, float posx, float posy,float fade)
{
int samples = precision;
int samples2 = samples *0.5;
float4 ret = float4(0, 0, 0, 0);
float count = 0;
for (int iy = -samples2; iy < samples2; iy++)
{
for (int ix = -samples2; ix < samples2; ix++)
{
float2 uv2 = float2(ix, iy);
uv2 /= samples;
uv2 *= size*0.1;
uv2 += float2(-posx,posy);
uv2 = saturate(uv+uv2);
ret += tex2D(source, uv2);
count++;
}
}
ret = lerp(float4(0, 0, 0, 0), ret / count, intensity);
ret.rgb = color.rgb;
float4 m = ret;
float4 b = tex2D(source, uv);
ret = lerp(ret, b, b.a);
ret = lerp(m,ret,fade);
return ret;
}








float4 Gloss2D(float4 txt, float2 uv, float pos, float size, float smooth, float intensity, float speed)
{
pos = pos + 0.5+sin(_Time*20*speed)*0.5;
uv = uv - float2(pos, 0.5);
float a = atan2(uv.x, uv.y) + 1.4, r = Pi;
float d = cos(floor(0.5 + a / r) * r - a) * length(uv);
float dist = 1.0 - smoothstep(size, size + smooth, d);
txt.rgb += dist*intensity;
return txt;
}








float4 FireDislapce2D ( )  // use as Frag or Feed Texture  
{
float4 NewTex_1 = tex2D(_NewTex_1, i.texcoord);
float4 _Moving2wayMotion_1 = Moving2wayMotion(i.texcoord,Moving2wayMotion_1,_Moving2wayMotion_ValueX_1,_Moving2wayMotion_ValueY_1,_Moving2wayMotion_Size_1,1,1);
float2 _Simple_Displacement_Rotative_1 = MoveUVWithRotation(i.texcoord,_Moving2wayMotion_1,_Simple_Displacement_Rotative_Value_1,_Simple_Displacement_Rotative_Rotation_1);
float4 _GlowLightVariant_1 = GlowLightVariant(_MainTex,_Simple_Displacement_Rotative_1,_GlowLightVariant_Precision_1,_GlowLightVariant_Size_1,_GlowLightVariant_Color_1,_GlowLightVariant_Intensity_1,_GlowLightVariant_PosX_1,_GlowLightVariant_PosY_1,_GlowLightVariant_NoSprite_1);
float4 _PremadeGradients_1 = Color_BlendLutGrad(_GlowLightVariant_1,float4(0.5,0.5,0.5,1),float4(0.5,0.5,0.5,1),float4(0.8,0.8,0.8,1),float4(0,0.33,0.67,1),_PremadeGradients_Offset_1,_PremadeGradients_Fade_1,_PremadeGradients_Speed_1);
i.texcoord = lerp(i.texcoord,_Simple_Displacement_Rotative_1,_LerpUV_Fade_1);
float4 SourceRGBA_1 = tex2D(_MainTex, i.texcoord);
float4 BlendMask_2 = BlendMask(_PremadeGradients_1, SourceRGBA_1, _BlendMask_Fade_2); 
float4 _Gloss2D_1 = Gloss2D(BlendMask_2,i.texcoord,_Gloss2D_Pos_1,_Gloss2D_Size_1,_Gloss2D_Smooth_1,_Gloss2D_Intensity_1,_Gloss2D_Speed_1);
float4 BlendMask_1 = BlendMask(NewTex_1, _Gloss2D_1, _BlendMask_Fade_1); 
float4 ComputedReturn = BlendMask_1;
ComputedReturn.rgb *= i.color.rgb;
ComputedReturn.a = ComputedReturn.a * _SpriteFade * i.color.a;
ComputedReturn.rgb *= ComputedReturn.a;
ComputedReturn.a = saturate(ComputedReturn.a);
return ComputedReturn;
}





// this example can be used to move uvs on a Vector can be converteted to 2d
Shader "MoveUVonDirection" {
	Properties {
	_Color ("Texture Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_Direction ("Texture move direction", Vector) = (1,1,-1,-1)
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _Color;
			half4 _Direction;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 tex = tex2D(_MainTex, i.texcoord + _Time.x * _Direction.xy);
				fixed4 tex2 = tex2D(_MainTex, i.texcoord + _Time.x * _Direction.zw);
				return 2.0f * i.color * _Color * tex * tex2;
			}
			ENDCG 
		}
	}	
}
}







