class Base
{
public:
   virtual void g1 ( int32_t a = 0 ); 
   virtual void g2 ( int32_t a = 0 );
   virtual void b1 ( int32_t a = 0 );
};
class Derived : public Base
{
public:
   virtual void g1 ( int32_t a = 0 );   // Compliant - same default used
   virtual void g2 ( int32_t a );       // Compliant -
                                        //          no default specified
   virtual void b1 ( int32_t a = 10 );  // Non-compliant - different value
};
void f( Derived& d )
{
   Base& b = d;
   b.g1 ( );          // Will use default of 0
   d.g1 ( );          // Will use default of 0
   b.g2 ( );          // Will use default of 0
   d.g2 ( 0 );        // No default value available to use
   b.b1 ( );          // Will use default of 0
   d.b1 ( );          // Will use default of 10
}