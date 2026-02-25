import cpp
import codingstandards.cpp.Linkage
import codingstandards.cpp.Macro
import codingstandards.cpp.Unicode as Unicode

class ExternalIdentifiers extends InterestingIdentifiers {
  ExternalIdentifiers() {
    hasExternalLinkage(this) and
    getNamespace() instanceof GlobalNamespace
  }

  string getSignificantName() {
    //C99 states the first 31 characters of external identifiers are significant
    //C90 states the first 6 characters of external identifiers are significant and case is not required to be significant
    //C90 is not currently considered by this rule
    result = this.getName().prefix(31)
  }
}

//Identifiers that are candidates for checking uniqueness
class InterestingIdentifiers extends Declaration {
  InterestingIdentifiers() {
    not this.isFromTemplateInstantiation(_) and
    not this.isFromUninstantiatedTemplate(_) and
    not this instanceof TemplateParameter and
    not this.hasDeclaringType() and
    not this instanceof Operator and
    not this.hasName("main") and
    exists(this.getADeclarationLocation())
  }

  //this definition of significant relies on the number of significant characters for a macro name (C99)
  //this is used on macro name comparisons only
  //not necessarily against other types of identifiers
  string getSignificantNameComparedToMacro() { result = this.getName().prefix(63) }
}

//Declarations that omit type - C90 compiler assumes int
predicate isDeclaredImplicit(Declaration d) {
  d.hasSpecifier("implicit_int") and
  exists(Type t |
    (d.(Variable).getType() = t or d.(Function).getType() = t) and
    // Exclude "short" or "long", as opposed to "short int" or "long int".
    t instanceof IntType and
    // Exclude "signed" or "unsigned", as opposed to "signed int" or "unsigned int".
    not exists(IntegralType it | it = t | it.isExplicitlySigned() or it.isExplicitlyUnsigned())
  )
}

predicate isTemplateSpecialization(Declaration d) {
  d instanceof ClassTemplateInstantiation or
  d instanceof FunctionTemplateInstantiation or
  d instanceof FunctionTemplateSpecialization or
  d instanceof ClassTemplateSpecialization
}

private newtype TIdentifierIntroduction =
  TSomeIdentifierIntroduction(
    string ident, Location loc, IdentifierIntroductionImpl::IdentifierIntroductionBase element
  ) {
    ident = element.getAnIdent() and
    loc = element.getLocation()
  }

/**
 * An identifier introduced by some kind of declaration.
 *
 * This class should exclude declarations that have false names in the database, such as compiler
 * generated declarations, anonymous declarations, and more.
 *
 * Note that this class does not extend `Declaration` because there are many edge cases to which
 * declarations introduce which identifiers that require special handling, such as templates,
 * friends, and more.
 *
 * To get the name of the introduced identifier, use `getAnIdent()`. For implementation reasons,
 * some `IdentifierIntroduction`s may introduce multiple identifiers, such as `MacroIdentifier`
 * which introduces both the macro name and its parameter names, and therefore plural `getAnIdent()`
 * is used instead of singular `getIdent()`.
 */
class IdentifierIntroduction extends TIdentifierIntroduction {
  string getIdent() { this = TSomeIdentifierIntroduction(result, _, _) }

  Element getElement() { this = TSomeIdentifierIntroduction(_, _, result) }

  Location getLocation() { this = TSomeIdentifierIntroduction(_, result, _) }

  string toString() { result = getIdent() }

  /**
   * Holds if the introduced identifier contains a unicode character, which is in the database as a
   * unicode escape sequence.
   *
   * For example, an identifier containing the Greek small letter alpha, α, will be in the database
   * as the literal text "\u03B1" (backslash included literally).
   *
   * Attempting to unescape all identifiers for unicode characters is quite slow in CodeQL, so this
   * predicate exists to limit that expensive operation to only those identifiers which actually
   * contain unicode escape sequences.
   */
  predicate containsUnicode() { getIdent().matches("%\\\\u%") }

  /**
   * Provides the actual value of the introduced identifier, which may include unicode characters.
   *
   * The database stores unicode characters as literal escape sequences, such as "\u03B1" for the
   * Greek small letter alpha, α. This function will convert such escape sequences into the actual
   * unicode characters.
   *
   * This function is also optimized to only perform the unescaping operation if the identifier
   * actually contains unicode escape sequences, as determined by the `containsUnicode()` predicate.
   */
  string unescapeUnicode() {
    if pragma[only_bind_out](this).containsUnicode()
    then result = Unicode::unescapeUnicode(getIdent())
    else result = getIdent()
  }

