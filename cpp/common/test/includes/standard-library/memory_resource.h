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
    memory_resource(const memory_resource&) = default;
    virtual ~memory_resource();

    memory_resource& operator=(const memory_resource&) = default;

    void* allocate(std::size_t, std::size_t = alignof(std::max_align_t));
    void deallocate(void*, std::size_t, std::size_t = alignof(std::max_align_t));
    bool is_equal(const memory_resource&) const noexcept;

  private:
    virtual void* do_allocate(std::size_t, std::size_t) = 0;
    virtual void do_deallocate(void*, std::size_t, std::size_t) = 0;
    virtual bool do_is_equal(const memory_resource&) const noexcept = 0;
  };

  bool operator==(const memory_resource&, const memory_resource&) noexcept;
  bool operator!=(const memory_resource&, const memory_resource&) noexcept;

  memory_resource* new_delete_resource() noexcept;
  memory_resource* null_memory_resource() noexcept;
  memory_resource* get_default_resource() noexcept;
  memory_resource* set_default_resource(memory_resource*) noexcept;


  template <typename T1>
  class polymorphic_allocator {
  public:
    using value_type = T1;

    polymorphic_allocator() noexcept;
    polymorphic_allocator(memory_resource*);
    polymorphic_allocator(const polymorphic_allocator&) = default;

    template <typename T2>
    polymorphic_allocator(const polymorphic_allocator<T2>&) noexcept;

    polymorphic_allocator& operator=(const polymorphic_allocator&) = delete;

    T1* allocate(std::size_t);
    void deallocate(T1*, std::size_t);

    template <typename T2, typename
              ... T3>
    void construct(T2*, T3&&...);

    template <typename T3, typename T4, typename... T5, typename... T6>
    void construct(std::pair<T3, T4>*,
                   std::piecewise_construct_t,
                   std::tuple<T5...>,
                   std::tuple<T6...>);

    template <typename T3, typename T4>
    void construct(std::pair<T3, T4>*);

    template <typename T3, typename T4, typename T5, typename T6>
    void construct(std::pair<T3, T4>*, T5&&, T6&&);

    template <typename T3, typename T4, typename T5, typename T6>
    void construct(std::pair<T3, T4>*, const std::pair<T5, T6>&);

    template <typename T3, typename T4, typename T5, typename T6>
    void construct(std::pair<T3, T4>*, std::pair<T5, T6>&&);

    template <typename T2>
    void destroy(T2*);

    polymorphic_allocator select_on_container_copy_construction() const;

    memory_resource* resource() const;

  private:
    memory_resource* resource_;
  };

  template <typename T1, typename T2>
  bool operator==(const polymorphic_allocator<T1>&,
                  const polymorphic_allocator<T2>&) noexcept;

  template <typename T1, typename T2>
  bool operator!=(const polymorphic_allocator<T1>&,
                  const polymorphic_allocator<T2>&) noexcept;


  struct pool_options {
    std::size_t max_blocks_per_chunk = 0;
    std::size_t largest_required_pool_block = 0;
  };


  class monotonic_buffer_resource : public memory_resource {
  public:
    explicit monotonic_buffer_resource(memory_resource*);
    monotonic_buffer_resource(std::size_t, memory_resource*);
    monotonic_buffer_resource(void*, std::size_t, memory_resource*);

    monotonic_buffer_resource();
    explicit monotonic_buffer_resource(std::size_t);
    monotonic_buffer_resource(void*, std::size_t);

    monotonic_buffer_resource(const monotonic_buffer_resource&) = delete;

    ~monotonic_buffer_resource() override;

    monotonic_buffer_resource& operator=(const monotonic_buffer_resource&) = delete;

    void release();
    memory_resource* upstream_resource() const;

  private:
    void* do_allocate(std::size_t, std::size_t) override;
    void do_deallocate(void*, std::size_t, std::size_t) override;
    bool do_is_equal(const memory_resource&) const noexcept override;

    void* current_buffer_;
    std::size_t current_buffer_size_;
    std::size_t current_offset_;
    std::size_t next_buffer_size_;
    void* chunks_;
    memory_resource* upstream_;
    void* initial_buffer_;
    std::size_t initial_buffer_size_;
  };


  class unsynchronized_pool_resource : public memory_resource {
  public:
    unsynchronized_pool_resource(const pool_options&, memory_resource*);

    unsynchronized_pool_resource();
    explicit unsynchronized_pool_resource(memory_resource*);
    explicit unsynchronized_pool_resource(const pool_options&);

    unsynchronized_pool_resource(const unsynchronized_pool_resource&) = delete;

    ~unsynchronized_pool_resource() override;

    unsynchronized_pool_resource& operator=(const unsynchronized_pool_resource&) = delete;

    void release();

    memory_resource* upstream_resource() const;
    pool_options options() const;

  protected:
    void* do_allocate(std::size_t, std::size_t) override;
    void do_deallocate(void*, std::size_t, std::size_t) override;
    bool do_is_equal(const memory_resource&) const noexcept override;

  private:
    pool_options options_;
    memory_resource* upstream_;
    void* pools_;
    void* chunks_;
  };


  class synchronized_pool_resource : public memory_resource {
  public:
    synchronized_pool_resource(const pool_options&, memory_resource*);

    synchronized_pool_resource();
    explicit synchronized_pool_resource(memory_resource*);
    explicit synchronized_pool_resource(const pool_options&);

    synchronized_pool_resource(const synchronized_pool_resource&) = delete;

    ~synchronized_pool_resource() override;

    synchronized_pool_resource& operator=(const synchronized_pool_resource&) = delete;

    void release();

    memory_resource* upstream_resource() const;
    pool_options options() const;

  protected:
    void* do_allocate(std::size_t, std::size_t) override;
    void do_deallocate(void*, std::size_t, std::size_t) override;
    bool do_is_equal(const memory_resource&) const noexcept override;

  private:
    pool_options options_;
    memory_resource* upstream_;
    void* pools_;
    void* chunks_;
    void* mutex_;
  };

} // namespace std::pmr

#endif // _GHLIBCPP_MEMORY_RESOURCE
