#include <cstddef>
#include <cstdlib>
#include <memory>
#include <new>

/**
 * Fixture class with class-specific operator new/delete declarations and
 * definitions.
 */
class C1 {
public:
  // Class-specific operator declarations - NON_COMPLIANT (any signature)
  void *
  operator new(std::size_t size); // NON_COMPLIANT: class-specific declaration
  void *
  operator new[](std::size_t size); // NON_COMPLIANT: class-specific declaration
  void operator delete(
      void *ptr) noexcept; // NON_COMPLIANT: class-specific declaration
  void operator delete[](
      void *ptr) noexcept; // NON_COMPLIANT: class-specific declaration
  void *operator new(
      std::size_t size,
      const std::nothrow_t
          &) noexcept; // NON_COMPLIANT: class-specific nothrow declaration
  void *operator new(std::size_t size,
                     void *ptr) noexcept; // NON_COMPLIANT: class-specific
                                          // placement declaration
  void *operator new[](std::size_t size,
                       void *ptr) noexcept; // NON_COMPLIANT: class-specific
                                            // placement declaration
  void *
  operator new(std::size_t size,
               int hint); // NON_COMPLIANT: class-specific custom declaration
  void *
  operator new(std::size_t size, double alignment,
               int pool); // NON_COMPLIANT: class-specific custom declaration
  void operator delete(void *ptr,
                       void *) noexcept; // NON_COMPLIANT: class-specific
                                         // placement delete declaration
  void operator delete[](void *ptr,
                         void *) noexcept; // NON_COMPLIANT: class-specific
                                           // placement delete[] declaration
  void operator delete(void *ptr,
                       int hint) noexcept; // NON_COMPLIANT: class-specific
                                           // custom delete declaration
};

/**
 * Class-specific operator definitions - NON_COMPLIANT (any signature)
 */
void *C1::operator new(std::size_t size) {
  return std::malloc(size);
} // NON_COMPLIANT: class-specific
void *C1::operator new[](std::size_t size) {
  return std::malloc(size);
} // NON_COMPLIANT: class-specific
void C1::operator delete(void *ptr) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: class-specific
void C1::operator delete[](void *ptr) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: class-specific
void *C1::operator new(std::size_t size, const std::nothrow_t &) noexcept {
  return std::malloc(size);
} // NON_COMPLIANT: class-specific nothrow
void *C1::operator new(std::size_t size, void *ptr) noexcept {
  return ptr;
} // NON_COMPLIANT: class-specific placement
void *C1::operator new[](std::size_t size, void *ptr) noexcept {
  return ptr;
} // NON_COMPLIANT: class-specific placement
void *C1::operator new(std::size_t size, int hint) {
  return std::malloc(size);
} // NON_COMPLIANT: class-specific custom
void *C1::operator new(std::size_t size, double alignment, int pool) {
  return std::malloc(size);
} // NON_COMPLIANT: class-specific custom

/**
 * Fixture class with class-specific operator new/delete inline definitions.
 */
class C2 {
public:
  C2() {}

  // Class-specific operator inline definitions - NON_COMPLIANT (any signature)
  void *operator new(std::size_t size) {
    return std::malloc(size);
  } // NON_COMPLIANT: class-specific inline
  void *operator new[](std::size_t size) {
    return std::malloc(size);
  } // NON_COMPLIANT: class-specific inline
  void operator delete(void *ptr) noexcept {
    std::free(ptr);
  } // NON_COMPLIANT: class-specific inline
  void operator delete[](void *ptr) noexcept {
    std::free(ptr);
  } // NON_COMPLIANT: class-specific inline
  void *operator new(std::size_t size, const std::nothrow_t &) noexcept {
    return std::malloc(size);
  } // NON_COMPLIANT: class-specific nothrow inline
  void *operator new(std::size_t size, void *ptr) noexcept {
    return ptr;
  } // NON_COMPLIANT: class-specific placement inline
  void *operator new[](std::size_t size, void *ptr) noexcept {
    return ptr;
  } // NON_COMPLIANT: class-specific placement inline
  void *operator new(std::size_t size, int hint) {
    return std::malloc(size);
  } // NON_COMPLIANT: class-specific custom inline
  void *operator new(std::size_t size, double alignment, int pool) {
    return std::malloc(size);
  } // NON_COMPLIANT: class-specific custom inline
};

/**
 * Re-declared allocation / deallocations functions - NON_COMPLIANT
 */