  /**
   * Holds if the introduced identifier contains a codepoint which may not be NFC normalized.
   *
   * See UAX #15 of the unicode standard for more information
   *
   * The exact algorithm to detect NFC normalization is too complex to be worth implementing in
   * CodeQL, and there are currently no plans to add support for this in the CodeQL language itself.
   * However, the unicode standard does have an "NFC_Quick_Check" property which can be used to
   * quickly determine if a string is definitely normalized, definitely not normalized, or may not
   * be normalized. This member predicate exposes that information for approximate checking of
   * NFC normalization.
   */
  predicate hasNonNfcNormalizedCodepoint(int index, string noOrMaybe) {
    pragma[only_bind_out](this).containsUnicode() and
    Unicode::nonNfcNormalizedCodepoint(unescapeUnicode(), index, noOrMaybe)
  }

  /**
   * Holds if the introduced identifier contains a codepoint which is not allowed by UAX #44.
   *
   * See UAX #44 of the unicode standard for more information.
   */
  predicate hasNonUax44Codepoint(int index) {
    pragma[only_bind_out](this).containsUnicode() and
    Unicode::nonUax44IdentifierCodepoint(unescapeUnicode(), index)
  }

  predicate isFromMacro() {
    this.getElement() instanceof IdentifierIntroductionImpl::MacroIdentifier
  }

  predicate isLiteralSuffix() {
    this.getElement()
        .(IdentifierIntroductionImpl::FunctionDeclarationEntryIdentifier)
        .isLiteralSuffix()
  }

  Namespace getNamespace() {
    result =
      this.getElement().(IdentifierIntroductionImpl::IdentifierIntroductionBase).getNamespace()
  }
}

private module IdentifierIntroductionImpl {
  /**
   * An identifier introduced by some kind of declaration.
   *
   * This class should exclude declarations that have false names in the database, such as compiler
   * generated declarations, anonymous declarations, and more.
   *
   * Note that this class does not extend `Declaration` because there are many edge cases to which
   * declarations introduce which identifiers that require special handling, such as templates,
   * friends, and more.
   *
   * To get the name of the introduced identifier, use `getAnIdent()`. For implementation reasons,
   * some `IdentifierIntroduction`s may introduce multiple identifiers, such as `MacroIdentifier`
   * which introduces both the macro name and its parameter names, and therefore plural `getAnIdent()`
   * is used instead of singular `getIdent()`.
   */
  abstract class IdentifierIntroductionBase extends Element {
    IdentifierIntroductionBase() {
      not isTemplateSpecialization(this) and
      // Template instantiations do not introduce new identifiers.
      not this.isFromTemplateInstantiation(_)
    }

    /**
     * The name of an introduced identifier.
     *
     * This may have multiple results, for instance for a function-like macro which introduces both
     * the macro name and its parameter names.
     */
    abstract string getAnIdent();

    abstract Namespace getNamespace();
  }

  /**
   * An identifier introduced by an enum constant declaration.
   */
  class EnumConstantIdentifier extends IdentifierIntroductionBase, EnumConstant {
    override string getAnIdent() { result = this.getName() }

    override Namespace getNamespace() { result = this.(Declaration).getNamespace() }
  }

  /**
   * An identifier introduced by a friend declaration.
   *
   * This has to be treated specially. The member predicate `getName()` on a `FriendDecl` returns the
   * string "foo's friend", which is not an identifier in the program.
   *
   * The elements returned by the `getFriend()` member predicate often do not have a corresponding
   * `DeclarationEntry`, and therefore these element identifiers are not matched by the other classes
   * defined here that extend `IdentifierIntroductionBase`.
   *
   * Therefore, this class provides the identifiers of declarations with the friend specifier.
   */
  class FriendIdentifier extends IdentifierIntroductionBase, FriendDecl {
    FriendIdentifier() { not this.getFriend() instanceof Operator }

    override string getAnIdent() { result = this.getFriend().getName() }

    override Namespace getNamespace() { result = this.(Declaration).getNamespace() }
  }

