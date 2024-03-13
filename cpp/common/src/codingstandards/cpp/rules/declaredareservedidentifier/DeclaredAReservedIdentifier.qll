/**
 * Provides a library which includes a `problems` predicate for reporting declarations of reserved identifiers.
 */

import cpp
import codingstandards.cpp.CKeywords
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Linkage
import codingstandards.cpp.Macro
import codingstandards.cpp.StandardLibraryNames

abstract class DeclaredAReservedIdentifierSharedQuery extends Query { }

Query getQuery() { result instanceof DeclaredAReservedIdentifierSharedQuery }

newtype Scope =
  FileScope() or
  BlockScope() or
  FunctionScope() or
  MacroScope()

/**
 * A C name space according to C11 6.2.3, not to be confused with a C++ namespace.
 */
newtype TCNameSpace =
  LabelNameSpace() or
  TagNameSpace() or
  MemberNameSpace() or
  OrdinaryNameSpace() or
  // Create a "fake" name space for macro names
  MacroNameSpace()

class CNameSpace extends TCNameSpace {
  string toString() {
    this = LabelNameSpace() and result = "label"
    or
    this = TagNameSpace() and result = "tag"
    or
    this = MemberNameSpace() and result = "member"
    or
    this = OrdinaryNameSpace() and result = "ordinary"
    or
    this = MacroNameSpace() and result = "macro"
  }
}

string getDeclDescription(Declaration d) {
  d instanceof Function and result = "Function"
  or
  d instanceof Parameter and result = "Parameter"
  or
  d instanceof LocalVariable and result = "Local variable"
  or
  d instanceof MemberVariable and result = "Member variable"
  or
  d instanceof GlobalVariable and result = "Global variable"
  or
  d instanceof UserType and result = "Type"
  or
  d instanceof EnumConstant and result = "Enum constant"
}

/**
 * Whether a C declaration is considered to be at file scope.
 */
predicate isFileScope(Declaration d) {
  d.getFile().compiledAsC() and
  // Not inside a block - if the declaration is part of a DeclStmt, it is also part of a function
  // and therefore enclosed in at least one block
  not exists(DeclStmt ds | ds.getADeclaration() = d) and
  // Not inside a parameter list
  not d instanceof Parameter
}

/**
 * The given C program element defines the `identifierName` in the given `Scope` and `CNameSpace`.
 */
predicate isCIdentifier(
  Element e, string identifierName, Scope scope, CNameSpace cNameSpace, string identifierDescription
) {
  // This only makes sense on C compiled files
  e.getFile().compiledAsC() and
  (
    // An identifier can denote an object; a function; a tag or a member of a structure, union, or
    // enumeration; a typedef name; a label name; a macro name; or a macro parameter
    e.(Declaration).hasName(identifierName) and
    // Exclude any compiler generated identifiers
    not e.(Variable).isCompilerGenerated() and
    not e.(Function).isCompilerGenerated() and
    // Exclude local variables generated by the compiler (but not marked as such by our extractor)
    not e.(LocalScopeVariable).hasName(["__func__", "__PRETTY_FUNCTION__", "__FUNCTION__"]) and
    // Exclude special "macro"
    (
      if isFileScope(e)
      then
        // technically ignoring the function prototype scope, but we don't care for this use case
        scope = FileScope()
      else scope = BlockScope()
    ) and
    (
      if e instanceof UserType
      then
        if e instanceof TypedefType
        then
          // Typedef types are in the ordinary namespace
          cNameSpace = OrdinaryNameSpace()
        else
          // Other user-defined types are in the tag namespace
          cNameSpace = TagNameSpace()
      else
        if (e instanceof MemberVariable or e instanceof MemberFunction)
        then cNameSpace = MemberNameSpace()
        else cNameSpace = OrdinaryNameSpace()
    ) and
    (
      if exists(getDeclDescription(e))
      then identifierDescription = getDeclDescription(e)
      else identifierDescription = "Identifier"
    )
    or
    e.(LabelStmt).getName() = identifierName and
    scope = FunctionScope() and
    cNameSpace = LabelNameSpace() and
    identifierDescription = "Label"
    or
    e.(Macro).hasName(identifierName) and
    scope = MacroScope() and
    cNameSpace = MacroNameSpace() and
    identifierDescription = "Macro"
    or
    e.(FunctionLikeMacro).getAParameter() = identifierName and
    // Exclude __VA_ARGS__ as it is a special macro parameter
    not identifierName = "__VA_ARGS__..." and
    scope = MacroScope() and
    cNameSpace = MacroNameSpace() and
    identifierDescription = "Macro parameter"
  )
}

Macro getGeneratedFrom(Element e) {
  isCIdentifier(e, _, _, _, _) and
  exists(MacroInvocation mi |
    mi = result.getAnInvocation() and
    mi.getAGeneratedElement() = e and
    mi.getLocation().getStartColumn() = e.getLocation().getStartColumn() and
    not exists(MacroInvocation child |
      child.getParentInvocation() = mi and
      child.getAGeneratedElement() = e
    )
  )
}

module TargetedCLibrary = CStandardLibrary::C11;

