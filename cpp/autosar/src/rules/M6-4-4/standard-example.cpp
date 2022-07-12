switch(x)
{
case 1:     // Compliant
  if( ... )
  {
    case 2: //Non Compliant
    DoIt( );
  }
  break;
default:
  break; 
}