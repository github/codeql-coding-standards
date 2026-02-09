/**
 * @id c/cert/do-not-violate-in-line-linkage-constraints
 * @name MSC40-C: Do not violate inline linkage constraints
 * @description Inlined external functions are prohibited by the language standard from defining
 *              modifiable static or thread storage objects, or referencing identifiers with
 *              internal linkage.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc40-c
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Linkage

/*
 * This is C specific, because in C++ all extern function definitions must be identical.
 * Only in C is it permitted for an extern function to be defined in multiple translation
 * units with different implementations, when using the inline keyword.
 */

from Element accessOrDecl, Variable v, Function f, string message
where
  not isExcluded(f, ContractsPackage::doNotViolateInLineLinkageConstraintsQuery()) and
  f.isInline() and
  hasExternalLinkage(f) and
  // Pre-emptively exclude compiler generated functions
  not f.isCompilerGenerated() and
  // This rule does not apply to C++, but exclude C++ specific cases anyway
  not f instanceof MemberFunction and
  not f.isFromUninstantiatedTemplate(_) and
  (
    // There exists a modifiable local variable which is static or thread local
    exists(LocalVariable lsv, string storageModifier |
      lsv.isStatic() and storageModifier = "Static"
      or
      lsv.isThreadLocal() and storageModifier = "Thread-local"
    |
      lsv.getFunction() = f and
      not lsv.isConst() and
      accessOrDecl = lsv and
      message = storageModifier + " local variable $@ declared" and
      v = lsv
    )
    or
    // References an identifier with internal linkage
    exists(GlobalOrNamespaceVariable gv |
      accessOrDecl = v.getAnAccess() and
      accessOrDecl.(VariableAccess).getEnclosingFunction() = f and
      hasInternalLinkage(v) and
      message = "Identifier $@ with internal linkage referenced" and
      v = gv
    )
  )
select accessOrDecl, message + " in the extern inlined function $@.", v, v.getName(), f,
  f.getQualifiedName()
