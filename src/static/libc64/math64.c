#include "libc64/math64.h"
#include "MSL_C/w_math.h"

/* math64.h #defines fsqrt→sqrtf under TARGET_PC for callers,
 * but math64.c itself must define the wrapper. */
#ifdef fsqrt
#undef fsqrt
#endif

f32 fatan2(f32 x, f32 y) {
    return atan2(x, y);
}

f32 fsqrt(f32 x) {
    return sqrtf(x);
}

f32 facos(f32 x) {
    return acos(x);
}
