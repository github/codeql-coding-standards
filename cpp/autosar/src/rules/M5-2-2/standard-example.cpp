class B {
  ...
};
class D : public virtual B {
  ...
};
D d;
B *pB = &d;
D *pD = static_cast<D *>(pB);   // Non-compliant - undefined behaviour
D *pD2 = dynamic_cast<D *>(pB); // Compliant, but pD2 may be NULL
D &D3 = dynamic_cast<D &>(*pB); // Compliant, but may throw an exception