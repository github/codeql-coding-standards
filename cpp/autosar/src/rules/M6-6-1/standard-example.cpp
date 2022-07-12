void f1( )
{
  int32_t j = 0;
  goto L1;
  for(j = 0; j < 10 ; ++j)
  {
L1: // Non-compliant
    j;
  }
}
void f2( )
{
  for(int32_t j = 0; j < 10; ++j)
  {
    for(int32_t i = 0; i < 10; ++i)
    { 
      goto L1; 
    }
  }
L1: // Compliant
  f1( );                        
}