struct s1 {
  int m;
};

class C1 {};

typedef s1 s1_t;
typedef const s1 s1_const_t;
typedef C1 C1_t;
typedef const C1 C1_const_t;

void f() {
  try {

  } catch (int i) {
    // COMPLIANT: Primitives will not be sliced when caught by value.
  } catch (long l) {
    // COMPLIANT: Primitives will not be sliced when caught by value.
  } catch (float f) {
    // COMPLIANT: Primitives will not be sliced when caught by value.
  } catch (char c) {
    // COMPLIANT: Primitives will not be sliced when caught by value.
  } catch (int *p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (s1 s) {
    // NON-COMPLIANT: User-defined types will be sliced when caught by value.
  } catch (const s1 s) {
    // NON-COMPLIANT: User-defined types will be sliced when caught by value.
  } catch (s1 *p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (s1 *const p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (s1 &r) {
    // COMPLIANT: References will not be sliced when caught by value.
  } catch (s1 &const r) {
    // COMPLIANT: Const eferences will not be sliced when caught by value.
  } catch (const C1 c) {
    // NON-COMPLIANT: User-defined types will be sliced when caught by value.
  } catch (C1 c) {
    // NON-COMPLIANT: User-defined types will be sliced when caught by value.
  } catch (C1 *p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (C1 *const p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (C1 &r) {
    // COMPLIANT: References will not be sliced when caught by value.
  } catch (C1 &const r) {
    // COMPLIANT: Const eferences will not be sliced when caught by value.
  } catch (s1_t s) {
    // NON-COMPLIANT: User-defined types will be sliced when caught by value.
  } catch (s1_const_t s) {
    // NON-COMPLIANT: User-defined types will be sliced when caught by value.
  } catch (C1_t c) {
    // NON-COMPLIANT: User-defined types will be sliced when caught by value.
  } catch (C1_const_t c) {
    // NON-COMPLIANT: User-defined types will be sliced when caught by value.
  } catch (s1_t *p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (s1_t *const p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (s1_t &r) {
    // COMPLIANT: References will not be sliced when caught by value.
  } catch (s1_t &const r) {
    // COMPLIANT: Const eferences will not be sliced when caught by value.
  } catch (C1_t *p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (C1_t *const p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (C1_t &r) {
    // COMPLIANT: References will not be sliced when caught by value.
  } catch (C1_t &const r) {
    // COMPLIANT: Const eferences will not be sliced when caught by value.
  } catch (s1_const_t *p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (s1_const_t *const p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (s1_const_t &r) {
    // COMPLIANT: References will not be sliced when caught by value.
  } catch (s1_const_t &const r) {
    // COMPLIANT: Const eferences will not be sliced when caught by value.
  } catch (C1_const_t *p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (C1_const_t *const p) {
    // COMPLIANT: Pointers will not be sliced when caught by value.
  } catch (C1_const_t &r) {
    // COMPLIANT: References will not be sliced when caught by value.
  } catch (C1_const_t &const r) {
    // COMPLIANT: Const eferences will not be sliced when caught by value.
  } catch (...) {
    // COMPLIANT: Catch-all handler.
  }
}