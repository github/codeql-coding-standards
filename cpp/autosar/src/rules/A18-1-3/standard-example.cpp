// $Id: A18-1-3.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <memory>
#include <vector>
void Fn() noexcept
{
    std::auto_ptr<std::int32_t> ptr1(new std::int32_t(10)); // Non-compliant 
    std::unique_ptr<std::int32_t> ptr2 =
                std::make_unique<std::int32_t>(10); // Compliant
    std::vector<std::auto_ptr<std::int32_t>> v; // Non-compliant
}