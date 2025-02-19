 - A new in code deviation format has been introduced, using the C/C++ attribute syntax:
   ```
   [[codeql::<standard>_deviation("<code-identifier>")]]
   ```
   This can be applied to functions, statements and variables to apply a deviation from the Coding Standards configuration file. The user manual has been updated to describe the new format.
 - For those codebases that cannot use standard attributes, we have also introduced a comment based syntax
   ```
   // codeql::<standard>_deviation(<code-identifier>)
   // codeql::<standard>_deviation_next_line(<code-identifier>)
   // codeql::<standard>_deviation_begin(<code-identifier>)
   // codeql::<standard>_deviation_end(<code-identifier>)
   ```
   Further information is available in the user manual.