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

**Get the Root of Coding Standards**
```
Get-RepositoryRoot
```