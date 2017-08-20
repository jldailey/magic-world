
#define SWAP(a,b) (tmp = a; a = b; b = tmp)
#define MIXIN(name, ...) Mixin.name = (__VA_ARGS__) -> class name
#define CLAMP(x,m,n) (Math.min n, Math.max m, x)
#define SET_ADD(a,x) (if (a.indexOf x) is -1 then a.push x)
#define SET_REMOVE(a,x) (if ~(i = a.indexOf x) then a.splice i, 1)
#define SET_ADDER(a) (x) -> (if (a.indexOf x) is -1 then a.push x)
#define SET_REMOVER(a) (x) -> (if ~(i = a.indexOf x) then a.splice i, 1)
#define FLAT_MAP(a,f,...) (__VA_ARGS__) -> $(r for r in s.f(__VA_ARGS__) for s in a).flatten()
#define PROP(n, o, i, min, max) ($.defineProperty(@::,n,{get:(->o[i]),set:(v)->o[i]=CLAMP(v,min,max);}))
#define VEC_ADD(a, b) (new Float64Array [a[0]+b[0],a[1]+b[1],a[2]+b[2],a[3]+b[3]])
#define VEC_ADDF(a, f) (new Float64Array [a[0]+f,a[1]+f,a[2]+f,a[3]+f])
#define VEC_SUB(a, b) (new Float64Array [a[0]-b[0],a[1]-b[1],a[2]-b[2],a[3]-b[3]])
#define VEC_DOT(a, b) ( (a[0]*b[0]) + (a[1]*b[1]) + (a[2]*b[2]) + (a[3]*b[3]) )
#define VEC_SCALE(a, f) (a[0]*=f;a[1]*=f;a[2]*=f;a[3]*=f)

