#!/bin/bash

~/codeql-home/codeqls/codeql-2.6.3/codeql database create --overwrite --language cpp --command "clang++ main.cpp" --command "python3 ../../scripts/configuration/process_coding_standards_config.py" ~/codeql-home/databases/deviations-test