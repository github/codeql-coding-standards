// $Id: A26-5-1.cpp 311495 2018-03-13 13:02:54Z michal.szczepankiewicz $
#include <cstdlib> 
#include <cstdint> 
#include <ctime> 
#include <iostream> 
#include <random>
int main() {
  std::srand(std::time(nullptr));
  int r1 = std::rand() % 100; //non-compliant
  std::cout << "Random value using std::rand(): " << r1 << std::endl;

  std::random_device rd;
  std::default_random_engine eng{rd()};
  std::uniform_int_distribution<int> ud{0, 100};
  int r2 = ud(eng); //compliant
  std::cout << "Random value using std::random_device: " << r2 << std::endl;
  return 0;
}