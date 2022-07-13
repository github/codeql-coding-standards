switch(x)
{
case 0: 
  ...
  break; // break is required here
case 1:  // empty clause, break not required
case 2:
  break; // break is required here
default: // default clause is required
  break; // break is required here, in case a future
         // modification turns this into a case clause
}