void *operator new(
    std::size_t size); // NON_COMPLIANT: re-declaring global replaceable
void *operator new(std::size_t size) {
  return std::malloc(size);
} // NON_COMPLIANT: implementing global replaceable
void operator delete(void *ptr) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: implementing global replaceable
void *operator new[](std::size_t size) {
  return std::malloc(size);
} // NON_COMPLIANT: implementing global replaceable
void operator delete[](void *ptr) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: implementing global replaceable
void *operator new(std::size_t size, const std::nothrow_t &) noexcept {
  return std::malloc(size);
} // NON_COMPLIANT: implementing global replaceable nothrow
void *operator new[](std::size_t size, const std::nothrow_t &) noexcept {
  return std::malloc(size);
} // NON_COMPLIANT: implementing global replaceable nothrow
void operator delete(void *ptr, std::size_t) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: implementing global replaceable sized
void operator delete[](void *ptr, std::size_t) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: implementing global replaceable sized
void operator delete(void *ptr, const std::nothrow_t &) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: implementing global replaceable placement deallocation
void operator delete[](void *ptr, const std::nothrow_t &) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: implementing global replaceable placement deallocation

/**
 * Global non-standard forms - NON_COMPLIANT
 * These are not in the four replaceable categories.
 */
void *
operator new(std::size_t size,
             void *ptr) noexcept; // NON_COMPLIANT: user-declared placement new
void *operator new[](
    std::size_t size,
    void *ptr) noexcept; // NON_COMPLIANT: user-declared placement new[]
void *operator new(std::size_t size, int hint) {
  return std::malloc(size);
} // NON_COMPLIANT: custom parameter
void *operator new(std::size_t size, double alignment, int pool) {
  return std::malloc(size);
} // NON_COMPLIANT: custom parameters
void operator delete(
    void *ptr,
    void *) noexcept; // NON_COMPLIANT: user-declared placement delete
void operator delete[](
    void *ptr,
    void *) noexcept; // NON_COMPLIANT: user-declared placement delete[]
void operator delete(void *ptr, int hint) noexcept {
  std::free(ptr);
} // NON_COMPLIANT: custom parameter

/**
 * Test replaceable new / delete expressions.
 */
void use_standard_new_delete() {
  // Compliant: new expressions that call the global `operator new`s.
  struct S {};
  S *p1 = new S;     // COMPLIANT
  S *p2 = new S[10]; // COMPLIANT
  void *p3 = ::operator new(sizeof(S));
  void *p4 = ::operator new[](sizeof(S));
  S *p5 = new (std::nothrow) S;     // COMPLIANT
  S *p6 = new (std::nothrow) S[10]; // COMPLIANT

  // Compliant: delete expressions that call the global `operator delete`s.
  delete p1;                             // COMPLIANT
  delete[] p2;                           // COMPLIANT
  ::operator delete(p3);                 // COMPLIANT
  ::operator delete[](p4);               // COMPLIANT
  ::operator delete(p5, std::nothrow);   // COMPLIANT
  ::operator delete[](p6, std::nothrow); // COMPLIANT
}

/**
 * Test placement new expressions.
 */
void use_placement_new() {
  std::size_t size = 10;
  alignas(C1) std::byte buffer[sizeof(C1)];
  C1 *p1 = new (buffer) C1; // NON_COMPLIANT: placement new expression
  C1 *p2 = new (buffer)
      C1{}; // NON_COMPLIANT: placement new expression with brace init

  alignas(C1) std::byte arr_buffer[sizeof(C1) * 10];
  C1 *p3 =
      new (arr_buffer) C1[size]; // NON_COMPLIANT: placement new[] expression

  void *mem = std::malloc(sizeof(C1)); // NON_COMPLIANT (Rule 21.6.2): malloc
  C1 *p4 = new (mem) C1; // NON_COMPLIANT: placement new expression
}

/**
 * Test custom-parameter new expressions.
 */
void use_custom_new_expressions() {
  C1 *p1 = new (42) C1; // NON_COMPLIANT: uses operator new(size_t, int)
  C1 *p2 =
      new (3.14, 1) C1; // NON_COMPLIANT: uses operator new(size_t, double, int)
}

/**
 * Test taking address of global placement new.
 */
