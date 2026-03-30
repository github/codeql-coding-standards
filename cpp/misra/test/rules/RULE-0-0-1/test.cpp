void f1() {
  int l1 = 0; // COMPLIANT -- reachable block
}

void f2() {
  return;
  int l1 = 0; // NON-COMPLIANT
}

void f3(int p1) {
  // Reachable empty
  if (p1) {
    int l1 = 0; // COMPLIANT
  } else {
    int l2 = 0; // COMPLIANT
  }

  if (false) {
    int l3 = 0; // NON-COMPLIANT
  } else {
    int l4 = 0; // COMPLIANT
  }

  if (true) {
    int l5 = 0; // COMPLIANT
  } else {
    int l6 = 0; // NON-COMPLIANT
  }

  // Rule text states that both operands of && are considered reachable, and
  // that blocks linked from edges of conditions are considered reachable if the
  // condition is not a constant expression.
  if (false && p1) {
    int l7 = 0; // COMPLIANT
  } else {
    int l8 = 0; // COMPLIANT
  }
}

void f4(int p1) {
  if (p1) {
    return;
    int l1 = 0; // NON-COMPLIANT
  }

  int l2 = 0; // COMPLIANT

  if (p1) {
    int l3 = 0; // COMPLIANT
  } else {
    return;
    int l4 = 0; // NON-COMPLIANT
  }

  int l5 = 0; // COMPLIANT

  if (p1) {
    return;
  } else {
    return;
  }

  int l6 = 0; // NON-COMPLIANT
}

void f5() {
  const bool b1 = true;
  if (b1) {
    int l1 = 0; // COMPLIANT
  } else {
    int l2 = 0; // NON-COMPLIANT
  }

  constexpr bool b2 = false;
  if (b2) {
    int l3 = 0; // NON-COMPLIANT
  } else {
    int l4 = 0; // COMPLIANT
  }

  if constexpr (b1) {
    int l5 = 0; // COMPLIANT -- constexpr excluded from rule
  } else {
    int l6 = 0; // COMPLIANT -- constexpr excluded from rule
  }
}

template <bool B> void f6() {
  if (B) {
    int l1 = 0; // NON-COMPLIANT -- reachability depends on template parameter
                // value, a constant
  } else {
    int l2 = 0; // NON-COMPLIANT -- reachability depends on template parameter
                // value, a constant
  }

  if constexpr (B) {
    int l3 = 0; // COMPLIANT -- constexpr excluded from rule
  } else {
    int l4 = 0; // COMPLIANT -- constexpr excluded from rule
  }
}

void f7() {
  f6<true>();
  f6<false>();
}

void f8(int p1) {
  switch (p1) {
  case 1: {
    int l1 = 0; // COMPLIANT
    break;
    int l2 = 0; // NON-COMPLIANT
  }
  case 2: {
    int l3 = 0; // COMPLIANT
    return;
    int l4 = 0; // NON-COMPLIANT
  }
  }

  int l5 = 0; // COMPLIANT

  switch (p1) {
  default: {
    return;
  }
  }

  int l6 = 0; // NON-COMPLIANT
}

void f9(int p1) {
  for (; false;) {
    int l1 = 0; // NON-COMPLIANT
  }

  for (; p1;) {
    int l2 = 0; // COMPLIANT
  }

  for (; true;) {
    int l3 = 0; // COMPLIANT
    break;
    int l4 = 0; // NON-COMPLIANT
  }

  // Rule text states that both operands of && are considered reachable, and
  // that blocks linked from edges of conditions are considered reachable if the
  // condition is not a constant expression.
  for (; false && p1;) {
    int l5 = 0; // COMPLIANT
  }

  for (; true;)
    ;
  int l6 = 0; // NON-COMPLIANT
}

void f10(int p1) {
  while (false) {
    int l1 = 0; // NON-COMPLIANT
  }

  while (p1) {
    int l2 = 0; // COMPLIANT
  }

  while (true) {
    int l3 = 0; // COMPLIANT
    break;
    int l4 = 0; // NON-COMPLIANT
  }

  // Rule text states that both operands of && are considered reachable, and
  // that blocks linked from edges of conditions are considered reachable if the
  // condition is not a constant expression.
  while (false && p1) {
    int l5 = 0; // COMPLIANT
  }

  while (true)
    ;
  int l6 = 0; // NON-COMPLIANT
}

[[noreturn]] void noret();

void f11() {
  noret();
  int l1 = 0; // NON-COMPLIANT
}

class Base {};
class Derived : public Base {};
void f_except();
void f_no_except() noexcept;

void f12() {
  try {
    f_except();
  } catch (const Derived &d) {
    int l1 = 0; // COMPLIANT
  } catch (const Base &b) {
    int l2 = 0; // COMPLIANT
  } catch (...) {
    int l1 = 0; // COMPLIANT
  }

  try {
    f_no_except();
  } catch (const Derived &d) {
    int l1 = 0; // NON-COMPLIANT
  } catch (const Base &b) {
    int l2 = 0; // NON-COMPLIANT
  } catch (...) {
    int l2 = 0; // NON-COMPLIANT
  }

  try {
    f_except();
  } catch (const Base &b) {
    int l1 = 0; // COMPLIANT
  } catch (const Derived &b) {
    int l2 = 0; // NON-COMPLIANT
  }

  try {
    f_except();
  } catch (const Derived &d) {
    int l1 = 0; // COMPLIANT
  } catch (const Derived &b) {
    int l2 = 0; // NON-COMPLIANT -- duplicate
  } catch (Derived &b) {
    int l2 = 0; // NON-COMPLIANT -- masked by previous catch
  } catch (Derived b) {
    int l2 = 0; // NON-COMPLIANT -- masked by previous catch
  }

  try {
    f_except();
  } catch (const Base &b) {
    try {
      f_no_except(); // COMPLIANT
    } catch (...) {
      int l1 = 0; // NON-COMPLIANT
    }
  }
}