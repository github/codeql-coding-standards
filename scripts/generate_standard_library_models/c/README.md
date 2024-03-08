## Generating Standard Library models

This directory contains a script for generating a models-as-data file from a plain text file containing standard library definitions copied from Appendix B of the C Programming Language standard.

### How to use

 1. Download a PDF of the desired C programming language standard.
 2. Copy each page individually into a text file (avoiding copying headers and footers).
 3. Run `python3 generate_standard_library_models.py <lang-standard> <path-to-text-file> <output-file>`