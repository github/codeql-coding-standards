#include <stddef.h>

// placement new
void *operator new(size_t _Size, void *_Where) {
  // ...
}

// ---

class ClassA {
public:
  int x, y;
};

void test_array_of_class(bool do_array_delete) {
  ClassA *mc = new ClassA;
  ClassA *mc_array = new ClassA[1024];

  if (do_array_delete) {
    delete[] mc;       // NON_COMPLIANT
    delete[] mc_array; // COMPLIANT
  } else {
    delete mc;       // COMPLIANT
    delete mc_array; // NON_COMPLIANT
  }
}

void test_char_array(bool do_array_delete) {
  char *c_array = new char[32];
  char *c_array_ptr_2 = c_array;

  if (do_array_delete) {
    delete[] c_array_ptr_2; // COMPLIANT
  } else {
    delete c_array_ptr_2; // NON_COMPLIANT
  }
}

void test_single_array_item(bool do_array_delete) {
  char *c_ptr_array[10] = {0};
  c_ptr_array[5] = new char;

  if (do_array_delete) {
    delete[] c_ptr_array[5]; // NON_COMPLIANT[FALSE_NEGATIVE]
  } else {
    delete c_ptr_array[5]; // COMPLIANT
  }
}

ClassA *global_mc = 0;

void test_global(bool do_array_delete) {
  // alloc
  if (global_mc == 0) {
    global_mc = new ClassA;
  }

  // free
  if (global_mc != 0) {
    if (do_array_delete) {
      delete[] global_mc; // NON_COMPLIANT
    } else {
      delete global_mc; // COMPLIANT
    }
  }
}

void test_cond_two(bool cond) {
  void *a = 0, *b = 0;

  if (cond) {
    a = new int;
    b = new int[10];
  }

  delete a;   // COMPLIANT
  delete[] a; // NON_COMPLIANT: new -> delete[]

  delete b;   // NON_COMPLIANT: new[] -> delete
  delete[] b; // COMPLIANT
}

void test_reassign() {
  void *ptr;

  ptr = new int;
  delete ptr; // COMPLIANT

  ptr = new int[10];
  delete[] ptr; // COMPLIANT
}

class ClassWithMembers {
public:
  ClassWithMembers() {
    a = new int;
    b = new int;
    c = new int;
  }

  ~ClassWithMembers() {
    delete a;   // COMPLIANT
    delete[] b; // NON_COMPLIANT: new -> delete[]
  }

private:
  int *a, *b, *c;
};

// ---

struct map_cell {
  char ch;
  int col;
};
map_cell *map;

static void map_init() { map = new map_cell[30 * 30]; }

static void test_map_shutdown() {
  delete map; // NON_COMPLIANT: new[] -> delete
  map = 0;
}

// ---

class TestNewArrayMember {
public:
  TestNewArrayMember() : data(new char[10]) {}

  ~TestNewArrayMember() {
    delete data; // NON_COMPLIANT: new[] -> delete
  }

  char *data;
};

class TestResizeArray {
public:
  TestResizeArray() { data = new char[10]; }

  void resize(int size) {
    if (size > 0) {
      delete[] data; // COMPLIANT
      data = new char[size];
    }
  }

  ~TestResizeArray() {
    delete data; // NON_COMPLIANT: new[] -> delete
  }

  char *data;
};

// ---

int *z;

void test_multiple_local_and_global(bool cond) {
  int *x, *y;

  x = new int();
  delete x; // COMPLIANT

  if (cond) {
    y = new int();
    z = new int();
  }

  // ...

  if (cond) {
    delete y; // COMPLIANT
    delete z; // COMPLIANT
  }
}

class MyPointer13 {
public:
  MyPointer13(char *_pointer) : pointer(_pointer) {}

  char *
  getPointer() // note: this should not be considered an allocation function
  {
    return pointer;
  }

private:
  char *pointer;
};

void test_delete_member() {
  MyPointer13 myPointer(new char[100]);

  delete myPointer.getPointer(); // COMPLIANT
}