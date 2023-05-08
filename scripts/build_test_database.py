import sys
import shutil 
import os 
import subprocess
import json 

if len(sys.argv) < 4:
    print ("Usage: build_test_database.py LANGUAGE STANDARD RULE", file=sys.stderr)
    exit(1)

LANGUAGE=sys.argv[1]
STANDARD=sys.argv[2]
RULE=sys.argv[3]

if shutil.which("codeql") is None:
    print ("Please install codeql.", file=sys.stderr)
    exit(1)

if LANGUAGE == "cpp":
    compiler = "clang++"
elif LANGUAGE == "c":
    compiler = "clang"
else:
    exit(f"Unknown language {LANGUAGE}")

if shutil.which(compiler) is None:
    print (f"Please install {compiler}", file=sys.stderr)
    exit(1)


# check the database directory
if os.path.exists('databases') and not os.path.isdir('databases'):
    print ("Please delete the file 'databases' in your home directory before continuing.", file=sys.stderr)
    exit(1)
elif not os.path.exists('databases'):
    print ("Creating database directory in current working directory...")
    os.mkdir('databases') 

# check the standard

if not os.path.exists(f"{LANGUAGE}/{STANDARD}"):
    print (f"Standard {STANDARD} doesn't exist.", file=sys.stderr)
    exit(1)

if not os.path.exists(f"{LANGUAGE}/{STANDARD}/test/rules/{RULE}"):
    print (f"Rule {RULE} within standard {STANDARD} doesn't exist.", file=sys.stderr)
    exit(1)

# get the codeql version 
res = subprocess.run(['codeql', 'version', '--format', 'json'], stdout=subprocess.PIPE)
res_json = json.loads(res.stdout) 
CODEQL_VERSION=res_json["version"]

# get the list of cpp files 
all_files = os.listdir(f"{LANGUAGE}/{STANDARD}/test/rules/{RULE}/")
# make them into a string argument

if LANGUAGE == "cpp":
    FILES = ' '.join([f for f in all_files if f.endswith('.cpp')])
    BUILD_COMMAND=f"clang++ -std=c++14 -fsyntax-only {FILES}"

elif LANGUAGE == "c":
    FILES = ' '.join([f for f in all_files if f.endswith('.c')])
    BUILD_COMMAND=f"clang -fsyntax-only {FILES}"

ITERATION=0
while os.path.exists(f"databases/{RULE}+{ITERATION}@{CODEQL_VERSION}"):
    ITERATION = ITERATION + 1 

os.system(f"codeql database create -l cpp -s {LANGUAGE}/{STANDARD}/test/rules/{RULE} --command=\"{BUILD_COMMAND}\" databases/{RULE}+{ITERATION}@{CODEQL_VERSION}")
