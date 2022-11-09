// COMPLIANT
void test_assembly_is_documented() {
  // This comment serves as documentation
  __asm__("ret\n");
}

// NON_COMPLIANT
void test_assembly_is_not_documented() { __asm__("ret\n"); }

// COMPLIANT
#define RETURN __asm__("ret\n")
void test_undocumented_assembly_from_macro() { RETURN; }