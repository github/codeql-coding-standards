switch(int16)
{
case 0: 
  break;
case 1:
case 2:
  break;
        // Non-compliant – default clause is required.
}
enum Colours {RED, BLUE, GREEN} colour;
switch (colour)
{
case RED:
  break;
case GREEN:
  break;
        // Non-compliant – default clause is required.
}
switch(colour)
{
case RED:
  break;
case BLUE:
  break;
case GREEN:
  break;
        // Compliant – exception allows no default in this case
}