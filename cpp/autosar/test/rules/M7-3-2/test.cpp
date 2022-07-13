int main() // COMPLIANT
{}

namespace {
void main() // NON_COMPLIANT
{}
} // namespace

namespace ns {
int main() // NON_COMPLIANT
{}
} // namespace ns

class Class {
  int main() // NON_COMPLIANT
  {}
};

struct Struct {
  int main() // NON_COMPLIANT
  {}
};