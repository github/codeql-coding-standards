#include <algorithm>
#include <new>
#include <stddef.h>
#include <vector>

class ClassA {
public:
  ClassA() : m1(1) {}
  ClassA(int p_m1) : m1(p_m1) {}

private:
  int m1;
};

class ClassB {};

void test_global_operator_new() {
  void *correctlyAllocatedMemory = ::operator new(sizeof(ClassA));
  ClassA *a1 = new (correctlyAllocatedMemory) ClassA(1); // COMPLIANT
  a1->~ClassA();
  ::operator delete(correctlyAllocatedMemory);

  // The memory allocation is of a fixed size that's sufficient
  void *correctlyAllocatedMemory2 = ::operator new(100);
  ClassA *a2 = new (correctlyAllocatedMemory2) ClassA(1); // COMPLIANT
  a2->~ClassA();
  ::operator delete(correctlyAllocatedMemory2);

  void *badlyAllocatedMemory = ::operator new(sizeof(ClassB));
  // badlyAllocatedMemory does not have enough space
  ClassA *a3 = new (badlyAllocatedMemory) ClassA(1); // NON_COMPLIANT
  a3->~ClassA();
  ::operator delete(badlyAllocatedMemory);

  void *badlyAllocatedMemory2 = ::operator new(1);
  // badlyAllocatedMemory2 does not have enough space
  ClassA *a4 = new (badlyAllocatedMemory2) ClassA(1); // NON_COMPLIANT
  a4->~ClassA();
  ::operator delete(badlyAllocatedMemory2);
}

void test_local_address_of() {
  ClassA a;
  ClassA *a1 = new (&a) ClassA(1); // COMPLIANT
  ClassB b;
  ClassA *a2 = new (&b) ClassA(1); // NON_COMPLIANT
}

void test_local_array() {
  char goodAlloc alignas(ClassA)[sizeof(ClassA)];
  ClassA *a1 = new (goodAlloc) ClassA(1); // COMPLIANT
  char badAlloc alignas(ClassB)[sizeof(ClassB)];
  ClassA *a2 = new (badAlloc) ClassA(1); // NON_COMPLIANT
}

template <typename T> class PoolAlloc {
public:
  void *allocate() {
    void *memory;
    if (pool.empty()) {
      // allocation is an origin for placement new
      memory = ::operator new(sizeof(T));
    } else {
      // static_cast is an origin for placement new
      memory = static_cast<void *>(pop());
    }
    return memory;
  }

  void *deallocate(void *memory) { pool.push_back(static_cast<T *>(memory)); }

  ~PoolAlloc() {
    for (auto m : pool) {
      delete m;
    }
    pool.clear();
  }

private:
  T *pop() {
    T *back = pool.back();
    pool.pop_back();
    return back;
  }
  std::vector<T *> pool;
};

void test_pool_alloc() {
  // Create a pool allocator for ClassA
  PoolAlloc<ClassA> poolClassA;
  // The origin of this allocation call is in the PoolAlloc and is either the
  // static_cast or the allocation call of a buffer which is suitably sized for
  // ClassA
  void *goodAlloc = poolClassA.allocate();
  ClassA *a1 = new (goodAlloc) ClassA(1); // COMPLIANT

  PoolAlloc<ClassB> poolClassB;
  void *badAlloc = poolClassB.allocate();
  // Wrong pool used
  ClassA *a2 = new (badAlloc) ClassA(1); // NON_COMPLIANT - origins do not
                                         // have enough space
}

void test_array_alloc(unsigned int N2) {
  const unsigned N = 32;
  unsigned char badAlloc alignas(ClassA)[sizeof(ClassA) * N];
  // Allocating an array usually requires more space than just the elements
  // themselves Compilers will typically add a "cookie" on the front which
  // stores the number of elements so that the delete can call the appropriate
  // number of destructors. The amount of space added is implementation
  // dependent
  ClassA *a1 =
      ::new (badAlloc) ClassA[N]; // NON_COMPLIANT - no space for cookie

  // The additional space required is implementation dependent, but for
  // clang/gcc it's size_t plus any alignment considerations.
  unsigned char goodAlloc alignas(
      ClassA)[sizeof(ClassA) * N +
              std::max(sizeof(std::size_t), alignof(ClassA))];
  ClassA *a2 = ::new (goodAlloc) ClassA[N]; // COMPLIANT

  unsigned char goodAlloc2 alignas(
      ClassA)[sizeof(ClassA) * N +
              std::max(sizeof(std::size_t), alignof(ClassA))];
  if (N2 < N) {
    ClassA *a3 = ::new (goodAlloc2) ClassA[N2]; // COMPLIANT
  }
}