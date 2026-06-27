/* pc_linux_compat.h - Force-included on Linux for C++ compatibility.
 *
 * Provides MSVC-isms and suppresses Metrowerks/GCC ABI differences
 * that the decompiled JSystem code relies on.
 */

#ifndef TARGET_PC
#error "This header is for the PC port (TARGET_PC) only"
#endif

#ifdef __cplusplus
#ifndef PC_LINUX_COMPAT_H
#define PC_LINUX_COMPAT_H

/* _tolower/_toupper are MSVC extensions; tolower/toupper from <cctype>.
 * We do NOT include <cctype> here because this header is force-included
 * and C++ standard headers (especially <cctype> → <bits/c++config.h>)
 * are fragile across multilib targets. Source files include what they need.
 */
#ifndef _WIN32
#endif

#endif /* PC_LINUX_COMPAT_H */
#endif /* __cplusplus */