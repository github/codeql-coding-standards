 - The following query suites have been added or modified for CERT C:
   - A new query suite has been created `cert-c-default.qls` to avoid confusion with the CERT C++ query suites. The `cert-default.qls` suite has been deprecated, and will be removed in a future releases, and is replaced by the `cert-c-default.qls` suite.
     - The `cert-c-default.qls` suite has been specified as the default for the pack, and will include our most up-to-date coverage for CERT C.
   - One new query suite, `cert-c-recommended.qls` has been added to enable running CERT recommendations (as opposed to rules) that will be added in the future.
   - The default query suite, `cert-c-default.qls` has been set to exclude CERT recommendations (as opposed to rules) that will be added in the future.
 - The following query suites have been added or modified for CERT C++:
   - A new query suite has been created `cert-cpp-default.qls` to avoid confusion with the CERT C query suites. The `cert-default.qls` suite has been deprecated, and will be removed in a future releases, and is replaced by the `cert-cpp-default.qls` suite.
     - The `cert-cpp-default.qls` suite has been specified as the default for the pack, and will include our most up-to-date coverage for CERT C.
   - A new query suite has been created `cert-cpp-single-translation-unit.qls` to avoid confusion with the CERT C query suites. The `cert-single-translation-unit.qls` suite has been deprecated, and will be removed in a future releases, and is replaced by the `cert-cpp-single-translation-unit.qls` suite.