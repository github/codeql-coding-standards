#ifndef _GHLIBCPP_MUTEX
#define _GHLIBCPP_MUTEX
#include "chrono.h"

namespace std {

struct adopt_lock_t {
  explicit adopt_lock_t() = default;
};

struct defer_lock_t {
  explicit defer_lock_t() = default;
};

struct try_to_lock_t {
  explicit try_to_lock_t() = default;
};

constexpr adopt_lock_t adopt_lock{};
constexpr defer_lock_t defer_lock{};
constexpr try_to_lock_t try_to_lock{};

class mutex {
public:
  constexpr mutex() noexcept;
  ~mutex();
  mutex(const mutex &) = delete;
  mutex &operator=(const mutex &) = delete;
  void lock();
  bool try_lock();
  void unlock();
};

// unique_lock uses a simplified chrono library

template <class Mutex> class unique_lock {
public:
  typedef Mutex mutex_type;
  unique_lock() noexcept;
  explicit unique_lock(mutex_type &m);
  unique_lock(mutex_type &__m, adopt_lock_t);
  unique_lock(mutex_type &__m, defer_lock_t);
  unique_lock(mutex_type &__m, try_to_lock_t);
  unique_lock(mutex_type &m, const chrono::duration &rel_time);
  ~unique_lock();
  unique_lock(unique_lock const &) = delete;
  unique_lock &operator=(unique_lock const &) = delete;
  unique_lock(unique_lock &&u) noexcept;
  unique_lock &operator=(unique_lock &&u);
  void lock();
  bool try_lock();
  bool try_lock_for(const chrono::duration &rel_time);
  bool try_lock_until(const chrono::time_point &abs_time);
  void unlock();
  void swap(unique_lock &u) noexcept;
  mutex_type *release() noexcept;
  bool owns_lock() const noexcept;
  explicit operator bool() const noexcept;
  mutex_type *mutex() const noexcept;
};
template <class Mutex>
void swap(unique_lock<Mutex> &x, unique_lock<Mutex> &y) noexcept;

template <class _Lock0, class _Lock1, class... _LockN>
void lock(_Lock0 &_Lk0, _Lock1 &_Lk1, _LockN &..._LkN) { }

template <typename Mutex> class lock_guard {
public:
  typedef Mutex mutex_type;

  explicit lock_guard(mutex_type &__m);
  lock_guard(const lock_guard &) = delete;
  lock_guard &operator=(const lock_guard &) = delete;
};

} // namespace std

#endif // _GHLIBCPP_MUTEX
