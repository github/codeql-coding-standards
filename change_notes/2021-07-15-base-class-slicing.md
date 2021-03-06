 - `A12-8-6` - `CopyAndMoveNotDeclaredProtected.ql`:
   - Fixed issue #174 - a result is now only reported when the declaring class is either used as a base class in the database, or where the class is abstract.
   - Fixed a bug where exclusions did not apply to invalid assignment operators.
   - Changed the location of the alert to always report the function declaration entry in the class body, rather than the definition location which may be outside the class.
   - Updated the alert message to specify the kind of member function, the name of the declaring type and to clarify it is a base class.
 - `A12-4-1` - `DestructorOfABaseClassNotPublicVirtual.ql`:
   - Extended the concept of a base class to include abstract classes which are not extended in the current database.