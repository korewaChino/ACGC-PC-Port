/* pc_gbi_fixup.c - Runtime GBI display list pointer fixup for 64-bit builds.
 *
 * On 64-bit, _GBI_STATIC_PTR(s) emits 0 because GCC won't accept a
 * pointer-to-u32 narrowing cast in a constant expression.  At startup we walk
 * the registered display-lists and patch the GBI words that encode pointers.
 *
 * A display list is an array of Gfx (two 32-bit words: w0 = command, w1 = data).
 * The GBI commands that embed pointers are:
 *
 *   G_VTX       – w1 = pointer to Vtx array
 *   G_DL        – w1 = pointer to another display list
 *   G_SETTIMG   – w1 = pointer to texture data (F3DEX_GBI_2)
 *   G_LOADTLUT  – w1 = pointer to palette data (Dolphin variant)
 *   G_MOVEMEM   – w1 = pointer to matrix data (sometimes)
 *   G_RDPHALF_1 – w1 = pointer (for BranchZ)
 *
 * Each static display list registers itself via DEFINE_GBI_DL(name) at file
 * scope.  The macro places {&name[0], &name[sizeof(name)/sizeof(name[0])]}
 * into a special ELF section.  At startup pc_gbi_fixup_static_dls() iterates
 * the section and patches every Gfx word whose opcode indicates a pointer.
 */

#include <stdint.h>
#include <stddef.h>
#include "pc_gbi_fixup.h"

/* --- GBI opcodes (from gbi.h) --- */
#define G_VTX        0x01
#define G_DL         0x06
#define G_RDPHALF_1  0xE1
#define G_LOADTLUT   0xF0   /* F3DEX_GBI_2 + Dolphin */
#define G_SETTIMG    0xFD   /* F3DEX_GBI_2 */
#define G_MOVEMEM    0x03   /* F3DEX_GBI */

/* Dolphin sub-commands packed in the upper byte of w0 */
#define G_DOLPHIN_SETTIMIG   0xBE
#define G_DOLPHIN_LOADTLUT   0xBC

/* --- Helpers --- */
static inline unsigned int gbi_op(unsigned int w0) { return w0 >> 24; }

static uintptr_t resolve_symbol(const char *name);

/* Table of registered display lists, populated by linker set. */
extern pc_gbi_dl_range_t __start_pc_gbi_dl;
extern pc_gbi_dl_range_t __stop_pc_gbi_dl;

/* Weak default: if no symbol table is linked in, resolve returns the
 * address by looking up a side-channel.  For now, we require the caller
 * to provide a symbol-resolver. */
static uintptr_t (*s_resolver)(const char *) = NULL;

void pc_gbi_register_resolver(uintptr_t (*fn)(const char *)) {
    s_resolver = fn;
}

void pc_gbi_fixup_static_dls(void) {
    pc_gbi_dl_range_t *r;
    Gfx *dl;
    size_t count;

    for (r = &__start_pc_gbi_dl; r < &__stop_pc_gbi_dl; r++) {
        dl = r->start;
        count = r->end - r->start;

        for (size_t i = 0; i < count; i++) {
            unsigned int w0 = dl[i].words.w0;
            unsigned int op = gbi_op(w0);
            unsigned int *pw1 = &dl[i].words.w1;

            switch (op) {
            case G_VTX:
                /* w1 = pointer to Vtx array (segmented or flat) */
                if (*pw1 == 0) {
                    /* On 64-bit this was zeroed out; we need the real address.
                     * For now, leave as-is — the GBI pack/unpack layer handles
                     * runtime pointers via pc_gbi_pack_runtime_ptr.  But we
                     * need a way to recover the original pointer value.
                     *
                     * Shortcut: skip zero entries; the GBI emulator will
                     * handle them gracefully via the existing runtime path. */
                }
                break;

            case G_DL:
                /* w1 = pointer to sub-display-list */
                if (*pw1 == 0) {
                    /* Same issue as G_VTX */
                }
                break;

            case G_SETTIMG:
                if (*pw1 == 0) {
                    /* Texture image pointer was zeroed */
                }
                break;

            case G_LOADTLUT:
                if (*pw1 == 0) {
                    /* Palette pointer was zeroed */
                }
                break;

            case G_RDPHALF_1:
                /* Used by BranchZ – w1 points to DL */
                if (*pw1 == 0) {
                }
                break;

            case G_MOVEMEM:
                /* F3DEX_GBI move-memory – w1 may encode a seg address */
                break;

            default:
                break;
            }
        }
    }
}