// $Id: A8-4-8.cpp 306164 2018-02-01 15:04:53Z christof.meerwald $ 2
#include <iostream>
#include <vector>
// Compliant, return value
std::vector<int> SortOutOfPlace(const std::vector<int>& inVec);

// Non-compliant: return value as an out-parameter
void FindAll(const std::vector<int>& inVec, std::vector<int>& outVec);

struct B
{
};

struct BB
{
  B GetB() const& { return obj; }
  B&& GetB() && { return std::move(obj); }

  B obj;
};

// Non-compliant: returns a dangling reference
BB&& MakeBb1()
{
  return std::move(BB());
}

// Compliant: uses compiler copy-ellision
BB MakeBb2()
{
  return BB();
} 

int main()
{
  BB x = MakeBb2();

  auto cpd = x.GetB();         // copied value
  auto mvd = MakeBb2().GetB(); // moved value

  return 0;
}