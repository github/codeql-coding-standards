import sys
import shutil 
import os 
import subprocess
import json 

if len(sys.argv) < 3:
    print ("Usage: build_test_database.py STANDARD RULE", file=sys.stderr)
    exit(1)

STANDARD=sys.argv[1]
RULE=sys.argv[2]

if shutil.which("codeql") is None:
    print ("Please install codeql.", file=sys.stderr)
    exit(1)

if shutil.which("clang++") is None:
    print ("Please install clang++.", file=sys.stderr)
    exit(1)


# check the database directory
if os.path.exists('databases') and not os.path.isdir('databases'):
    print ("Please delete the file 'databases' in your home directory before continuing.", file=sys.stderr)
    exit(1)
elif not os.path.exists('databases'):
    print ("Creating database directory in current working directory...")
    os.mkdir('databases') 

# check the standard

if not os.path.exists(f"cpp/{STANDARD}"):
    print (f"Standard {STANDARD} doesn't exist.", file=sys.stderr)
    exit(1)

if not os.path.exists(f"cpp/{STANDARD}/test/rules/{RULE}"):
    print (f"Rule {RULE} within standard {STANDARD} doesn't exist.", file=sys.stderr)
    exit(1)

# get the codeql version 
res = subprocess.run(['codeql', 'version', '--format', 'json'], stdout=subprocess.PIPE)
res_json = json.loads(res.stdout) 
CODEQL_VERSION=res_json["version"]

# get the list of cpp files 
all_files = os.listdir(f"cpp/{STANDARD}/test/rules/{RULE}/")
# make them into a string argument
FILES = ' '.join([f for f in all_files if f.endswith('.cpp')])


BUILD_COMMAND=f"clang++ -std=c++14 -fsyntax-only {FILES}"

ITERATION=0
while os.path.exists(f"databases/{RULE}+{ITERATION}@{CODEQL_VERSION}"):
    ITERATION = ITERATION + 1 

os.system(f"codeql database create -l cpp -s cpp/{STANDARD}/test/rules/{RULE} --command=\"{BUILD_COMMAND}\" databases/{RULE}+{ITERATION}@{CODEQL_VERSION}")
