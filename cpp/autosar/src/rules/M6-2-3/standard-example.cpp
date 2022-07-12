while((port & 0x80) == 0)
{
    ; // wait for pin - Compliant
    /* wait for pin */ ; // Non-compliant, comment before ;
    ;// wait for pin – Non-compliant, no white-space char after ;
}