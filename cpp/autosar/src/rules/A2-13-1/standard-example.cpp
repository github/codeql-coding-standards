//% $Id: A2-13-1.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <string>
void F()
{
  const std::string a = "\k";         // Non-compliant
  const std::string b = "\n";         // Compliant
  const std::string c = "\U0001f34c"; // Compliant
}