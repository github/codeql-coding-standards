// $Id: A8-4-10.cpp 307966 2018-02-16 16:03:46Z christof.meerwald $ 2
#include <cstdint>
#include <numeric>
#include <vector>

// Non-Compliant: non-optional parameter passed by pointer
int32_t Sum(const std::vector<int32_t> *v)
{
  return std::accumulate(v->begin(), v->end(), 0); 
}

// Compliant: non-optional parameter passed by reference
int32_t Sum(const std::vector<int32_t> &v) 
{
  return std::accumulate(v.begin(), v.end(), 0); 
}