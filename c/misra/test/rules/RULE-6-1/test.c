typedef unsigned int UINT_16;

enum Color { R, G, B };

struct SampleStruct {
  unsigned int b1 : 2; // COMPILANT - explicitly unsigned (example in the doc)
  signed int b2 : 2;   // COMPILANT - explicitly signed
  int b3 : 2; // NON_COMPLIANT - plain int not permitted (example in the doc)
  UINT_16 b4 : 2; // COMPLIANT - typedef designating unsigned int (example in
                  // the doc)
  signed long b5 : 2; // NON_COMPLIANT - even if long and int are the same size
                      // (example in the doc)
  signed char b6 : 2; // NON_COMPILANT - cannot declare bit field for char
  enum Color b7 : 3;  // NON_COMPILANT - cannot declare bit field for enum
} sample_struct;