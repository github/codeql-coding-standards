// $Id: A8-4-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
void Print1(char* format, ...) // Non-compliant - variadic arguments are used
{
  // ...
}

template <typename First, typename... Rest>
void Print2(const First& first, const Rest&... args) // Compliant
{
  // ...
}