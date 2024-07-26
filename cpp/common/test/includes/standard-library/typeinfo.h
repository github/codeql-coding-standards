#include <stddef.h>

namespace std {
struct type_info {
  const char *name() const noexcept;
  std::size_t hash_code() const noexcept;
  bool operator==(const type_info &rhs) const;
};
} // namespace std