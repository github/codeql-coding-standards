/**
 * @id cpp/autosar/use-inheriting-constructors
 * @name A12-1-6: Use inheriting constructors instead of reimplementing all the base class constructors
 * @description Derived classes that do not need further explicit initialization and require all the
 *              constructors from the base class shall use inheriting constructors.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-1-6
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * A `ConstructorBaseInit` that is either a direct call to a base class, or a direct call to a
 * virtual base class.
 *
 * This class excludes delegating constructor calls, which are not to base classes, but occur on
 * the same class.
 */
class ConstructorDirectOrVirtualInit extends ConstructorBaseInit {
  ConstructorDirectOrVirtualInit() {
    this instanceof ConstructorDirectInit
    or
    this instanceof ConstructorVirtualInit
  }
}

/**
 * A constructor that "reimplements" a constructor from a base class.
 *
 * A reimplemented constructor is one which:
 *  - Calls a base class constructor e.g. `Derived(int p1) : Base(p1) {}`
 *  - Does not explicitly initialize another base class or member variable.
 *  - Has an empty body.
 *  - Matches the parameter list and certain specifiers (`constexpr`, `explicit`) of the base class
 *    constructor.
 *  - Matches the access visibility of the base class constructor.
 *  - Accepts parameters in the same order as the base class constructor.
 */
class ReimplementedConstructor extends Constructor {
  ConstructorDirectOrVirtualInit baseInitCall;
  Constructor baseConstructor;

  ReimplementedConstructor() {
    // baseInitCall is a non compiler generated ConstructorCall to a base class
    baseInitCall.getEnclosingFunction() = this and
    // And there is only one constructor init, so no other initialization occurs
    count(ConstructorInit ci | ci.getEnclosingFunction() = this) = 1 and
    // The constructor body has a single statement (representing the constructor init)
    getBlock().getNumStmt() = 1 and
    // Determine the constructor target
    baseConstructor = baseInitCall.getTarget() and
    // The constructor is for a direct base class
    baseConstructor.getDeclaringType() = getDeclaringType().getABaseClass() and
    // The base constructor has the same visibility as this constructor
    (
      baseConstructor.isPublic() and this.isPublic()
      or
      baseConstructor.isProtected() and this.isPublic()
      or
      baseConstructor.isPublic() and this.isPublic()
    ) and
    // The i-th parameter is used as the i-th argument, and is of the correct type
    forall(Parameter p, int i | p = getParameter(i) |
      p.getAnAccess() = baseInitCall.getArgument(i) and
      baseConstructor.getParameter(i).getType().getUnspecifiedType() =
        p.getType().getUnspecifiedType()
    ) and
    // The base constructor has the same explicit and constexpr specifiers as this constructor
    forall(string specifier | specifier = ["explicit", "is_constexpr"] |
      if baseConstructor.hasSpecifier(specifier)
      then this.hasSpecifier(specifier)
      else not this.hasSpecifier(specifier)
    )
  }

  /** Gets the constructor this is inherited from. */
  Constructor getConstructorInheritedFrom() { result = baseConstructor }
}

/** Gets the number of defaulted parameters for the given constructor. */
int getNumberOfDefaultedParameters(Constructor c) {
  result = count(c.getAParameter().getInitializer())
}

from Class derivedClass, Class baseClass
where
  not isExcluded(derivedClass, InitializationPackage::useInheritingConstructorsQuery()) and
  // Pick a base class
  baseClass = derivedClass.getABaseClass() and
  // For each "interesting" constructor in the base class, there must be a "reimplemented"
  // constructor in the derived class
  forex(Constructor baseClassConstructor |
    baseClassConstructor.getDeclaringType() = baseClass and
    // Ignore the copy, move and the default constructors
    not baseClassConstructor instanceof MoveConstructor and
    not baseClassConstructor instanceof CopyConstructor and
    not baseClassConstructor.getNumberOfParameters() = 0
  |
    // For constructors with defaulted parameters, we must see a reimplemented constructor for each
    // possible number of arguments to the constructor
    forall(int defaultedParameterCount |
      defaultedParameterCount = [0 .. getNumberOfDefaultedParameters(baseClassConstructor)]
    |
      // Find a reimplemented constructor for this number of defaulted parameters
      exists(ReimplementedConstructor reimplementedConstructor |
        reimplementedConstructor = derivedClass.getAConstructor() and
        reimplementedConstructor.getConstructorInheritedFrom() = baseClassConstructor and
        baseClassConstructor.getNumberOfParameters() - defaultedParameterCount =
          reimplementedConstructor.getNumberOfParameters()
      )
    )
  )
select derivedClass,
  "Derived class " + derivedClass.getName() +
    " unecessarily reimplements all the constructors from $@.", baseClass, baseClass.getName()
