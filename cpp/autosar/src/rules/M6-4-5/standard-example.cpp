switch(x)
{
case 0: 
  break; // Compliant
case 1:  // Compliant - empty drop through
         //             allows a group
case 2:
  break; // Compliant
case 3:
  throw; // Compliant
case 4: 
  a = b;
         // Non-compliant - non empty drop through
default:
  ;      // Non-compliant – default must also have "break"
}