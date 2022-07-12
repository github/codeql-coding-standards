#ifndef _GHLIBCPP_CONDITION_VARIABLE
#define _GHLIBCPP_CONDITION_VARIABLE
#include "chrono.h"
#include "mutex.h"

namespace std {

enum class cv_status { no_timeout, timeout };

// condition_variable uses a simplified chrono library

class condition_variable {
public:
  condition_variable();
  ~condition_variable();
  condition_variable(const condition_variable &) = delete;
  condition_variable &operator=(const condition_variable &) = delete;
  void notify_one() noexcept;
  void notify_all() noexcept;
  void wait(unique_lock<mutex> &lock);
  template <class Predicate>
  void wait(std::unique_lock<std::mutex> &lock, Predicate stop_waiting);
  cv_status wait_until(unique_lock<mutex> &lock,
                       const chrono::time_point &abs_time);
  cv_status wait_for(unique_lock<mutex> &lock,
                     const chrono::duration &rel_time);
};

class condition_variable_any {
public:
  condition_variable_any();
  ~condition_variable_any();
  condition_variable_any(const condition_variable_any &) = delete;
  condition_variable &operator=(const condition_variable_any &) = delete;
  void notify_one() noexcept;
  void notify_all() noexcept;
  void wait(unique_lock<mutex> &lock);
  cv_status wait_until(unique_lock<mutex> &lock,
                       const chrono::time_point &abs_time);
  cv_status wait_for(unique_lock<mutex> &lock,
                     const chrono::duration &rel_time);
};
} // namespace std
#endif // _GHLIBCPP_CONDITION_VARIABLE