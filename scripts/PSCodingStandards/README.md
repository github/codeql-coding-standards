# Powershell Automation Library

To use this on the command line, do:

```
Import-Module -Name ./scripts/PSCodingStandards/CodingStandards
```

To use this in your scripts you can do: 

```
Import-Module -Name "$PSScriptRoot/../PSCodingStandards/CodingStandards"
```

# Summary of Available Commands


**Get all the rules in a particular suite and language**

```
Get-RulesInSuite -Language c -Suite cert-c
```

Example: Get all rules in a suite with severity 'error'. 

```
Get-RulesInSuite -Language c -Suite cert-c | Where-Object { $_.severity -eq 'error' }
```

**Get All Packages for a Language**

```
Get-Packages -Language c 
```

**Get Rules in the IO package for a particular suite and language**

```
Get-RulesInPackageAndSuite -Suite cert-c -Package (Get-Packages -Language c | Where-Object { $_.BaseName -eq "IO" })
```

**Get The Test Directory For Queries With Severity Error In autosar**

```
(Get-RulesInSuite -Language cpp -Suite autosar | Where-Object { $_.severity -eq 'error' }) | ForEach-Object { Get-TestDirectory -Language c -RuleObject $_ }
```

**Get the runnable test file, following reused-fixture references**

```
(Get-RulesInSuite -Language c -Suite MISRA-C-2025) | ForEach-Object { Get-TestFile -Language c -RuleObject $_ }
```

A `.testref` contains a repository-relative path to a runnable `.ql` or `.qlref` file
with matching `.expected` results. A new query variant needs its own runnable test,
but can reuse an existing C/C++ fixture. The matrix runner uses the referenced
file's directory, query name, and expected results.

Direct runnable tests take precedence over `.testref` files. Returned test files
and their base fixture directories are repository-relative paths, so wrappers
sharing a fixture use the same matrix lock.

`__applicable_suites` controls matrix suite selection without changing
`__memberof_suite` ownership. Add suites to `$SUITE_DEFINITIONS` in `Config.ps1`;
`IncludeSuites` lists additional owning suites, and `ExcludeTags` filters their
queries. MISRA C:2025 uses this configuration to include non-legacy MISRA C:2012-owned queries.

Run the matrix tooling regression checks with:

```
pwsh -NoLogo -NoProfile -File scripts/matrix_testing/Get-TestFile.Tests.ps1
```

**Get the Root of Coding Standards**
```
Get-RepositoryRoot
```