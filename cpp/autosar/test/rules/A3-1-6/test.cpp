class A {
public:
  void setX(int px) { x = px; } // COMPLIANT
  void setY(int py);
  int getX();

private:
  int x;
  int y;
};

void A::setY(int py) { // NON_COMPLIANT
  y = py;
}

int A::getX() { // NON_COMPLIANT
  return x;
}

class B {
public:
  void setX(int px) { x = px; } // COMPLIANT
  void setY(int py);

private:
  int x;
  int y;
};

void B::setY(int py) { // COMPLIANT
  int i;
  if (i > 0) {
    y = py;
  } else {
    y = -py;
  }
}

class C {
public:
  void setX(int px) { x = px; } // COMPLIANT
  void setY(int py) {           // COMPLIANT
    bool b = false;
    if (b > 0) {
      b = true;
      y = py;
    }
    return;
  }

private:
  int x;
  int y;
};

class D {
public:
  void setX(int px) { x = px; } // COMPLIANT
  void setY(int py);

private:
  int x;
  int y;
};

void D::setY(int py) { // COMPLIANT
  int i;
  if (i > 0) {
    y = py;
  }
  return;
}

class E {
public:
  void setX(int px);
  void setY(int py);

private:
  int x;
  int y;
};

void E::setX(int px) { // NON_COMPLIANT
  x = px;
}
void E::setY(int py) { // NON_COMPLIANT
  y = py;
}

class F {
public:
  F() = default; // COMPLIANT
};

class G {
public:
  G(const G &rhs); // COMPLIANT - A constructor is not an accessor or mutator
                   // function
  ~G(); // COMPLIANT - A constructor is not an accessor or mutator function
private:
  int n;
};

G::G(const G &rhs) { this->n = rhs.n; }

G::~G() { this->n = 0; }
