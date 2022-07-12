CODEQL=codeql
SEARCH_PATH?=$(PWD)/../../codeql_modules/codeql
.PHONY: all clean
all: cxx14-stdlib-macros.json cxx14-stdlib-objects.json cxx14-stdlib-functions.json

%.json: %.bqrs
	$(CODEQL) bqrs decode --format=json -o $@ $<
%.bqrs: queries/%.ql cxx14-stdlib-db
	$(CODEQL) query run --search-path=$(SEARCH_PATH) -d cxx14-stdlib-db -o $@ $<
cxx14-stdlib-db:
	$(CODEQL) database create -l cpp -s source -c "make clean all" $@

clean:
	- rm -r cxx14-stdlib-db