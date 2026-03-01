/**
 * Provides models of functions in <memory> that deals with uninitialized memory.
 */

import cpp

abstract class UninitializedMemoryManagementFunction extends Function {
  UninitializedMemoryManagementFunction() {
    this.getADeclarationLocation().getFile().getShortName() = "memory"
  }
}

class UninitializedCopyFunction extends UninitializedMemoryManagementFunction {
  UninitializedCopyFunction() { this.hasQualifiedName("std", "uninitialized_copy") }
}

class UninitializedCopyNFunction extends UninitializedMemoryManagementFunction {
  UninitializedCopyNFunction() { this.hasQualifiedName("std", "uninitialized_copy_n") }
}

class UninitializedDefaultConstructFunction extends UninitializedMemoryManagementFunction {
  UninitializedDefaultConstructFunction() {
    this.hasQualifiedName("std", "uninitialized_default_construct")
  }
}

class UninitializedDefaultConstructNFunction extends UninitializedMemoryManagementFunction {
  UninitializedDefaultConstructNFunction() {
    this.hasQualifiedName("std", "uninitialized_default_construct_n")
  }
}

class UninitializedValueConstructFunction extends UninitializedMemoryManagementFunction {
  UninitializedValueConstructFunction() {
    this.hasQualifiedName("std", "uninitialized_value_construct")
  }
}

class UninitializedValueConstructNFunction extends UninitializedMemoryManagementFunction {
  UninitializedValueConstructNFunction() {
    this.hasQualifiedName("std", "uninitialized_value_construct_n")
  }
}

class UninitializedMoveFunction extends UninitializedMemoryManagementFunction {
  UninitializedMoveFunction() { this.hasQualifiedName("std", "uninitialized_move") }
}

class UninitializedMoveNFunction extends UninitializedMemoryManagementFunction {
  UninitializedMoveNFunction() { this.hasQualifiedName("std", "uninitialized_move_n") }
}

class UninitializedFillFunction extends UninitializedMemoryManagementFunction {
  UninitializedFillFunction() { this.hasQualifiedName("std", "uninitialized_fill") }
}

class UninitializedFillNFunction extends UninitializedMemoryManagementFunction {
  UninitializedFillNFunction() { this.hasQualifiedName("std", "uninitialized_fill_n") }
}

class DestroyFunction extends UninitializedMemoryManagementFunction {
  DestroyFunction() { this.hasQualifiedName("std", "destroy") }
}

class DestroyNFunction extends UninitializedMemoryManagementFunction {
  DestroyNFunction() { this.hasQualifiedName("std", "destroy_n") }
}

class DestroyAtFunction extends UninitializedMemoryManagementFunction {
  DestroyAtFunction() { this.hasQualifiedName("std", "destroy_at") }
}

class LaunderFunction extends UninitializedMemoryManagementFunction {
  LaunderFunction() { this.hasQualifiedName("std", "launder") }
}
