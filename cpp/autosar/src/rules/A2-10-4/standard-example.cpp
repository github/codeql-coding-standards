//% $Id: A2-10-4.cpp 305382 2018-01-26 06:32:15Z michal.szczepankiewicz $
#include <cstdint>
// f1.cpp
namespace ns1
{
  static std::int32_t globalvariable = 0;
}

// f2.cpp
namespace ns1
{
// static std::int32_t globalvariable = 0; // Non-compliant - identifier reused
// in ns1 namespace in f1.cpp
}
namespace ns2
{
  static std::int32_t globalvariable =
        0; // Compliant - identifier reused, but in another namespace
}

// f3.cpp
static std::int32_t globalvariable =
       0; // Compliant - identifier reused, but in another namespace