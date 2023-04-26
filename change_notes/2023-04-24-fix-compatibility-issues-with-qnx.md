* Fix compatibility issues with the `qcc` compiler and standard headers:
  * `RULE-21-4`: `longjmp` can be implmented as macro
  * `ENV32-C`: exit functions can be implmented as macro
  * `ERR33-C` `FIO34-C` `FIO46-C` `RULE-22-6`: the library files `ReadErrorsAndEOF.qll` `DoNotAccessAClosedFile.qll` `FileAccess.qll` have been updated to support different definitions of IO related functions and macros
  * `RULE-10-6`: Fix output string format
  * `STR37-C`: add support for a different `tolower/toupper` macro implementation
  * `EXP43-C`: add explicit support for library functions that are mentioned in the rule description
  * `RULE-11-1` `RULE-11-2` `RULE-11-5`: support for a different NULL pointer definition
  * `STR38-C`: removed links to library internals in the output message