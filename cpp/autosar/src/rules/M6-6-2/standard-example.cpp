void f( )
{
  int32_t j = 0;
L1:
  ++j;
  if(10 == j)
  { 
    goto L2; // Compliant
  }
  goto L1;   // Non-compliant
L2:
  ++j; 
}