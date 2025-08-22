/**
 * This module implements the C++ spec sections [class.copy] and [over.match] (overload resolution)
 * as they relate to discovering implicit copy and move constuctors and assignment operators.
 * 
 * This module is necessary because implicit constructors and copy assignment operators do not
 * reliably appear in the database, and, in order to know if a class is copy constructible, copy
 * assignable, move constructible, or move assignable, we need to know whether these implicit
 * special member functions exist, and whether they are implicitly defined as deleted.
 * 
 * Note that the section implementing operator overload resolution is NOT a complete implementation.
 * Creating such a module would be a massive project, so only the subset of that logic needed to
 * resolve copy initialization and `operator=` as it pertains to [class.copy] has been implemented.
 * 
 * The process for checking if a class has an implicitly defaulted or deleted copy/move
 * constructor/assignment operator is roughly as follows:
 * 
 *  - If a record for the special member function exists in the database, use that definition.
 * 
 *  - (Copy constructor): If the class has a user declared move constructor or assignment operator,
 *    then the implicit copy constructor is deleted [class.copy]/7.
 * 
 *  - (Move constructor): If there is a user declared copy constructor, copy assignment operator, or
 *    move assignment operator, user declared destructor, then no implicit move constructor is
 *    declared [class.copy]/9.
 * 
 *  - (copy assignment operator): If the class has a user declared move constructor or move
 *    assignment operator, then the implicit copy assignment operator is deleted [class.copy]/18.
 * 
 *  - (move assignment operator): If there is a user declared copy constructor, copy assignment
 *    operator, or move constructor, user declared destructor, then no implicit move assignment
 *    operator is declared [class.copy]/20.
 * 
 *  - (copy constructor): If the class contains a non-static data member of rvalue reference type,
 *    then the implicit copy constructor is deleted [class.copy]/11.4.
 * 
 *  - (copy and move assignment operators): If the class contains a non-static data member of const
 *    non-class type (or array thereof), then the implicit copy/move assignment operator is deleted.
 *    [class.copy]/23.2.
 * 
 *  - (copy and move assignment operators): If the class has a non-static data
 *    member of reference type, then the corresponding implicit constructor/assignment operator is
 *    deleted [class.copy]/23.3.
 * 
 *  - If the current class is or contains an anonymous union, then it is a union-like class
 *    [class.union]/8. If a union-like class has a non-static union member (a "variant member"):
 * 
 *    - (copy and move constructors) has a non-trivial "corresponding constructor", then the
 *      corresponding implicit copy/move constructor is deleted [class.copy]/11.1.
 * 
 *    - (copy and move assignment operators) has a non-trivial "corresponding assignment operator",
 *      then the corresponding implicit copy/move assignment operator is deleted [class.copy]/23.1.
 * 
 *  - For each "potentially constructed subobject" type `T`, where a potentially constructed
 *    subobject includes non-static data members and direct base classes (note that array members of
 *    type `T[]` are considered here as values of type `T`):
 * 
 *    - Note: The spec says that copy/move constructors perform this resolution on "potentially
 *      constructed subobjects," which would exclude virtual bases of abstract classes. I have dug
 *      deeply into this issue and concluded that it is irrelevant to us, for the following reasons.
 *      Basically, the abstract class cannot be instantiated, so it is never copy/move constructible
 *      regardless of whether it has a deleted or defaulted copy/move constructor. If we wanted to
 *      check for such a constructor, we would need to create a concrete subclass. However, that
 *      subclass would have the root virtual base as a direct subobject (because that is how virtual
 *      inheritance works). This concrete class will require the virtual base to be copy/move
 *      constructible. Thus, it would be impossible to create and observe/test the implicit
 *      defaulted copy/move constructor for an abstract class with a virtual base that is not
 *      copy/move constructible. We may as well pretend that it isn't, and treat virtual inheritance
 *      the same as non-virtual inheritance for this purpose. Also note that this language is only
 *      used in the spec for constructors, not assignment operators, so if this note is missing an
 *      important detail/subtlety, then it will only affect constructors.
 * 
 *    - T must satisfy operator overload resolution for the corresponding constructor (described
 *      later). [class.copy]/11.2, 23.4.
 * 
 *    - (copy and move constructors): If `T` has no valid destructor (deleted or inaccessible) then
 *      the implicit constructor is deleted [class.copy]/11.3.
 * 
 *  The process for validating overload resolution is roughly as follows:
 * 
 *  - Roughly speaking, given each constructed subobject of type `T`, we will attempt to resolve
 *    `T(t)` for copy and move constructors, and `t = t` for copy and move assignment operators. We
 *    must find a set of candidate functions in each case (constructors or operators). More detail
 *    is given below.
 * 
 *  - Candidate functions are gathered from the following sources:
 * 
 *    - (Move and copy constructors): Candidates are gathered as described in [over.match.copy].
 * 
 *      - The candidates to copy type T is the set of converting constructors on T. A defaulted and
 *        deleted move constructor is not considered a candidate.
 * 
 *      - Note that constructors declared without the `explicit` specifier are considered converting
 *        constructors. [class.conv.ctor]/1. Non explicit copy/move constructors are converting
 *        constructors [class.conv.ctor]/3.
 * 
 *      - For future debugging: [over.match.copy]/1.2 does not seem to apply, as type S is the same
 *        as type T. Hopefully this interpretation is correct.
 * 
 *    - (Move and copy assignment operators): Candidates are gathered as described in
 *      [over.match.oper].
 * 
 *      - When the member type `T` is a class type, all members `T::operator=`. A defaulted and
 *        deleted move assignment operator is not considered a candidate. This is not limited to
 *        special member functions, but may include other overloads of `=` on this class.
 * 
 *      - If any of these candidates are templated, we cannot analyze them, so we give up. We must
 *        report these in an audit query.
 * 
 *      - Built-in assignment operators `VQ L& operator=(VQ L&, R)` exist for all arithmetic types
 *        `L`, promoted arithmetic types `R`, where `VQ` is either "volatile" or empty. These are
 *        also candidates [over.match.oper]/3.2.
 *
 *  - Built in assignment operators have additional restrictions. No temporaries are created for the
 *    left operand, and no user defined conversions are applied to the left operand
 *    [over.match.oper]/4.
 * 
 *  - Note that the candidate functions may be deleted. For this reason, it is important that prior
 *    steps correctly handle the case where a special member function is _not declared_, vs when the
 *    special member function is declared as deleted. The former is not a candidate while the latter
 *    is a candidate.
 * 
 *  - The candidates are checked to have the correct number of parameters. Note that this must
 *    consider the existence of optional parameters (parameters with default arguments), and
 *    variadic functions [over.match.viable]/2.
 * 
 *  - The argument is checked to have a well-formed implicit conversion sequence to the parameter
 *    type of the candidate function:
 * 
 *    - If the argument matches the parameter type, that is a valid conversion sequence.
 * 
 *    - We check for "standard conversion sequences" [over.ics.scs]. A standard conversion sequence
 *      is a sequence of:
 * 
 *      - (Optionally one of) a lvalue-to-rvalue, array-to-pointer, or function-to-pointer
 *        conversion
 * 
 *        - lvalue-to-rvalue: The type T may not be an incomplete type. Non-class types have
 *          cv-qualification removed. [conv.lval].
 * 
 *        - array-to-pointer: T[] is converted to T*. [conv.array].
 * 
 *        - function-to-pointer: function type T is converted to pointer to function type T*.
 *          [conv.func].
 * 
 *      - Followed by an optional qualification conversion [conv.qual]:
 * 
 *        - Recursively adds cv-qualifiers to pointer, pointer to member, or array types. This
 *          recursive cannot remove cv-qualifiers, and stops at the first non-pointer,
 *          non-pointer-to-member, non-array type.
 * 
 *      - Followed by (optionally one of) an integral promotion, a floating point promotion
 * 
 *        - Integral promotions [conv.prom]:
 * 
 *          - integer types other than `bool`, `char16_t`, `char32_t`, and `wchar_t` and with a rank
 *            less than the rank of int are promoted to int if int can represent all the
 *            values of the original type. Otherwise it can be converted to unsigned int.
 * 
 *          - `char16_t`, `char32_t`, and `wchar_t` are promoted to the first of `int`, `unsigned int`,
 *            `long int`, `unsigned long int`, `long long int`, or `unsigned long long int` that can
 *            represent all the values of the original type, or else is unchanged.
 * 
 *          - Enums with a fixed underlying type can be converted to the underlying type, or integer
 *            promotion may be applied to the underlying type.
 * 
 *          - Unfixed enums can be converted to an integer type that can represent all the values of
 *            its enum values (`int`, `unsigned int`, `long int`, ...).
 * 
 *          - `bool` can be converted to `int`.
 * 
 *          - Bitfields can be converted to `int` or `unsigned int`, and no other integral type.
 * 
 *        - Floating point promotions [conv.fpprom] can convert a float to a double.
 *
 *      - Followed by (optionally one of) an integral conversion, a floating point conversion, a
 *        floating-integral conversion, pointer conversion, pointer to member conversion, or a
 *        boolean conversion.
 * 
 *        - An integer can be converted to any other integer type (that isn't a promotion)
 *          [conv.integral], or bool, and bool can be converted to any integer [conv.bool]. An
 *          integer or unscoped enum can also be converted to a floating point type [conv.fpint].
 * 
 *        - A floating point type can be converted to another floating point type (that isn't a
 *          promotion) [conv.double], or to an integer type [conv.fpint].
 * 
 *        - Pointer conversion [conv.ptr] can convert a "null pointer constant" (an integer literal
 *          with constant value zero, or an expression of type `std::nullptr_t`) to a cv-qualified
 *          pointer type. This does not count as a qualification conversion. An integer literal with
 *          value zero can also be converted to `std::nullptr_t`. A pointer to `cv-T1` can
 *          be converted to a pointer to `cv-T2` if T2 is void or a base class of T1. If this
 *          conversion is selected and the base class is inaccessible or ambiguous, then overload
 *          resolution must fail.
 * 
 *        - Pointer to member conversion [conv.mem] can convert a "null pointer constant" (see
 *          above) to a cv-qualified pointer-to-member type. This does not count as a qualification
 *          conversion. A pointer-to-member of `B` of type `cv-T` can be converted to a
 *          pointer-to-member of `D` of type `cv-T` if `D` is derived from `B`. If `B` is
 *          inaccessible, ambiguous, or a (possibly transitively) virtual base class of `D`, then
 *          overload resolution must fail when this conversion is selected.
 * 
 *        - In addition to the above, unscoped enums, pointer types, and pointer-to-member types may
 *          be converted to `bool`.
 *
 *      - If any "_x_ conversion" was applied in the last step, the sequence is ranked as a
 *        "Conversion." Otherwise, if any "_y_ promotion" was applied in the previous step, the rank
 *        is "Promotion." Otherwise, the rank is "Exact Match."
 * 
 *    - If the corresponding argument is matched by an ellipsis, that is a valid conversion
 *      sequence [over.ics.ellipsis].
 * 
 *    - (copy and move assignment operators): User defined conversions are considered
 *      [over.ics.user] unless the candidate is a built-in assignment operator [over.match.oper]/4.
 * 
 *      - A standard conversion sequence is performed, followed by a user-defined conversion,
 *        followed by another standard conversion sequence.
 * 
 *      - TODO: consider [over.ics.user]/2-4 which I don't yet understand.
 * 
 *    - (copy and move constructors): user-defined conversion sequences are not considered.
 * 
 *    - TODO: Understand and address reference binding 13.3.3.1.4. Does this apply to us?
 * 
 *    - If multiple conversion sequences are possible, the "ambiguous" sequence is chosen. (Note:
 *      during ranking this is scored as a "user-defined" conversion sequence. If the overload that
 *      is ultimately selected has an ambiguous conversion sequence, overload resolution fails.)
 * 
 *  - Now the candidates are ranked according to the implicit conversion sequences associated with
 *    them.
 * 
 *    - Standard conversion sequences are ranked above user-defined conversion sequences, which are
 *      ranked above ellipsis matches [over.ics.rank]/2.
 * 
 *    - Standard conversions are ranked as Exact Match > Promotion > Conversion [over.ics.rank]/4.
 * 
 *    - Otherwise, a standard conversion that converts a pointer, pointer to member, or nullptr_t to
 *      bool is ranked below a conversion that does not do so [over.ics.rank]/4.1.
 * 
 *    - Otherwise, if two promotions promotes enum `E` with fixed underlying type `U`, and one
 *      promotes to `U` while the other promotes to the promoted type of `U`, then the promotion to
 *      `U` is ranked better [over.ics.rank]/4.2.
 * 
 *    - Otherwise, a conversion from `B*` to `A*` where B is derived from A is ranked better than a
 *      conversion from `B*` to `void*` [over.ics.rank]/4. Similarly, a conversion from `A*` to
 *      `void*` is better than a conversion from `B*` to `void*` [over.ics.rank]/4.3.
 * 
 *    - Otherwise, in conversions from `A` to `B` or `C`, `A*` to `B*` or `C*`, or `A::*` to `B::*`
 *      or `C::*`, we check the number of steps from `A` to `B` and from `A` to `C` in the
 *      inheritance hierarchy. The conversion with the fewest steps is ranked better
 *      [over.ics.rank]/4.4.
 * 
 *  - We look for the best viable function. The viable function must have a conversion sequence
 *    for each argument/parameter type. The best viable function should have a conversion sequence
 *    for each argument/parameter type that is not worse than any other viable function.
 * 
 *  - To efficiently find the best viable function, we must first run a tournament between all
 *    candidates. Then, we check the winner against all the prior losers to ensure that there was
 *    not an equally good candidate that was eliminated earlier.
 * 
 *  - If multiple viable functions are equally good, then the overload resolution fails.
 * 
 *  - Lastly, if a single candidate is selected, it must be checked to ensure it is not ill-formed.
 *    For instance, if the selected candidate is a deleted function, then the overload resolution
 *    fails.
 * 
 *  - If that overload resolution has succeeded, we can declare that the current type indeed has the
 *    relevant special member function.
 * 
 *  - We must record this in order to analyze types that contain this type as a member or base class.
 *    The exact signatures will affect overload resolution in those types.
 * 
 *    - Copy constructor: `T::T(const T&)` if each subobject `M` has a copy constructor with
 *      signature `M(const M&)`, otherwise `T::T(T&)`.
 * 
 *    - Move constructor: `T::T(T&&)`.
 * 
 *    - Copy assignment operator: `T& T::operator=(const T&)` if each subobject `M` has a copy
 *      assignment operator with signature `M& M::operator=(const M&)`, otherwise
 *      `T& T::operator=(T&)`.
 * 
 *    - Move assignment operator: `T& T::operator=(T&&)`
 *
 *  - Now that we have the implicit signatures, we need to check if `std::is_x_constructible`,
 *    `std::is_x_assignable` is true or false.
 * 
 *    - For `is_x_constructible`, we need to check if `T(t)` is well-formed. This looks like the
 *      above process, but it also requires that T not be abstract and that T not be inaccessible
 *      to the context of std::is_x_constructible. This simply means it must be public.
 *
 *    - For `is_x_assignable`, we need to check if `t = t` is well-formed. Again, this looks like the
 *      above process, but the resolved overload must be accessible, though it does not matter if it
 *      is an abstract class.
 * 
 *    - Nested private classes cannot be passed as parameters to std::is_x_y<T>(). I have decided to
 *      simply exclude them from this analysis.
 * 
 * TODOs:
 *   - Are variant parameters inheritable?
 *   - How complicated is "inaccessible" in the context of inaccessible destructors and base
 *     classes? (friend classes?)
 *   - How hard is it to efficiently implement the tournament selection algorithm in CodeQL?
 *   - How hard is it to check that the final selected overload is not ill-formed?
 */
