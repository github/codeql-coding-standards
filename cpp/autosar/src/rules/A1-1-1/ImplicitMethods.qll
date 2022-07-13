/**
 * A module for representing implicit (compiler-generated) class methods.
 */

import cpp

CopyAssignmentOperator getCopyAssignmentOperator(Class c) {
  exists(CopyAssignmentOperator cao | cao.getDeclaringType() = c | result = cao)
}

CopyConstructor getCopyConstructor(Class c) {
  exists(CopyConstructor cc | cc.getDeclaringType() = c | result = cc)
}

predicate hasImplicitCopyConstructor(Class c) {
  getCopyConstructor(c).isCompilerGenerated()
  or
  not exists(getCopyConstructor(c)) and
  not (
    exists(MoveConstructor mc | mc.getDeclaringType() = c | mc.isCompilerGenerated())
    or
    exists(MoveAssignmentOperator mao | mao.getDeclaringType() = c | mao.isCompilerGenerated())
  )
}

predicate hasImplicitCopyAssignmentOperator(Class c) {
  getCopyAssignmentOperator(c).isCompilerGenerated()
}
