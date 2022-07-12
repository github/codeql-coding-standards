// classes used for exception handling
class B {};
class D : public B {};
try {
  // ... }
  catch (D &d) // Compliant – Derived class caught before base class
  {
    // ...
  }
  catch (B &b) // Compliant – Base class caught after derived class
  {
    // ...
  }

  // Using the classes from above ...
  try {
    // ...
  } catch (B &b) // Non-compliant – will catch derived classes as well
  {
    // ...
  } catch (D &d)
  // Non-compliant – Derived class will be caught above
  {
    // Any code here will be unreachable,
    // breaking Rule 0–1–1
  }
