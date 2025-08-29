CODEQL=codeql
.PHONY: all clean
all: libraryFunctionModel.json libraryObjectModel.json libraryMemberVariableModel.json libraryTypeModel.json

%.json: %.bqrs
	$(CODEQL) bqrs decode --format=json -o $@ $<
%.bqrs: queries/%.ql cxx14-stdlib-db
	$(CODEQL) query run -d cxx14-stdlib-db -o $@ $<
cxx14-stdlib-db:
	$(CODEQL) database create -l cpp -s source -c "make clean all" $@

clean:
	- rm -r cxx14-stdlib-db