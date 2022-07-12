#define M(A) printf ( #A )
void main()
{
  M(
#ifdef SW
   "Message 1"
#else
   "Message 2"
#endif
  ); 
}