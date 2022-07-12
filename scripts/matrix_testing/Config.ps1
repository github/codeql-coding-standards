$COMPILER_MAPPINGS = @{
    "cpp" = @{
        "clang"      = "clang++";
        "armclang"   = "armclang";
        "tiarmclang" = "tiarmclang";
    };

    "c"   = @{
        "clang" = "clang";
    };
}

$COMPILER_ARGS = @{
    "cpp" = @{
        "clang"      = "-std=c++14 -fsyntax-only";
        "armclang"   = "-std=c++14 -fsyntax-only --target=arm-arm-none-eabi";
        "tiarmclang" = "-std=c++14 -fsyntax-only --target=arm-arm-none-eabi";
    };

    "c"   = @{
        "clang" = "-fsyntax-only";
    };
    
}

$AVAILABLE_SUITES = @("CERT-C++", "AUTOSAR", "MISRA-C-2012", "CERT-C")
$REQUIRED_CODEQL_VERSION = "2.6.3"


$REPORT_QUERY = @"
SELECT
    T0.SUITE,
    T0.PACKAGE,
    Count(T0.QUERY) AS NUM_QUERIES,
    T2.NUM_COMPILE_FAILURES AS NUM_COMPILE_FAILURES,
    T4.NUM_TEST_FAILURES AS NUM_TEST_FAILURES
FROM
    (
        [{0}] AS T0
        LEFT JOIN (
            SELECT
                T1.SUITE,
                T1.PACKAGE,
                Count(T1.QUERY) AS NUM_COMPILE_FAILURES
            FROM
                [{0}] as T1
            WHERE
                T1.COMPILE_PASS = 'False'
            GROUP BY
                T1.SUITE,
                T1.PACKAGE
        ) AS T2 ON T2.SUITE = T0.SUITE
        AND T2.PACKAGE = T0.PACKAGE
    )
    LEFT JOIN (
        SELECT
            T3.SUITE,
            T3.PACKAGE,
            Count(T3.QUERY) AS NUM_TEST_FAILURES
        FROM
            [{0}] as T3
        WHERE
            T3.TEST_PASS = 'False'
        GROUP BY
            T3.SUITE,
            T3.PACKAGE
    ) AS T4 ON T4.SUITE = T0.SUITE
    AND T4.PACKAGE = T0.PACKAGE
GROUP BY
    T0.SUITE,
    T0.PACKAGE,
    T2.NUM_COMPILE_FAILURES,
    T4.NUM_TEST_FAILURES;
"@
