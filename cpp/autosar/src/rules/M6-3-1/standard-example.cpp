for(i = 0; i < N_ELEMENTS; ++i)
{                // Compliant
  buffer[i] = 0; // Even a single statement must
                 // be in braces
}
for(i = 0; i < N_ELEMENTS; ++i);  // Non-compliant
                                  // Accidental single null statement
{
  buffer[i] = 0;
}
while(new_data_available) // Non-compliant
  process_data();         // Incorrectly not enclosed in braces
  service_watchdog();     // Added later but, despite the appearance
                          // (from the indent) it is actually not
                          // part of the body of the while statement,
                          // and is executed only after the loop has
                          // terminated