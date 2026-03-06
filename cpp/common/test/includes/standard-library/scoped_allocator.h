#ifndef _GHLIBCPP_SCOPED_ALLOCATOR
#define _GHLIBCPP_SCOPED_ALLOCATOR

#include <cstddef>
#include <memory>

namespace std {

// =============================================================================
// std::scoped_allocator_adaptor
// =============================================================================

template <typename T1, typename... T2>
class scoped_allocator_adaptor : public T1 {
public:
  using outer_allocator_type = T1;
  using value_type = typename allocator_traits<T1>::value_type;
  using size_type = typename allocator_traits<T1>::size_type;
  using pointer = typename allocator_traits<T1>::pointer;
  using const_void_pointer = typename allocator_traits<T1>::const_void_pointer;

  scoped_allocator_adaptor();
  scoped_allocator_adaptor(const scoped_allocator_adaptor &) noexcept;
  scoped_allocator_adaptor(scoped_allocator_adaptor &&) noexcept;

  ~scoped_allocator_adaptor() = default;

  pointer allocate(size_type);
  pointer allocate(size_type, const_void_pointer);
  void deallocate(pointer, size_type);
};

} // namespace std

#endif // _GHLIBCPP_SCOPED_ALLOCATOR
