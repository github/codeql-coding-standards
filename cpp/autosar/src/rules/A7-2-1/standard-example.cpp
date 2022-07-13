// $Id: A7-2-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
enum class E : std::uint8_t
{
    Ok = 0,
    Repeat,
    Error
};
E Convert1(std::uint8_t number) noexcept
{
    E result = E::Ok; // Compliant
    switch (number)
    {
        case 0:
        {
            result = E::Ok; // Compliant
            break;
        }
        case 1:
        {
            result = E::Repeat; // Compliant
            break;
        }
        case 2:
        {
            result = E::Error; // Compliant
            break;
        }
        case 3:
        {
            constexpr std::int8_t val = 3;
            result = static_cast<E>(val); // Non-compliant - value 3 does not
                                          // correspond to any of E’s
                                          // enumerators
            break;
        }
        default:
        {
            result =
            static_cast<E>(0); // Compliant - value 0 corresponds to E::Ok
            break;
        }
    }
    return result;
}
E Convert2(std::uint8_t userInput) noexcept
{
    E result = static_cast<E>(userInput); // Non-compliant - the range of
                                          // userInput may not correspond to
                                          // any of E’s enumerators
    return result;
}
E Convert3(std::uint8_t userInput) noexcept
{
    E result = E::Error;
    if (userInput < 3)
    {
        result = static_cast<E>(userInput); // Compliant - the range of
                                            // userInput checked before casting
                                            // it to E enumerator
    }
    return result;
}