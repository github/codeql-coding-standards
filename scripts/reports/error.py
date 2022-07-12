import sys


def failure(msg, err=None):
    print(msg, file=sys.stderr)

    if err:
        if err.reason:
            print("==== reason ====", file=sys.stderr)
            print(err.reason, file=sys.stderr)
        if err.returncode:
            print("==== returncode ====", file=sys.stderr)
            print(err.returncode, file=sys.stderr)
        if err.stdout:
            print("==== stdout ====", file=sys.stderr)
            print(err.stdout, file=sys.stderr)
        if err.stdout:
            print("==== stderr ====", file=sys.stderr)
            print(err.stderr, file=sys.stderr)
    sys.exit(1)
