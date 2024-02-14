 * `A7-1-5` - exclude auto variables initialized with an expression of non-fundamental type. Typically this occurs when using range based for loops with arrays of non-fundamental types. For example:
   ```
   void iterate(Foo values[]) {
      for (auto value : values) { // COMPLIANT (previously false positive)
         // ...
      }
   }
   ```