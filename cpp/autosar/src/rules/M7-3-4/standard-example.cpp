namespace NS1
{
  int32_t i1;
  int32_t j1;
  int32_t k1; 
}
using namespace NS1; // Non-compliant
  namespace NS2
{
  int32_t i2;
  int32_t j2;
  int32_t k2; 
}
using NS2::j2; // Compliant
namespace NS3
{
  int32_t i3;
  int32_t j3;
  int32_t k3; 
}
void f()
{
  ++i1;
  ++j2;
  ++NS3::k3; 
}