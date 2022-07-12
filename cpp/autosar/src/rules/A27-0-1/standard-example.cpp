// $Id: A27-0-1.cpp 311495 2018-03-13 13:02:54Z michal.szczepankiewicz $
#include <cstring>
#include <cstdint>
#include <cstdio>
void F1(const char* name) // name restricted to 256 or fewer characters
{
    static const char format[] = "Name: %s .";
    size_t len = strlen(name) + sizeof(format);
    char* msg = new char[len];

    if (msg == nullptr)
    {
        // Handle an error
    }

    std::int32_t ret =
    snprintf(msg,
             len,
             format,
             name);   // Non-compliant - no additional check for overflows

    if (ret < 0)
    {
        // Handle an error
    }
    else if (ret >= len)
    {
        // Handle truncated output
    }

    fprintf(stderr, msg);
    delete[] msg;
}
void F2(const char* name)
{
    static const char format[] = "Name: %s .";
    fprintf(stderr, format, name);  // Compliant - untrusted input passed as one
                                    // of the variadic arguments, not as part of
                                    // vulnerable format string
}
void F3(const std::string& name)
{
    //compliant, untrusted input not passed
    //as a part of vulnerable format string
    std::cerr << "Name: " << name;
}