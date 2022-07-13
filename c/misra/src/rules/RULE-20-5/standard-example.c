#define QUALIFIER volatile
#undef QUALIFIER /* Non-compliant */
void f(QUALIFIER int32_t p) {
  while (p != 0) {
    ; /* Wait... */
  }
}