#include <stddef.h>

namespace std {
struct type_info {
  const char *name() const noexcept;
  std::size_t hash_code() const noexcept;
};
} // namespace std