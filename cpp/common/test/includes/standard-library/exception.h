#ifndef _GHLIBCPP_EXCEPTION
#define _GHLIBCPP_EXCEPTION
namespace std {
class exception {
public:
  exception() noexcept;
  exception(const exception &) noexcept;
  exception &operator=(const exception &) noexcept;
  virtual ~exception();
  virtual const char *what() const noexcept;
};

[[noreturn]] void terminate() noexcept;
bool uncaught_exception() noexcept;

void set_terminate(void *);
void set_unexpected(void *);

} // namespace std
#endif // _GHLIBCPP_EXCEPTION