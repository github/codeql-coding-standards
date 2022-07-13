bool modify ( int32_t * pX )
{
  *pX++;
  return ( *pX < 10 );
}

for ( x = 0; modify ( &x ); ) // Non-compliant 
{
}
  
for ( x = 0; x < 10; )
{
  x = x * 2;                  // Non-compliant
}