void take_address_of_placement_new() {
  void *(*c1)(std::size_t) =
      &::operator new; // COMPLIANT: address of replaceable new
  void *(*c2)(std::size_t) =
      ::operator new; // COMPLIANT: implicit address of replaceable new
  void *(*c3)(std::size_t) =
      &::operator new[]; // COMPLIANT: address of replaceable new[]
  void *(*c4)(std::size_t) =
      ::operator new[]; // COMPLIANT: implicit address of replaceable new[]
  void *(*c5)(std::size_t, const std::nothrow_t &) =
      &::operator new; // COMPLIANT: address of nothrow new
  void *(*c6)(std::size_t, const std::nothrow_t &) =
      &::operator new[]; // COMPLIANT: address of nothrow new[]

  // Non-compliant: taking address of non-replaceable allocation functions
  void *(*p1)(std::size_t, void *) =
      &::operator new; // NON_COMPLIANT: address of placement new
  void *(*p2)(std::size_t, void *) =
      ::operator new; // NON_COMPLIANT: implicit address of placement new
  void *(*p3)(std::size_t, void *) =
      &::operator new[]; // NON_COMPLIANT: address of placement new[]
  void *(*p4)(std::size_t, void *) =
      ::operator new[]; // NON_COMPLIANT: implicit address of placement new[]
}

/**
 * Test taking address of global placement delete.
 */
void take_address_of_placement_delete() {
  // Compliant: taking address of replaceable deallocation functions
  void (*c1)(void *) =
      &::operator delete; // COMPLIANT: address of replaceable delete
  void (*c2)(void *) =
      ::operator delete; // COMPLIANT: implicit address of replaceable delete
  void (*c3)(void *) =
      &::operator delete[]; // COMPLIANT: address of replaceable delete[]
  void (*c4)(void *) = ::operator delete[]; // COMPLIANT: implicit address of
                                            // replaceable delete[]
  void (*c5)(void *, std::size_t) =
      &::operator delete; // COMPLIANT: address of sized delete
  void (*c6)(void *, std::size_t) =
      &::operator delete[]; // COMPLIANT: address of sized delete[]
  void (*c7)(void *, const std::nothrow_t &) =
      &::operator delete; // COMPLIANT: address of nothrow delete
  void (*c8)(void *, const std::nothrow_t &) =
      &::operator delete[]; // COMPLIANT: address of nothrow delete[]

  // Non-compliant: taking address of non-replaceable deallocation functions
  void (*p1)(void *, void *) =
      &::operator delete; // NON_COMPLIANT: address of placement delete
  void (*p2)(void *, void *) =
      ::operator delete; // NON_COMPLIANT: implicit address of placement delete
  void (*p3)(void *, void *) =
      &::operator delete[]; // NON_COMPLIANT: address of placement delete[]
  void (*p4)(void *, void *) =
      ::operator delete[]; // NON_COMPLIANT: implicit address of placement
                           // delete[]
}

/**
 * Test taking address of class-specific `operator new`s.
 * These are non-compliant overloads of the operator, but
 * These depend on the non-compliant operators being defined
 * in the first place (note that member functions need to be
 * implemented, beyond declared, to have an address).
 */
void take_address_of_class_specific_new() {
  void *(*p1)(std::size_t) =
      &C1::operator new; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                         // class-specific replaceable allocation function
  void *(*p2)(std::size_t) =
      &C1::operator new[]; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                           // class-specific replaceable allocation function
  void *(*p3)(std::size_t, const std::nothrow_t &) =
      &C1::operator new; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                         // class-specific replaceable non-throwing allocation
                         // function
  void *(*p4)(std::size_t, void *) =
      &C1::operator new; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                         // class-specific placement new
  void *(*p5)(std::size_t, int) =
      &C1::operator new; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                         // class-specific custom new
}

/**
 * Test taking address of class-specific `operator delete`s.
 * These are non-compliant overloads of the operator, but
 * These depend on the non-compliant operators being defined
 * in the first place (note that member functions need to be
 * implemented, beyond declared, to have an address).
 */
void take_address_of_class_specific_delete() {
  void (*p1)(void *) =
      &C1::operator delete; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                            // class-specific replaceable deallocation function
  void (*p2)(void *) =
      &C1::operator delete[]; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                              // class-specific replaceable deallocation
                              // function
  void (*p3)(void *, void *) =
      &C1::operator delete; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                            // class-specific placement delete
  void (*p4)(void *, void *) =
      &C1::operator delete[]; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                              // class-specific placement delete[]
  void (*p5)(void *, int) =
      &C1::operator delete; // NON_COMPLIANT[FALSE_NEGATIVE]: address of
                            // class-specific custom delete
}