  /**
   * An identifier introduced as a function name.
   *
   * Note that this class extends `FunctionDeclarationEntry` instead of `Function`, because a function
   * can have multiple locations, such as declarations and definitions. However, each
   * `FunctionDeclarationEntry` has only one location corresponding to that identifier.
   *
   * In the future we may revisit what counts as "introducing" a function identifier. In the current
   * implementation, forward declarations and implementations both have an `IdentifierIntroductionBase`,
   * which is probably not ideal long term. However, it is not clear which forward declarations or
   * definitions should be considered introductions, and this is made more complex by the fact that
   * parameter * names and template typenames may not match across these sites. A better
   * implementation requires answering these questions.
   */
  class FunctionDeclarationEntryIdentifier extends IdentifierIntroductionBase,
    FunctionDeclarationEntry
  {
    Function function;

    FunctionDeclarationEntryIdentifier() {
      function = this.getFunction() and
      not function instanceof Operator and
      // ConversionOperator is not a subclass of Operator
      not function instanceof ConversionOperator and
      // Constructors and destructors do not introduce new identifiers
      not function instanceof Constructor and
      not function instanceof Destructor and
      not function.isCompilerGenerated() and
      not isTemplateSpecialization(function)
    }

    /**
     * Whether this function is a user-defined literal suffix, such as `operator ""_foo`.
     */
    predicate isLiteralSuffix() { function.getName().matches("operator \"\"%") }

    override string getAnIdent() {
      // `operator ""_foo` functions are not considered operators in the database, but are functions
      // named 'operator ""_foo' in the database. This introduces the identifier "_foo".
      if isLiteralSuffix() then getName() = "operator \"\"" + result else result = getName()
    }

    override Namespace getNamespace() { result = function.getNamespace() }
  }

  /**
   * An identifier introduced as a type name: a class, struct, union, enum, typedef, etc.
   *
   * Note that this class extends `TypeDeclarationEntry` instead of `Type` or more specific classes
   * like `Class`, because a type can have multiple locations, such as declarations and definitions.
   * However, each `TypeDeclarationEntry` has only one location corresponding to that identifier.
   *
   * In the future we may revisit what counts as "introducing" a type identifier, between declarations
   * and definitions. See `FunctionDeclarationEntryIdentifier` for more information.
   *
   * Note that anonymous types must be excluded, as they have a name such as "(anonymous struct)",
   * which is not an identifier in the program.
   */
  class TypeDeclarationEntryIdentifier extends IdentifierIntroductionBase, TypeDeclarationEntry {
    Type type;

    TypeDeclarationEntryIdentifier() {
      type = this.getType() and
      not type.(Enum).isAnonymous() and
      not type.(Union).isAnonymous() and
      not type.(Struct).isAnonymous() and
      (
        // A template parameter may itself be a template (`template <template<typename> class T>`).
        // The inner template parameter `template<typename>` is anonymous and does not introduce an
        // identifier.
        not type.(TemplateParameter).isAnonymous()
        or
        // In the above case, the template template parameter `T` is incorrectly marked as anonymous
        // in the database. But it does introduce the identifier `T`, so it must not be excluded.
        type instanceof TemplateTemplateParameter
      ) and
      // Template classes are matched separately and require special handling.
      not type instanceof TemplateClass and
      // `TypeDeclarationEntry`s are the only `DeclarationEntry` that exists in the context of a
      // `FriendDecl`. These must be excluded here or to avoid duplicating the results of the
      // `FriendIdentifier` class.
      not exists(FriendDecl fd | fd.getFriend() = type) and
      not isTemplateSpecialization(type)
    }

    override string getAnIdent() { result = this.getName() }

    override Namespace getNamespace() { result = type.(Declaration).getNamespace() }
  }

  /**
   * An identifier introduced as a variable name.
   *
   * Note that this class extends `VariableDeclarationEntry` instead of `Variable`, because some
   * variables such as parameters and globals can have multiple locations, from different declarations
   * and definitions. However, each `VariableDeclarationEntry` has only one location corresponding to
   * that identifier.
   *
   * In the future we may revisit what counts as "introducing" a variable identifier, between declarations
   * and definitions. See `FunctionDeclarationEntryIdentifier` for more information.
   */
  class VariableDeclarationEntryIdentifier extends IdentifierIntroductionBase,
    VariableDeclarationEntry
  {
    Variable variable;

    VariableDeclarationEntryIdentifier() {
      variable = this.getVariable() and
      not variable.isCompilerGenerated() and
      // Some variables are not correctly marked as compiler generated, such as parameters of lambda
      // conversion operators.
      not variable.(Parameter).getFunction().isCompilerGenerated()
      // Note: Some duplicate and/or unflagged compiler-generated variables seem to exist in tests,
      // which may be related to constexpr in templates. These redundant variables seem to only be
      // distinguishable by the fact that their start location is the same as their end location.
      // However, this is also the case for other variables that we wish to match, such as single
      // character variable names, and other odd cases such as structured binding names.
      //
      // In the future, additional checks could find cases where duplicate variables exist where one
      // such variable has a zero-width location, and the other does not. However, these types of
      // predicates are prone to poor performance and performance regressions across CodeQL version
      // changes. So at the moment, these redundant variables are considered harmless enough and are
      // not currently excluded.
    }

    override string getAnIdent() { result = this.getName() }

    override Namespace getNamespace() { result = variable.getNamespace() }
  }

