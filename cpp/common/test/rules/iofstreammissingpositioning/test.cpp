#include <fstream>
#include <sstream>

std::string str("output:");

// local variable
void test_local() {
  std::fstream f_local("file");
  f_local << "some data"; // COMPLIANT
  f_local >> str;         // NON_COMPLIANT
  f_local << "more data"; // NON_COMPLIANT
  f_local.seekp(0);
  f_local >> str; // COMPLIANT
};
void test_local2() {
  std::fstream f_local("file");
  f_local << "some data"; // COMPLIANT
  f_local << "more data"; // COMPLIANT
  f_local >> str;         // NON_COMPLIANT
  f_local >> str;         // COMPLIANT
};

// two different streams
void test_2streams() {
  std::fstream f_s1("file1");
  std::fstream f_s2("file2");

  f_s1 << "some data";
  f_s2 >> str; // COMPLIANT
  f_s1.seekp(0);
  f_s2 << "some data"; // NON_COMPLIANT
  f_s1 >> str;         // COMPLIANT
}

// access via alias
void test_alias() {
  std::fstream f1("file1");
  std::fstream &alias_f1 = f1;

  f1 << "some data";
  alias_f1 >> str;   // NON_COMPLIANT
  f1 << "more data"; // NON_COMPLIANT
}

// class member variable
class Test_ClassMember {
public:
  std::fstream f_member;
  Test_ClassMember() {
    f_member.open("file");
    f_member >> str;
    f_member << "some data"; // NON_COMPLIANT
    f_member.seekg(0);
    f_member >> str; // COMPLIANT
  }
};

// intraprocedural global
std::fstream f_global;
void test_global() {
  f_global.open("file");
  f_global >> str;
  f_global << "some data"; // NON_COMPLIANT
  f_global.seekg(0);
  f_global >> str; // COMPLIANT
}

// interprocedural with global variable
std::fstream f_global_inter;
void read() {
  f_global_inter >> str; // COMPLIANT
}
void write() {
  f_global_inter << "some data"; // NON_COMPLIANT[FALSE_NEGATIVE]
}
void test_interprocedural() {
  f_global_inter.open("file");
  read();
  write();
  f_global_inter.seekg(0);
  read();
}

// different stream type
void test_sstream() {
  std::stringstream sstream;
  sstream << "some data";
  sstream >> str; // COMPLIANT
}

void test_branch(int rand) {
  std::fstream f_branch("file");
  f_branch << "some data";
  if (rand > 10) {
    f_branch.seekp(0);
  } else {
    f_branch.seekp(0);
  }
  f_branch >> str; // COMPLIANT
  if (rand > 10) {
    f_branch.seekp(0);
  }
  f_branch << "more data"; // NON_COMPLIANT
}
