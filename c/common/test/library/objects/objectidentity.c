#include "threads.h"
// Basic static storage duration
int g_statstg1;
extern int g_statstg2;
static int g_statstg3;

// Basic automatic storage duration
void f1(int p_autostg1) { int l_autostg2; }

// Block identifiers with static storage duration
void f2(void) {
  extern int l_statstg1;
  static int l_statstg2;
}

// Thread storage duration
_Thread_local g_thrdstg1;
extern _Thread_local g_thrdstg2;
static _Thread_local g_thrdstg3;
void f3() {
  extern _Thread_local l_statstg3;
  static _Thread_local l_statstg4;
}

// Struct declarations do not allocate storage, and do not have a storage
// duration.
struct s {
  int m;
};

// Enums and enum constants are not variables and have no linkage.
enum e { E1 };

// Various literals:
struct s *g_statstg4 = &(struct s){0};
char *g_statstg5 = "hello";
void f4(void) {
  1;
  "hello";
  (struct s){1};
}