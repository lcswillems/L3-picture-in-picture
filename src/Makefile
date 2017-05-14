OCAMLBUILD=ocamlbuild -classic-display \
			-tags annot,debug,thread \
			-libs unix,graphics
TARGET=native

pip:
	$(OCAMLBUILD) pip.$(TARGET)

example:
	$(OCAMLBUILD) example.$(TARGET)

clean:
	rm -rf _build *.$(TARGET)