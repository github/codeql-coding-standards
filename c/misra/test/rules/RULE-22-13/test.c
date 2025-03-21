#include "stdlib.h"
#include "threads.h"

mtx_t g1;  // COMPLIANT
thrd_t g2; // COMPLIANT
tss_t g3;  // COMPLIANT
cnd_t g4;  // COMPLIANT

static mtx_t g5;  // COMPLIANT
static thrd_t g6; // COMPLIANT
static tss_t g7;  // COMPLIANT
static cnd_t g8;  // COMPLIANT

_Thread_local mtx_t g9;   // NON-COMPLIANT
_Thread_local thrd_t g10; // NON-COMPLIANT
_Thread_local tss_t g11;  // NON-COMPLIANT
_Thread_local cnd_t g12;  // NON-COMPLIANT

typedef struct {
  mtx_t m;
} has_mtx_t;

typedef struct {
  mtx_t *m;
} has_ptr_mtx_t;

mtx_t g13[10];     // COMPLIANT
mtx_t *g14;        // COMPLIANT
has_mtx_t g15;     // COMPLIANT
has_ptr_mtx_t g16; // COMPLIANT
has_mtx_t g17[10]; // COMPLIANT

void f1(void) {
  mtx_t l1;  // NON-COMPLIANT
  thrd_t l2; // NON-COMPLIANT
  tss_t l3;  // NON-COMPLIANT
  cnd_t l4;  // NON-COMPLIANT

  static mtx_t l5;  // COMPLIANT
  static thrd_t l6; // COMPLIANT
  static tss_t l7;  // COMPLIANT
  static cnd_t l8;  // COMPLIANT

  mtx_t l9[10];      // NON-COMPLIANT
  mtx_t *l10;        // COMPLIANT
  has_mtx_t l11;     // NON-COMPLIANT
  has_ptr_mtx_t l12; // COMPLIANT
  has_mtx_t l13[10]; // NON-COMPLIANT

  l10 = &g1;                       // COMPLIANT
  l10 = malloc(sizeof(mtx_t));     // NON-COMPLIANT
  l10 = malloc(sizeof(mtx_t) * 4); // NON-COMPLIANT
}