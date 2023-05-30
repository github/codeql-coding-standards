 * Exclude the use of `__func__` from certain queries, as it is the proscribed way to return the name of the current function:
   * `A27-0-4` - Use of the value returned by `__func__` is no longer flagged as a use of C-style strings.
   * `A18-1-1` - `__func__` is no longer flagged as a declaration of a variable using C-style arrays.