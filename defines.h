
#define MIXIN(name) module.exports.name = class name then constructor: 
#define PROP(n,p) $.defineProperty @::, n, get: -> p
#define FROZEN Object.freeze
#define CLAMP(x,m,n) (Math.min n, Math.max m, x)
#define ARRAY_ADD(a,x) (if (a.indexOf t) is -1 then a.push x)
#define ARRAY_REMOVE(a,x) (if ~(i = a.indexOf x) then a.splice i, 1)
#define DEBUG(...) console.log "__FILE__:__LINE__", __VA_ARGS__
