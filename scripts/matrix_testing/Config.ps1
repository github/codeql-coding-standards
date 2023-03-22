Import-Module -Name "$PSScriptRoot/../PSCodingStandards/CodingStandards"

$COMPILER_MAPPINGS = @{
    "cpp" = @{
        "clang"      = "clang++";
        "gcc"        = "g++";
        "armclang"   = "armclang";
        "tiarmclang" = "tiarmclang";
        "qcc"        = "qcc"; 
    };

    "c"   = @{
        "clang" = "clang";
        "gcc"   = "gcc";
        "qcc"        = "qcc";  
    };
}

$COMPILER_ARGS = @{
    "cpp" = @{
        "clang"      = "-std=c++14 -fsyntax-only";
        "gcc"      = "-std=c++14 -fsyntax-only";
        "armclang"   = "-std=c++14 -fsyntax-only --target=arm-arm-none-eabi";
        "tiarmclang" = "-std=c++14 -fsyntax-only --target=arm-arm-none-eabi";
        "qcc" = "-lang-c++ -V8.3.0 -Wc,-fsyntax-only -c -nopipe -std=c++14 -D_QNX_SOURCE -Vgcc_ntoaarch64le_cxx";
    };

    "c"   = @{
        "gcc" = "-fsyntax-only -std=c11";
        "clang" = "-fsyntax-only -std=c11";        
        "qcc" = "-V8.3.0 -Wc,-fsyntax-only -c -nopipe -std=c11 -Vgcc_ntoaarch64le";        
    };
    
}

$REQUIRED_CODEQL_VERSION = (Get-Content (Join-Path (Get-RepositoryRoot) "supported_codeql_configs.json") | ConvertFrom-Json).supported_environment.codeql_cli


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
