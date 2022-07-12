x = y;
x = y = z;            // Non-compliant
if(x != 0)            // Compliant
{
  foo(); 
}
bool b1 = x != y;     // Compliant
bool b2;
b2 = x != y;          // Compliant
if((x = y) != 0)      // Non-compliant
{
  foo();
}
if(x = y)             // Non-compliant
{
  foo();
}
if(int16_t i = foo()) // Compliant
{
}