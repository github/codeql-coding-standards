float32_t My_fabs(float32_t f)
{
  uint8_t * pB = reinterpret_cast< uint8_t * >( &f );
  *(pB + 3) &= 0x7f; // Non-compliant – generate the absolute value
                     //                 of an IEEE-754 float value.
  return(f); 
}