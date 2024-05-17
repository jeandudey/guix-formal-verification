;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages fstar)
  #:use-module (formal-verification packages maths)
  #:use-module (formal-verification packages ocaml)
  #:use-module (gnu packages base)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages sphinx)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public fstar
  (package
    (name "fstar")
    (version "2024.01.13")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/FStarLang/FStar")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "18asgrwri2yc0ycs163y2j002fvp8hdb28gdkzf34ji6zw69cd66"))))
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f
           #:make-flags #~(list (string-append "PREFIX=" #$output))
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-after 'unpack 'patch-default-z3
                 (lambda* (#:key inputs #:allow-other-keys)
                   (substitute*
                     "src/smtencoding/FStar.SMTEncoding.Z3.fst"
                     (("Platform\\.exe \"z3\"")
                      (string-append "Plaform.exe \""
                                     (search-input-file inputs "bin/z3")
                                     "\"")))
                   (substitute*
                     "ocaml/fstar-lib/generated/FStar_SMTEncoding_Z3.ml"
                     (("FStar_Platform\\.exe \"z3\"")
                      (string-append "FStar_Platform.exe \""
                                     (search-input-file inputs "bin/z3")
                                     "\""))))))))
    (native-inputs
     (list dune
           ocaml
           ocaml-menhir))
    (propagated-inputs
     (list gmp
           ocaml-batteries
           ocaml-memtrace
           ocaml-pprint
           ocaml-ppx-deriving
           ocaml-ppx-deriving-yojson
           ocaml-process
           ocaml-sedlex
           ocaml-stdint
           ocaml-zarith))
    (inputs
     (list z3-4.8.5))
    (home-page "https://www.fstar-lang.org/")
    (synopsis "Proof-oriented programming language")
    (description "F* (pronnounced F star) is a general-purpose proof-oriented
programming language, supporting both functional and effectful programing.
It combines the expressive power of dependent types with proof automation
based on @acronym{SMT, Satisfiability Modulo Theories} solving and
tactic-based interactive theorem proving.

F* programs compile, by default, to OCaml.  Various fragments of F* can also be
extracted to F#, C or WebAssembly by a tool called KaRaMeL, or to assmebly
using the Vale toolchain.")
    (license license:asl2.0)))
