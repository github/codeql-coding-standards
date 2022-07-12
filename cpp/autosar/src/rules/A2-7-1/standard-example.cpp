// $Id: A2-7-1.cpp 305382 2018-01-26 06:32:15Z michal.szczepankiewicz $
#include <cstdint>
void Fn() noexcept
{
  std::int8_t idx = 0;
  // Incrementing idx before the loop starts // Requirement X.X.X \\
  ++idx; // Non-compliant - ++idx was unexpectedly commented-out because of \ character occurrence in the end of C++ comment
  constexpr std::int8_t limit = 10; 
  for (; idx <= limit; ++idx)
  {
    // ... 
  }
}