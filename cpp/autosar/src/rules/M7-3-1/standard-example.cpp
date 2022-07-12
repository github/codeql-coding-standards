void f1(int32_t); // Non-compliant
int32_t x1;       // Non-compliant
namespace
{ 
  void f2(int32_t); // Compliant
  int32_t x2;       // Compliant
}
namespace MY_API
{
  void b2(int32_t); // Compliant
  int32_t x2;       // Compliant
}
int32_t main()      // Compliant 
{
}