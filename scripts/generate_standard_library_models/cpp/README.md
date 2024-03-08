## Generating C++ Standard Library models

This directory contains a script for generating a models-as-data file based on a sample C++ codebase that includes every standard library header.

### How to use

 1. Run `make` from this directory to build the CodeQL database for the sample codebase, and run the queries over it.
 2. Copy each page individually into a text file (avoiding copying headers and footers).
 3. Run `python3 generate_cpp_standard_library_models.py` to generate the models-as-data file.