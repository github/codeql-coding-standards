for(x = 0; (x < 10) && !bool_a; ++x)
{
  if(...)
  {
    bool_a = true;                     // Compliant
  } 
}
bool test_a(bool * pB)
{
  *pB = ... ? true : false;
  return *pB; 
}
for(x = 0;
    (x < 10) && test_a(&bool_a);
    ++x)                               // Non-compliant
volatile bool status;
for(x = 0; (x < 10) && status; ++x)    // Compliant
for(x = 0; x < 10; bool_a = test(++x)) // Non-compliant