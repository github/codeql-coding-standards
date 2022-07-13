#ifndef _GHLIBCPP_CHRONO
#define _GHLIBCPP_CHRONO

namespace std {
namespace chrono {
class duration {};

class time_point {};

class system_clock {
public:
  static time_point now() noexcept;
};
} // namespace chrono
inline namespace literals {
inline namespace chrono_literals {
chrono::duration operator""ms(unsigned long long ms);
}
} // namespace literals
} // namespace std
#endif // _GHLIBCPP_CHRONO