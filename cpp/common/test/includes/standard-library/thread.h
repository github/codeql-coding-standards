namespace std {
class thread {
public:
  class id;
  thread() noexcept;
  template <class F, class... Args> explicit thread(F &&f, Args &&...args);
  ~thread();
  thread(const thread &) = delete;
  thread(thread &&) noexcept;
  thread &operator=(const thread &) = delete;
  thread &operator=(thread &&) noexcept;
  void swap(thread &) noexcept;
  bool joinable() const noexcept;
  void join();
  void detach();
  id get_id() const noexcept;
  static unsigned hardware_concurrency() noexcept;
};
} // namespace std