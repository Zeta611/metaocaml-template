(lang dune 3.19)

(name metaocaml_template)

(generate_opam_files true)

(package
 (name metaocaml_template)
 (depends
  ocaml
  (ocaml-variants
   (= 5.3.0+BER))
  dune
  ocamlfind))
