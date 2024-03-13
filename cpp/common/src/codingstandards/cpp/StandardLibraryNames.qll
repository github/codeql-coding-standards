/**
 * A module for representing names from the C and C++ Standard Library.
 */

import cpp

/**
 * Holds if the given standard defines the given macro in the given namespace.
 */
extensible predicate libraryMacroModel(
  string standard, string header, string name, string parameters
);

/**
 * Holds if the given standard defines the given type in the given namespace.
 */
extensible predicate libraryTypeModel(string standard, string header, string namespace, string name);

/**
 * Holds if the given standard defines the object or value name in the given namespace.
 */
extensible predicate libraryObjectModel(
  string standard, string header, string namespace, string name, string type, string linkage
);

/**
 * Holds if the given standard defines the function name in the given namespace.
 */
extensible predicate libraryFunctionModel(
  string standard, string header, string namespace, string declaringType, string name,
  string return_signature, string parameter_signature, string linkage
);

/**
 * Holds if the given standard defines the given member variable in the given declaring type and namespace.
 */
extensible predicate libraryMemberVariableModel(
  string standard, string header, string namespace, string declaringType, string name, string type
);

signature module StandardLibrary {
  string getName();

  default predicate hasMacroName(string header, string name, string parameters) {
    libraryMacroModel(getName(), header, name, parameters)
  }

  default predicate hasTypeName(string header, string namespace, string name) {
    libraryTypeModel(getName(), header, namespace, name)
  }

  default predicate hasObjectName(
    string header, string namespace, string name, string type, string linkage
  ) {
    libraryObjectModel(getName(), header, namespace, name, type, linkage)
  }

  default predicate hasFunctionName(
    string header, string namespace, string declaringType, string name, string return_signature,
    string parameter_signature, string linkage
  ) {
    libraryFunctionModel(getName(), header, namespace, declaringType, name, return_signature,
      parameter_signature, linkage)
  }

  default predicate hasMemberVariableName(
    string header, string namespace, string declaringType, string name, string type
  ) {
    libraryMemberVariableModel(getName(), header, namespace, declaringType, name, type)
  }
}

module CStandardLibrary {
  module C99 implements StandardLibrary {
    string getName() { result = "C99" }
  }

  module C11 implements StandardLibrary {
    string getName() { result = "C11" }
  }
}

module CppStandardLibrary {
  module Cpp14 implements StandardLibrary {
    string getName() { result = "C++14" }
  }
}