/**
 * Test std::uninitialized_default_construct and
 * std::uninitialized_default_construct_n.
 */
void use_uninitialized_default_construct() {
  std::size_t size = 10;
  alignas(C1) std::byte buffer[sizeof(C1) * 10];
  C1 *begin = reinterpret_cast<C1 *>(buffer);
  C1 *end = begin + size;

  std::uninitialized_default_construct(begin, end);    // NON_COMPLIANT
  std::uninitialized_default_construct_n(begin, size); // NON_COMPLIANT
}

/**
 * Test std::uninitialized_value_construct and
 * std::uninitialized_value_construct_n.
 */
void use_uninitialized_value_construct() {
  std::size_t size = 10;
  alignas(C1) std::byte buffer[sizeof(C1) * 10];
  C1 *begin = reinterpret_cast<C1 *>(buffer);
  C1 *end = begin + size;

  std::uninitialized_value_construct(begin, end);    // NON_COMPLIANT
  std::uninitialized_value_construct_n(begin, size); // NON_COMPLIANT
}

/**
 * Test std::uninitialized_copy and std::uninitialized_copy_n.
 */
void use_uninitialized_copy() {
  std::size_t size = 10;
  C1 source[10];
  alignas(C1) std::byte buffer[sizeof(C1) * 10];
  C1 *dest = reinterpret_cast<C1 *>(buffer);

  std::uninitialized_copy(source, source + size, dest); // NON_COMPLIANT
  std::uninitialized_copy_n(source, size, dest);        // NON_COMPLIANT
}

/**
 * Test std::uninitialized_move and std::uninitialized_move_n.
 */
void use_uninitialized_move() {
  std::size_t size = 10;
  C1 source[10];
  alignas(C1) std::byte buffer[sizeof(C1) * 10];
  C1 *dest = reinterpret_cast<C1 *>(buffer);

  std::uninitialized_move(source, source + size, dest); // NON_COMPLIANT
  std::uninitialized_move_n(source, size, dest);        // NON_COMPLIANT
}

/**
 * Test std::uninitialized_fill and std::uninitialized_fill_n.
 */
void use_uninitialized_fill() {
  std::size_t size = 10;
  alignas(C1) std::byte buffer[sizeof(C1) * 10];
  C1 *begin = reinterpret_cast<C1 *>(buffer);
  C1 *end = begin + size;
  C1 value;

  std::uninitialized_fill(begin, end, value);    // NON_COMPLIANT
  std::uninitialized_fill_n(begin, size, value); // NON_COMPLIANT
}

/**
 * Test std::destroy, std::destroy_n, and std::destroy_at.
 */
void use_destroy() {
  std::size_t size = 10;
  alignas(C1) std::byte buffer[sizeof(C1) * 10];
  C1 *begin = reinterpret_cast<C1 *>(buffer);
  C1 *end = begin + size;

  std::uninitialized_default_construct(begin, end); // NON_COMPLIANT

  std::destroy(begin, end);    // NON_COMPLIANT
  std::destroy_n(begin, size); // NON_COMPLIANT
  std::destroy_at(begin);      // NON_COMPLIANT
}

/**
 * Test std::launder.
 */
void use_launder() {
  alignas(C1) std::byte buffer[sizeof(C1)];
  C1 *p1 = new (buffer) C1; // NON_COMPLIANT: placement new
  p1->~C1();                // NON_COMPLIANT: explicit destructor
  C1 *p2 = new (buffer) C1; // NON_COMPLIANT: placement new

  C1 *p3 = std::launder(p1); // NON_COMPLIANT: use of std::launder
}

/**
 * Test explicit destructor call via pointer.
 */
void use_explicit_destructor() {
  C1 obj;
  C1 *p = &obj;

  p->~C1(); // NON_COMPLIANT: explicit destructor call
}

/**
 * Test explicit destructor call via reference.
 */
void use_explicit_destructor_via_reference() {
  C1 obj;
  C1 &ref = obj;

  ref.~C1(); // NON_COMPLIANT: explicit destructor call
}

/**
 * Test explicit destructor call in array loop.
 */
void use_explicit_destructor_array() {
  std::size_t size = 10;
  C1 arr[10];

  for (std::size_t i = 0; i < size; ++i) {
    arr[i].~C1(); // NON_COMPLIANT: explicit destructor call
  }
}

int main() { return 0; }
