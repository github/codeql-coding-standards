.PHONY: format check install help

check:
	black --check --diff *.py

compile:
	python3 -m py_compile *.py

format:
	black *.py

help:
	@echo "Available targets:"
	@echo "  install  - Install black formatter"
	@echo "  format   - Format all Python files in this directory"
	@echo "  check    - Check formatting without making changes"

install:
	pip install -r requirements.txt

