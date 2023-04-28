#!/usr/bin/env bash


if [[ -z $1 ]];
then 
    echo "Usage: bump_version.sh <new_version>"
    exit
fi

echo "Setting Local Branch Version to $1."

# update the qlpacks 
find . -name 'qlpack.yml' | grep -v './codeql_modules' | grep -v './scripts' | xargs sed -i "s/^version.*$/version: ${1}/"

# update the documentation. 

find docs -name 'user_manual.md' | xargs sed -i "s/code-scanning-cpp-query-pack-anon-.*\.zip\`/code-scanning-cpp-query-pack-anon-${1}.zip\`/"
find docs -name 'user_manual.md' | xargs sed -i "s/supported_rules_list_.*\.csv\`/supported_rules_list_${1}.csv\`/"
find docs -name 'user_manual.md' | xargs sed -i "s/supported_rules_list_.*\.md\`/upported_rules_list_${1}.md\`/"
find docs -name 'user_manual.md' | xargs sed -i "s/user_manual_.*\.md\`/user_manual_${1}.md\`/"
find docs -name 'user_manual.md' | xargs sed -i "s/This user manual documents release \`.*\` of/This user manual documents release \`${1}\` of/"

echo "Done."            