  /**
   * An identifier introduced as a template class name.
   *
   * This case is handled specially because `getName()` on a `TemplateClass` returns the name
   * including the template parameters, such as `MyClass<T>`, whereas the introduced identifier
   * is just `MyClass`.
   */
  class TemplateClassIdentifier extends IdentifierIntroductionBase, TemplateClass {
    override string getAnIdent() { result = this.getSimpleName() }

    override Namespace getNamespace() { result = this.(Declaration).getNamespace() }
  }

  /**
   * An identifier introduced as a macro name or as a parameter of a function-like macro.
   */
  class MacroIdentifier extends IdentifierIntroductionBase, Macro {
    override string getAnIdent() {
      result = this.getName() or
      result = this.(FunctionLikeMacro).getAParameter()
    }

    override Namespace getNamespace() { none() }
  }

  /**
   * An identifier introduced as a namespace name.
   *
   * Note that some namespaces are anonymous and do not introduce identifiers.
   */
  class NamespaceIdentifier extends IdentifierIntroductionBase, Namespace {
    NamespaceIdentifier() { not this.isAnonymous() }

    override string getAnIdent() { result = this.getName() }

    override Namespace getNamespace() { result = this.getParentNamespace() }
  }

  /**
   * An identifier introduced as a typed template parameter, for instance `template<int N>`.
   *
   * These are stored very strangely in the database, as `Literal`. However, we can tell that these
   * literals are template parameters because they are referenced as a template argument of a
   * `TemplateClass`, `TemplateFunction`, or `TemplateVariable`.
   *
   * These identifiers also have no location in the database, which we must fix.
   */
  class ValueParameterIdentifier extends IdentifierIntroductionBase, Literal {
    Element template;

    ValueParameterIdentifier() {
      this = template.(TemplateClass).getATemplateArgument()
      or
      this = template.(TemplateFunction).getATemplateArgument()
      or
      this = template.(TemplateVariable).getATemplateArgument()
    }

    override string getAnIdent() {
      // In our current database representation, the value of the literal is the name of the
      // template parameter.
      result = this.getValue()
    }

    override Location getLocation() {
      // These literals have no location in the database, so we use the location of the template
      // that they are a parameter of.
      result = template.getLocation()
    }

    override Namespace getNamespace() { result = template.(Declaration).getNamespace() }
  }

  /**
   * An identifier introduced as a label name, available to goto statements.
   *
   * Note that not all labels introduce identifiers, such as case labels in switch statements. These
   * are excluded as they do not introduce identifiers in the program.
   */
  class LabelIdentifier extends IdentifierIntroductionBase, LabelStmt {
    LabelIdentifier() { this.isNamed() }

    override string getAnIdent() { result = this.getName() }

    override Namespace getNamespace() { none() }
  }

  /**
   * An identifier that is part of an attribute.
   *
   * According to the cpp spec, attributes contain identifiers. It is hard to say which of these
   * attributes "introduce" identifiers, so we match them all here.
   *
   * A namespaced identifier such as `[[gnu::unused]]` is syntactically composed of two identifiers, `gnu`
   * and `unused`. Both of these are matched as introduced identifiers.
   *
   * Attributes in the database have a null location (`file://:0:0:0:0`), so in this class we say that the
   * introduced identifier is located at the location of the attributed element.
   */
  class AttributeIdentifier extends IdentifierIntroductionBase, Attribute {
    override string getAnIdent() {
      result = this.getName()
      or
      exists(StdAttribute stdattr |
        stdattr = this and
        not stdattr.getNamespace() = "" and
        result = stdattr.getNamespace()
      )
    }

    /**
     * Attributes in the database have a null location (`file://:0:0:0:0`), so we say that the
     * introduced identifier is located at the location of the attributed element.
     */
    override Location getLocation() {
      exists(Variable v |
        v.getAnAttribute() = this and
        result = v.getLocation()
      )
      or
      exists(Function f |
        f.getAnAttribute() = this and
        result = f.getLocation()
      )
      or
      exists(Class c |
        c.getAnAttribute() = this and
        result = c.getLocation()
      )
      or
      exists(Stmt stmt |
        stmt.getAnAttribute() = this and
        result = stmt.getLocation()
      )
    }

    override Namespace getNamespace() { none() }
  }
}
