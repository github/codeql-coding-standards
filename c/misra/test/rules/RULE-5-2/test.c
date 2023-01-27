extern int
    iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjyszmcsylyohvqaosjbqyyA; // NON_COMPLIANT
                                                                      // -
                                                                      // length
                                                                      // 64

static int
    iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjyszmcsylyohvqaosjbqyyB; // NON_COMPLIANT
                                                                      // -
                                                                      // length
                                                                      // 64

void f() {
  int iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjyszmcsylyohvqaosjbqyyC; // COMPLIANT
                                                                        // -
                                                                        // length
                                                                        // 64
                                                                        // but
                                                                        // diff
                                                                        // scope
}

static int
    iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjy_C; // COMPLIANT length <63
static int
    iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjy_D; // COMPLIANT length <63

#define iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjyszmcsylyohvqaosjbqyyA // COMPLIANT
                                                                         // -
                                                                         // this
                                                                         // rule
                                                                         // does
                                                                         // not
                                                                         // consider
                                                                         // macros
extern int
    iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjyszmcsylyohvqaosjbqyyA; // COMPLIANT
                                                                      // - this
                                                                      // rule
                                                                      // does
                                                                      // not
                                                                      // consider
                                                                      // when
                                                                      // both
                                                                      // identifiers
                                                                      // are
                                                                      // external