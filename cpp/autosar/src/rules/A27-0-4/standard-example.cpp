// $Id: A27-0-4.cpp 311495 2018-03-13 13:02:54Z michal.szczepankiewicz $
#include <iostream> 
#include <string> 
#include <list>
void F1()
{
  std::string string1;
  std::string string2;
  std::cin >> string1 >> string2; // Compliant - no buffer overflows
}

std::list<std::string> F2(const std::string& terminator)
{
  std::list<std::string> ret;
  //read a single word until it is different from the given terminator sequence 
  for (std::string s; std::cin >> s && s != terminator; )
  {
    ret.push_back(s);
  }
  return ret;
}