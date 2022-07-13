void fn( )
{
  for(int32_t i = 0; i != 10; ++i)
  {
    if((i % 2) == 0)
    { 
      continue; // Compliant
    }
    // ... 
  }
  int32_t j = -1;
  for(int32_t i = 0 ; i != 10 && j != i; ++i)
  {
    if((i % 2) == 0)
    { 
      continue; // Non-compliant – loop is not well-formed
    }
    // ...
    ++j; 
  }
}