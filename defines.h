
#define SWAP(a,b) (tmp = a; a = b; b = tmp)
#define MIXIN(name) module.exports.name = class name then constructor: 
#define PROP(n,p) $.defineProperty @::, n, get: -> p
#define FROZEN Object.freeze
#define CLAMP(x,m,n) (Math.min n, Math.max m, x)
#define ARRAY_ADD(a,x) (if (a.indexOf x) is -1 then a.push x)
#define ARRAY_REMOVE(a,x) (if ~(i = a.indexOf x) then a.splice i, 1)
#define DEBUG(...) (console.log __FILE__+":"+__LINE__, __VA_ARGS__)
#define COPY_ON_WRITE(v) (if Object.isFrozen v then v = v.slice 0)
#define FLAT_MAP(a,f,...) (__VA_ARGS__) -> $(r for r in s.f(__VA_ARGS__) for s in a).flatten()
#define COW_PROP(n, o, i, min, max) $.defineProperty(@::,n,{get:(->o[i]),set:(v)->COPY_ON_WRITE(o);o[i]=CLAMP(v,min,max)})
#define COW_ARRAY(name, a, b) (@::[name]=Object.freeze $ a, b)
#define COW_ARRAY_ADD(a) (x)->COPY_ON_WRITE(a);ARRAY_ADD(a,x);@
#define COW_ARRAY_REMOVE(a) (x)->COPY_ON_WRITE(a);ARRAY_REMOVE(a,x);@

