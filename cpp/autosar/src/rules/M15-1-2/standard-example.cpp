try {
  throw(NULL); // Non-compliant

} catch (int32_t i) { // NULL exception handled here
  // ...
} catch (const char_t *) // Developer may expect it to be caught here
{
  // ...
}
char_t *p = NULL;
try {
  throw(static_cast<const char_t *>(NULL)); // Compliant,
                                            // but breaks
                                            // Rule 15–0–2
                                            // Compliant
  throw(p);
  catch (int32_t i) {
    // ...
  }
  catch (const char_t *) // Both exceptions handled here
  {
    // ...
  }