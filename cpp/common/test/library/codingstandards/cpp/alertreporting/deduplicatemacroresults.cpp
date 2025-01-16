typedef struct {
} findme;

findme g1; // baseline report, not in a macro

#define SOMETIMES_HAS_RESULTS1(type, name) type name  // ignore
#define SOMETIMES_HAS_RESULTS2(type, name) type name; // ignore

SOMETIMES_HAS_RESULTS1(int, g2);    // ignore
SOMETIMES_HAS_RESULTS1(findme, g3); // RESULT

SOMETIMES_HAS_RESULTS2(int, g4)    // ignore
SOMETIMES_HAS_RESULTS2(findme, g5) // RESULT

#define ALWAYS_HAS_SAME_RESULT() extern findme g6; // RESULT

ALWAYS_HAS_SAME_RESULT() // ignore
ALWAYS_HAS_SAME_RESULT() // ignore
ALWAYS_HAS_SAME_RESULT() // ignore

#define ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(name) extern findme name; // RESULT

ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g7) // ignore
ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g8) // ignore
ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g9) // ignore
ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g9) // ignore
ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g9) // ignore

#define INNER_SOMETIMES_HAS_RESULTS(type, name) type name; // ignore
#define OUTER_ALWAYS_HAS_SAME_RESULT()                                         \
  extern INNER_SOMETIMES_HAS_RESULTS(findme, g10); // RESULT

OUTER_ALWAYS_HAS_SAME_RESULT() // ignore
OUTER_ALWAYS_HAS_SAME_RESULT() // ignore

// 'name ## suffix' required to work around extractor bug.
#define OUTER_ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(name)                       \
  INNER_SOMETIMES_HAS_RESULTS(findme, name##suffix); // RESULT

OUTER_ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g11) // ignore
OUTER_ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g12) // ignore

#define OUTER_OUTER_ALWAYS_HAS_SAME_RESULT()                                   \
  OUTER_ALWAYS_HAS_SAME_RESULT();    // ignore
OUTER_OUTER_ALWAYS_HAS_SAME_RESULT() // ignore
OUTER_OUTER_ALWAYS_HAS_SAME_RESULT() // ignore

// 'name ## suffix' required to work around extractor bug.
#define OUTER_OUTER_ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(name)                 \
  OUTER_ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(name##suffix); // ignore

OUTER_OUTER_ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g13) // ignore
OUTER_OUTER_ALWAYS_HAS_RESULT_VARIED_DESCRIPTION(g14) // ignore