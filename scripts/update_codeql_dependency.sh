#!/usr/bin/env bash

# If there aren't two arguments, print usage and exit.
if [[ -z $2 ]];
then 
    echo "Usage: update_codeql_dependencies.sh <dependency> <new_version>"
    exit
fi

echo "Updating CodeQL dependency $1 to $2."

# update the qlpacks
find . -name 'qlpack.yml' | grep -v './codeql_modules' | xargs sed -i -r "s#${1}: [^\s]+#${1}: ${2}#"

# update the lock files
find . -name 'codeql-pack.lock.yml' | grep -v './codeql_modules' | xargs sed -i -r -z "s#${1}:\n(\s*)version: [^\s]+\n#${1}:\n\1version: ${2}\n#"

echo "Done."