query predicate problems(Element m, string message) {
  not isExcluded(m, getQuery()) and
  exists(
    string name, Scope scope, CNameSpace cNameSpace, string reason, string identifierDescription
  |
    isCIdentifier(m, name, scope, cNameSpace, identifierDescription) and
    // Exclude cases generated from library macros, because the user does not control them
    not getGeneratedFrom(m) instanceof LibraryMacro and
    message = identifierDescription + " '" + name + "' " + reason + "."
  |
    // C11 7.1.3/1
    //  > All identifiers that begin with an underscore and either an uppercase letter or another
    //  > underscore are always reserved for any use.
    name.regexpMatch("__.*") and
    // Exclude this macro which is intended to be implemented by the user
    not name = "__STDC_WANT_LIB_EXT1__" and
    reason = "declares a reserved name beginning with __"
    or
    name.regexpMatch("_[A-Z].*") and
    reason = "declares a reserved name beginning _ followed by an uppercase letter"
    or
    //  > All identifiers that begin with an underscore are always reserved for use as identifiers
    //  > with file scope in both the ordinary and tag name spaces.
    name.regexpMatch("_([^A-Z_].*)?") and
    scope = FileScope() and
    cNameSpace = [OrdinaryNameSpace().(TCNameSpace), TagNameSpace()] and
    reason =
      "declares a name beginning with _ which is reserved in the " + cNameSpace + " name space"
    or
    name.regexpMatch("_([^A-Z_].*)?") and
    scope = MacroScope() and
    cNameSpace = MacroNameSpace() and
    reason = "declares a name beginning with _ which is reserved in the ordinary and tag namespaces"
    or
    // > Each macro name in any of the following subclauses (including the future library
    // > directions) is reserved for use as specified if any of its associated headers is included;
    // > unless explicitly stated otherwise (see 7.1.4).
    exists(string header |
      TargetedCLibrary::hasMacroName(header, name, _) and
      // The relevant header is included directly or transitively by the file
      m.getFile().getAnIncludedFile*().getBaseName() = header and
      reason =
        "declares a name reserved for a macro from the " + TargetedCLibrary::getName() +
          " standard library header '" + header + "'"
    )
    or
    // > All identifiers with external linkage in any of the following subclauses (including the
    // > future library directions) and errno are always reserved for use as identifiers with
    // > external linkage.184
    exists(string header |
      TargetedCLibrary::hasObjectName(header, _, name, _, "external")
      or
      TargetedCLibrary::hasFunctionName(header, _, "", name, _, _, "external")
      or
      // > 184. The list of reserved identifiers with external linkage includes math_errhandling, setjmp,
      // > va_copy, and va_end.
      name = "errno" and
      header = "errno.h"
      or
      name = "math_errhandling" and
      header = "math.h"
      or
      name = "setjmp" and
      header = "setjmp.h"
      or
      name = "va_copy" and
      header = "stdarg.h"
      or
      name = "va_end" and
      header = "stdarg.h"
    |
      hasExternalLinkage(m) and
      reason =
        "declares a name which is reserved for external linkage from the " +
          TargetedCLibrary::getName() + " standard library header '" + header + "'"
    )
    or
    // > Each identifier with file scope listed in any of the following subclauses (including the
    // > future library directions) is reserved for use as a macro name and as an identifier with
    // > file scope in the same name space if any of its associated headers is included
    //
    // Note: these cases are typically already rejected by the compiler, which prohibits redeclaration
    //       of existing symbols. The macro cases are expected to work, though.
    exists(string header |
      TargetedCLibrary::hasObjectName(header, _, name, _, _) and
      (cNameSpace = OrdinaryNameSpace() or cNameSpace = MacroNameSpace())
      or
      TargetedCLibrary::hasFunctionName(header, _, "", name, _, _, _) and
      (cNameSpace = OrdinaryNameSpace() or cNameSpace = MacroNameSpace())
      or
      exists(string typeName |
        TargetedCLibrary::hasTypeName(header, _, typeName) and
        // Strip struct/union/enum prefix
        name = typeName.regexpReplaceAll("^(struct|union|enum) ", "")
      |
        (
          if typeName.regexpMatch("^(struct|union|enum) ")
          then
            // struct, union and enum types are in the tag namespace
            cNameSpace = TagNameSpace()
          else
            // typedef and therefore part of the ordinary namespace
            cNameSpace = OrdinaryNameSpace()
        )
        or
        cNameSpace = MacroNameSpace()
      )
      or
      exists(string declaringType, Class c |
        TargetedCLibrary::hasMemberVariableName(header, _, declaringType, name, _)
      |
        // Each declaring type has its own namespace, so check that it's declared in the same
        cNameSpace = MemberNameSpace() and
        c.getAMember() = m and
        c.getSimpleName() = declaringType
        or
        cNameSpace = MacroNameSpace()
      )
    |
      (
        scope = FileScope()
        or
        scope = MacroScope()
      ) and
      // The relevant header is included directly or transitively by the file
      m.getFile().getAnIncludedFile*().getBaseName() = header and
      reason =
        "declares a reserved name from the " + TargetedCLibrary::getName() +
          " standard library header '" + header +
          "' which is included directly or indirectly in this translation unit"
    )
    or
    // C11 6.4.1/2
    Keywords::isKeyword(name) and
    reason = "declares a reserved name which is a C11 keyword"
  )
}
