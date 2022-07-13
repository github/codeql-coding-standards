char_t  ch = 't';              // Compliant
uint8_t v;
if((ch >= 'a') && (ch <= 'z')) // Non-compliant 
{
}
if((ch >= '0') && (ch <= '9')) // Compliant by exception
{
  v = ch - '0';                // Compliant by exception
  v = ch - '1';                // Non-compliant
} 
else
{ 
  // ...
}

ch = '0' + v;                  // Compliant by exception
ch = 'A' + v;                  // Non-compliant