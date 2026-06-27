/* pc_port_types.h - Type abstractions for the PC port.
 *
 * On 64-bit builds, pointer-sized types must be used where the original
 * N64 code stored pointers in u32 fields.  This header provides:
 *
 *   ptr_int_t  — integer large enough to hold a pointer (uintptr_t or u32)
 *   ptr_diff_t — signed difference of two pointers (ptrdiff_t or s32)
 *
 * Usage: replace `(u32)ptr` with `(ptr_int_t)ptr` and `u32 mPtr` with
 * `ptr_int_t mPtr` in JSystem heap/archive/ARAM code.
 */
#ifndef PC_PORT_TYPES_H
#define PC_PORT_TYPES_H

#include "types.h"

#ifdef TARGET_PC
#ifdef __LP64__
#include <stdint.h>
/* 64-bit: use full pointer-width integers */
typedef uintptr_t  ptr_int_t;
typedef intptr_t   ptr_sint_t;
typedef ptrdiff_t  ptr_diff_t;
#else
/* 32-bit: keep original u32/s32 for compatibility */
typedef u32  ptr_int_t;
typedef s32  ptr_sint_t;
typedef s32  ptr_diff_t;
#endif
#else
/* GameCube: original types */
typedef u32  ptr_int_t;
typedef s32  ptr_sint_t;
typedef s32  ptr_diff_t;
#endif

/* Cast a pointer to ptr_int_t (replaces (u32)ptr) */
#define PTR_TO_INT(p)  ((ptr_int_t)(uintptr_t)(p))

/* Cast ptr_int_t back to a typed pointer */
#define INT_TO_PTR(t, i)  ((t)(uintptr_t)(i))

#endif /* PC_PORT_TYPES_H */