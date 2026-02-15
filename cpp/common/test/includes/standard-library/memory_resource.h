#ifndef _GHLIBCPP_MEMORY_RESOURCE
#define _GHLIBCPP_MEMORY_RESOURCE

#include <cstddef>
#include <new>
#include <tuple>
#include <utility>

namespace std::pmr {

class memory_resource {
public:
  memory_resource() = default;
  memory_resource(const memory_resource &) = default;
  virtual ~memory_resource();

  void *allocate(std::size_t, std::size_t = alignof(std::max_align_t));
  void deallocate(void *, std::size_t, std::size_t = alignof(std::max_align_t));

private:
  virtual void *do_allocate(std::size_t, std::size_t) = 0;
  virtual void do_deallocate(void *, std::size_t, std::size_t) = 0;
  virtual bool do_is_equal(const memory_resource &) const noexcept = 0;
};

template <typename T1> class polymorphic_allocator {
public:
  using value_type = T1;

  polymorphic_allocator() noexcept;
  polymorphic_allocator(memory_resource *);
  polymorphic_allocator(const polymorphic_allocator &) = default;

  template <typename T2>
  polymorphic_allocator(const polymorphic_allocator<T2> &) noexcept;

  T1 *allocate(std::size_t);
  void deallocate(T1 *, std::size_t);

  memory_resource *resource() const;

private:
  memory_resource *resource_;
};

struct pool_options {
  std::size_t max_blocks_per_chunk = 0;
  std::size_t largest_required_pool_block = 0;
};

class monotonic_buffer_resource : public memory_resource {
public:
  explicit monotonic_buffer_resource(memory_resource *);
  monotonic_buffer_resource(std::size_t, memory_resource *);
  monotonic_buffer_resource(void *, std::size_t, memory_resource *);

  monotonic_buffer_resource();
  explicit monotonic_buffer_resource(std::size_t);
  monotonic_buffer_resource(void *, std::size_t);

  monotonic_buffer_resource(const monotonic_buffer_resource &) = delete;
  ~monotonic_buffer_resource() override;

  void release();
  memory_resource *upstream_resource() const;

private:
  void *do_allocate(std::size_t, std::size_t) override;
  void do_deallocate(void *, std::size_t, std::size_t) override;
  bool do_is_equal(const memory_resource &) const noexcept override;
};

class unsynchronized_pool_resource : public memory_resource {
public:
  unsynchronized_pool_resource(const pool_options &, memory_resource *);
  unsynchronized_pool_resource();
  explicit unsynchronized_pool_resource(memory_resource *);
  explicit unsynchronized_pool_resource(const pool_options &);

  unsynchronized_pool_resource(const unsynchronized_pool_resource &) = delete;
  ~unsynchronized_pool_resource() override;

  void release();
  memory_resource *upstream_resource() const;
  pool_options options() const;

protected:
  void *do_allocate(std::size_t, std::size_t) override;
  void do_deallocate(void *, std::size_t, std::size_t) override;
  bool do_is_equal(const memory_resource &) const noexcept override;
};

class synchronized_pool_resource : public memory_resource {
public:
  synchronized_pool_resource(const pool_options &, memory_resource *);
  synchronized_pool_resource();
  explicit synchronized_pool_resource(memory_resource *);
  explicit synchronized_pool_resource(const pool_options &);

  synchronized_pool_resource(const synchronized_pool_resource &) = delete;
  ~synchronized_pool_resource() override;

  void release();
  memory_resource *upstream_resource() const;
  pool_options options() const;

protected:
  void *do_allocate(std::size_t, std::size_t) override;
  void do_deallocate(void *, std::size_t, std::size_t) override;
  bool do_is_equal(const memory_resource &) const noexcept override;
};
} // namespace std::pmr

#endif // _GHLIBCPP_MEMORY_RESOURCE
