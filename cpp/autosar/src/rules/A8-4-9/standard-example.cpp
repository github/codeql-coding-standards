// $Id: A8-4-9.cpp 306178 2018-02-01 15:52:25Z christof.meerwald $ 2
#include <cstdint>
#include <numeric>
#include <string>
#include <vector>

// Non-Compliant: does not modify the "in-out" parameter
int32_t Sum(std::vector<int32_t> &v)
{
  return std::accumulate(v.begin(), v.end(), 0);
}

// Compliant: Modifying "in-out" parameter
void AppendNewline(std::string &s)
{
  s += '\n';
}

// Non-Compliant: Replacing parameter value
void GetFileExtension(std::string &ext)
{
  ext = ".cpp";
}