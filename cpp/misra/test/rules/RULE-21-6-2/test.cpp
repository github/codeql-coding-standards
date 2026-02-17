#include <cstdlib>
#include <stdlib.h>
#include <memory>
#include <memory_resource>
#include <scoped_allocator>

class C1 {
public:
  C1() {}
};

// Item 1: Any non-placement form of new or delete

void use_of_new() {
  C1 x1;                 // compliant: no use of new
  C1 x2{};               // compliant: no use of new
  C1 *x3 = new C1;       // non_compliant: use of new
  C1 *x4 = new (&x1) C1; // compliant: placement new (but violates Rule 21.6.3)
}

void use_of_delete() {
  C1 *x1 = new C1; // non_compliant: use of new
  delete x1;       // non_compliant: use of delete
}

// Item 2: Any of the functions malloc, calloc, realloc, aligned_alloc, free

void use_of_malloc() {
  C1 *x1 = static_cast<C1 *>(
      std::malloc(sizeof(C1))); // non_compliant: use of malloc
  C1 *x2 = static_cast<C1 *>(
      malloc(sizeof(C1))); // non_compliant: use of malloc from global namespace
}

void use_of_calloc() {
  C1 *x1 = static_cast<C1 *>(
      std::calloc(1, sizeof(C1))); // non_compliant: use of calloc
  C1 *x2 = static_cast<C1 *>(calloc(
      1, sizeof(C1))); // non_compliant: use of calloc from global namespace
}

void use_of_realloc() {
  void *p = std::malloc(sizeof(C1));          // non_compliant: use of malloc
  void *q1 = std::realloc(p, sizeof(C1) * 2); // non_compliant: use of realloc
  void *q2 = realloc(
      p, sizeof(C1) * 2); // non_compliant: use of realloc from global namespace
}

void use_of_aligned_alloc() {
  void *x1 = std::aligned_alloc(
      alignof(C1), sizeof(C1)); // non_compliant: use of aligned_alloc
  void *x2 = aligned_alloc(
      alignof(C1),
      sizeof(C1)); // non_compliant: use of aligned_alloc from global namespace
}

void use_of_free() {
  C1 *c1 = static_cast<C1 *>(
      std::malloc(sizeof(C1))); // non_compliant: use of malloc
  std::free(c1);                // non_compliant: use of free
  free(c1); // non_compliant: use of free from global namespace
}

// Item 3: Any member function named allocate or deallocate enclosed by
// namespace std

void use_of_std_allocator() {
  std::allocator<C1> alloc;
  C1 *p1 = alloc.allocate(1); // non_compliant: std::allocator::allocate
  alloc.deallocate(p1, 1);    // non_compliant: std::allocator::deallocate
}

void use_of_allocator_traits() {
  std::allocator<C1> alloc;
  using Traits = std::allocator_traits<std::allocator<C1>>;

  C1 *p1 = Traits::allocate(
      alloc, 1); // non_compliant: std::allocator_traits::allocate
  Traits::deallocate(alloc, p1,
                     1); // non_compliant: std::allocator_traits::deallocate
}

void use_of_memory_resource(std::pmr::memory_resource &mr) {
  void *p1 =
      mr.allocate(sizeof(C1));   // non_compliant: memory_resource::allocate
  mr.deallocate(p1, sizeof(C1)); // non_compliant: memory_resource::deallocate

  void *p2 = mr.allocate(
      sizeof(C1),
      alignof(C1)); // non_compliant: memory_resource::allocate (with alignment)
  mr.deallocate(
      p2, sizeof(C1),
      alignof(
          C1)); // non_compliant: memory_resource::deallocate (with alignment)
}

void use_of_polymorphic_allocator() {
  std::pmr::polymorphic_allocator<C1> alloc;
  C1 *p1 = alloc.allocate(1); // non_compliant: polymorphic_allocator::allocate
  alloc.deallocate(p1, 1); // non_compliant: polymorphic_allocator::deallocate
}

void use_of_monotonic_buffer_resource() {
  char buffer[1024];
  std::pmr::monotonic_buffer_resource mr{buffer, sizeof(buffer)};

  void *p1 = mr.allocate(
      sizeof(C1)); // non_compliant: monotonic_buffer_resource::allocate
  mr.deallocate(
      p1, sizeof(C1)); // non_compliant: monotonic_buffer_resource::deallocate
}

void use_of_pool_resources() {
  std::pmr::unsynchronized_pool_resource unsync_pool;
  void *p1 = unsync_pool.allocate(
      sizeof(C1)); // non_compliant: unsynchronized_pool_resource::allocate
  unsync_pool.deallocate(
      p1,
      sizeof(C1)); // non_compliant: unsynchronized_pool_resource::deallocate

  std::pmr::synchronized_pool_resource sync_pool;
  void *p2 = sync_pool.allocate(
      sizeof(C1)); // non_compliant: synchronized_pool_resource::allocate
  sync_pool.deallocate(
      p2, sizeof(C1)); // non_compliant: synchronized_pool_resource::deallocate
}

void use_of_scoped_allocator_adaptor() {
  using Alloc = std::scoped_allocator_adaptor<std::allocator<C1>>;
  Alloc alloc;

  C1 *p1 =
      alloc.allocate(1); // non_compliant: scoped_allocator_adaptor::allocate
  alloc.deallocate(p1,
                   1); // non_compliant: scoped_allocator_adaptor::deallocate
}

// Item 4: std::unique_ptr::release

void use_of_unique_ptr_release() {
  auto p1 = std::make_unique<C1>(); // compliant: smart pointer creation
  C1 *raw1 = p1.release();          // non_compliant: std::unique_ptr::release
  delete raw1;                      // non_compliant: use of delete

  auto p2 =
      std::make_unique<C1[]>(10); // compliant: smart pointer array creation
  C1 *raw2 =
      p2.release(); // non_compliant: std::unique_ptr::release (array form)
  delete[] raw2;    // non_compliant: use of delete[]
}

void delete_via_get() {
  auto p1 = std::make_unique<C1>();
  C1 *raw = p1.get(); // compliant: get() is fine
  delete raw;         // non_compliant: use of delete (causes double-free!)
}

int main() { return 0; }
