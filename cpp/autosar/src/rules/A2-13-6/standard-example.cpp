//% $Id: A2-13-6.cpp 307578 2018-02-14 14:46:20Z michal.szczepankiewicz $
#include <string>
void F()
{
  const std::string c = "\U0001f34c"; // Compliant 
}

//non-compliant
void \U0001f615()
{
  //
}