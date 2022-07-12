class IncompleteClass;
class CompleteClass {};

class DerivedCompleteClass : public CompleteClass {};

void test_cast_to_incomplete_type() {
  IncompleteClass *incompleteClass;
  void *ptr;

  incompleteClass = static_cast<IncompleteClass *>(ptr);      // NON_COMPLIANT
  incompleteClass = reinterpret_cast<IncompleteClass *>(ptr); // NON_COMPLIANT
  incompleteClass = (IncompleteClass *)ptr;                   // NON_COMPLIANT
}

void test_cast_to_complete_type() {
  DerivedCompleteClass completeClass;
  CompleteClass *ptr;

  ptr = static_cast<CompleteClass *>(&completeClass); // COMPLIANT
  ptr = (CompleteClass *)&completeClass;              // COMPLIANT
}