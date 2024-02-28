import sys
import shutil 
import os 
import subprocess
import json 
from pathlib import Path

if len(sys.argv) != 4 and len(sys.argv) != 2:
    print ("Usage: build_test_database.py TEST_FILE | LANGUAGE STANDARD RULE", file=sys.stderr)
    exit(1)

if len(sys.argv) == 4:
    LANGUAGE=sys.argv[1]
    STANDARD=sys.argv[2]
    RULE=sys.argv[3]

if len(sys.argv) == 2:
    TEST_FILE_PATH=Path(sys.argv[1])
    if not TEST_FILE_PATH.exists():
        print(f"The test file {TEST_FILE_PATH} does not exist!", file=sys.stderr)
        exit(1)
    RULE_PATH=TEST_FILE_PATH.parent
    while True:
        if len(list(RULE_PATH.glob("*.expected"))) > 0:
            break
        if RULE_PATH.parent != RULE_PATH:
            RULE_PATH = RULE_PATH.parent
        else:
            print(f"The test file {TEST_FILE_PATH} is not a test because we couldn't find an expected file!", file=sys.stderr)
            exit(1)
    RULE=RULE_PATH.name
    TESTS_PATH=RULE_PATH.parent.parent
    if TESTS_PATH.name != "test":
        print(f"The test file {TEST_FILE_PATH} is not in the expected test layout, cannot determine standard or language!", file=sys.stderr)
        exit(1)

    STANDARD_PATH=TESTS_PATH.parent
    STANDARD=STANDARD_PATH.name

    LANGUAGE_PATH=STANDARD_PATH.parent
    LANGUAGE=LANGUAGE_PATH.name

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
