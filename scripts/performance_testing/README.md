# Performance Testing 

Performance testing may be accomplished by using the performance testing tool found in this directory, `Test-ReleasePerformance.ps1`. These results may be further processed to provide predicate level performance details by using the script `profile_predicates.py`, which is documented in the [Profiling Predicates section.](#profiling-predicates), below. 

Note that this script depends on other files from this repository. It may be run on external builds of Coding Standards through the `-CodingStandardsPath` flag, but it should be run from a fresh checkout of this repository. 

This script requires `pwsh` to be installed. Note that the Windows native Powershell is not sufficient and you should download PowerShell Core. 

- Installing on Windows: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3
- Installing on Linux: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.3
- Installing on MacOS: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.3

Before invoking this script you should start a powershell session by typing `pwsh` at a command prompt. 

## Usage

```
NAME
    .\scripts\performance_testing\Test-ReleasePerformance.ps1
    
SYNOPSIS
    Test release performance. Generates outputs 2 csv files containing the slowest predicates as well as the queries
    causing work. Note that the method of computing query execution time is inaccurate due to the shared nature of 
    predicates. 

    
SYNTAX
    C:\Projects\codeql-coding-standards\scripts\performance_testing\Test-ReleasePerformance.ps1 -RunTests [-Threads <String>] -DatabaseArchive <String> 
    [-TestTimestamp <String>] [-CodingStandardsPath <String>] [-ResultsDirectory <String>] [-ReleaseTag <String>] -Suite <String> [-Platform <String>] -Language 
    <String> [<CommonParameters>]
    
    C:\Projects\codeql-coding-standards\scripts\performance_testing\Test-ReleasePerformance.ps1 -ProcessResults -ResultsFile <String> [-ResultsDirectory <String>] 
    [-ReleaseTag <String>] -Suite <String> [-Platform <String>] -Language <String> [<CommonParameters>]


DESCRIPTION
    Test release performance. Generates outputs 2 csv files containing the slowest predicates as well as the queries
    causing work. Note that the method of computing query execution time is inaccurate due to the shared nature of
    predicates.


PARAMETERS
    -RunTests [<SwitchParameter>]
        Configures tool to run tests.

        Required?                    true
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Threads <String>
        Specifies the number of threads to use.

        Required?                    false
        Position?                    named
        Default value                5
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -DatabaseArchive <String>
        Specifies the database to use for testing. Should be a zipped database
        directory.

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -TestTimestamp <String>
        The timestamp to use for the test.

        Required?                    false
        Position?                    named
        Default value                (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -CodingStandardsPath <String>
        The path to the coding standards root directory. This can be either the
        root of the repository or the root of the coding standards directory.

        Required?                    false
        Position?                    named
        Default value                "$PSScriptRoot../../"
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -ProcessResults [<SwitchParameter>]

        Required?                    true
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -ResultsFile <String>
        Configures tool to process results.

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -ResultsDirectory <String>
        Where results should be written to.

        Required?                    false
        Position?                    named
        Default value                (Get-Location)
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -ReleaseTag <String>
        The release tag to use for the test.

        Required?                    false
        Position?                    named
        Default value                current
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Suite <String>
        Which suite to run.

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Platform <String>
        The platform to run on. This is just a descriptive string.

        Required?                    false
        Position?                    named
        Default value                $PSVersionTable.Platform
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Language <String>
        The language to run on.

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS


RELATED LINKS

```
## Example Usage

Run the `cert` suite for `c` from within the Coding Standards repository. 

```
.\scripts\performance_testing\Test-ReleasePerformance.ps1 -RunTests -DatabaseArchive ..\codeql-coding-standards-release-engineering\data\commaai-openpilot-72d1744d830bc249d8761a1d843a98fb0ced49fe-cpp.zip -Suite cert -Language c
```

Run the `cert` suite for `c` on an external release, specifying a `-ReleaseTag` as well. The `-ReleaseTag` parameter is used for configuring performance tool to generate files within subdirectories with the `-ReleaseTag` as a prefix. For example, specifying `-ReleaseTag "2.16.0"` will cause files to be generated in the `release=2.16.0` directory. 

```
.\scripts\performance_testing\Test-ReleasePerformance.ps1 -RunTests -DatabaseArchive ..\codeql-coding-standards-release-engineering\data\commaai-openpilot-72d1744d830bc249d8761a1d843a98fb0ced49fe-cpp.zip -Suite cert -Language c -ReleaseTag "2.16.0" -CodingStandardsPath "Downloads\code-scanning-cpp-query-pack-2.16.0\codeql-coding-standards\"
```



## Outputs 

The `Test-ReleasePerformance.ps1` produces three files in the `ResultsDirectory` location, which defaults `performance_tests` within the current working directory. 

- `suite=$Suite,datum=queries.csv` - Which contains the run time for each query. 
- `suite=$Suite,datum=evaluator-log.json` - Which contains the evaluator log. 
- `suite=$Suite,datum=sarif.sarif` - The sarif log file for the run. 

## Profiling Predicates 

If you wish to extract predicate-level profiling information, you may use the script `profile_predicates.py` located in this directory. It requires Python3 with `pandas` and `numpy` to work. If you wish to use a virtual environment you may create one as follows on a Unix-based platform:

```
python -mvenv venv
source venv/bin/activate 
pip install pandas numpy
```

The script works by summarizing ALL of the csv and json files within a given directory. Thus, if you want to profile multiple suites or multiple releases you may place the files within that directory by repeatedly invoking `Test-ReleasePerformance.ps1.` Make sure to supply the same output directory each time so that the results accumulate in the correct location. 

To invoke the script run:

```
python scripts/performance_testing/profile_predicates.py <path to output directory>
```

For example: 
```
python .\scripts\performance_testing\profile_predicates.py .\performance_tests\
```

This will produce an additional CSV file per release, platform, and language within that directory called: `slow-log,datum=predicates,release={release},platform={platform},language={language}.csv` which will contain the execution times of all of the predicates used during execution. 
