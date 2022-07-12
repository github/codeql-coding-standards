#include <cstdint>

namespace NS1 {
struct A {};

template <typename T> bool operator+(T, std::int32_t);
// NON_COMPLIANT: a member of namespace with declarations struct type

} // namespace NS1

namespace NS2

{
void A();

template <typename T> bool operator+(T, std::int32_t);
// / COMPLIANT: a member of namespace with declarations of functions only

} // namespace NS2

namespace NS3

{
enum A {};

template <typename T> bool operator+(T &, std::int32_t);
// NON_COMPLIANT: a member of namespace with declarations enum type

} // namespace NS3
namespace NS4

{
class A {};

template <typename T> bool operator+(T &&, std::int32_t);
// NON_COMPLIANT: a member of namespace with declarations class type

} // namespace NS4

namespace NS5

{
union A {};

template <typename T> bool operator+(T &, std::int32_t);
// NON_COMPLIANT: a member of namespace with declarations class type

} // namespace NS5