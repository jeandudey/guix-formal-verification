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

(define-public everparse
  (package
    (name "everparse")
    (version "2024.08.23")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/project-everest/everparse")
                     (commit (string-append "v" version))))
              (modules '((guix build utils)))
              (snippet
                ;; Contains generated files.
                #~(delete-file-recursively "doc/3d-snapshot"))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1acs5zfxbbd75rqv7djzdpynzcqsvqx30yprdsnywvlra0jm7ifd"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "KRML_HOME="
                                  #$(this-package-input "karamel")))
           #:tests? #f
           #:test-target "test"
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-after 'unpack 'patch-karamel-home
                 (lambda _
                   (substitute* (find-files "." "^Makefile.*$")
                     (("\\$\\(KRML_HOME\\)/krmllib")
                      "$(KRML_HOME)/lib/krml")
                     (("\\$\\(KRML_HOME\\)/krml")
                      "$(KRML_HOME)/bin/krml"))))
               (add-after 'patch-karamel-home 'patch-clang-format
                 (lambda _
                   (substitute* "src/3d/ocaml/Batch.ml"
                     (("\"clang-format%s\"")
                      (string-append
                        "\""
                        #$(file-append (this-package-input "clang")
                                       "bin/clang-format")
                        "%s\"")))))
               (add-after 'patch-karamel-home 'patch-make
                 (lambda _
                   (substitute* "src/3d/Main.fst"
                     (("\"make\"")
                      (string-append
                        "\""
                        #$(file-append (this-package-input "make")
                                       "bin/make")
                        "\"")))))
               (replace 'install
                 (lambda _
                   (let ((bin (string-append #$output "/bin"))
                         (fstar (string-append #$output "/lib/fstar")))
                     (mkdir-p bin)
                     (mkdir-p (dirname fstar))

                     (install-file "bin/qd.exe" bin)
                     (install-file "bin/3d.exe" bin)

                     (copy-recursively "src/lowparse" fstar))))
               ;(add-after 'install 'wrap-program
               ;  (lambda _
               ;    (wrap-program (string-append #$output "/bin/3d.exe")
               ;      `("FSTAR_HOME" = (,#$(this-package-input "fstar")))
               ;      `("KRML_HOME" = (,#$(this-package-input "karamel")))
               ;      `("EVERPARSE_HOME" = (,#$output)))))
               )))
    (native-inputs
     (list dune
           fstar
           ocaml
           ocaml-findlib
           ocaml-menhir
           which))
    (inputs
     (list clang
           fstar
           karamel
           gnu-make
           ocaml-batteries
           ocaml-hex
           ocaml-re
           ocaml-sha
           ocaml-sexplib))
    (home-page "https://project-everest.github.io/everparse/")
    (synopsis "Generate parsers of binary formats")
    (description "This package provides EverParse, a tool to generate
verified secure parsers from @acronym{DSL, Domain Specific Language} format
specification languages.  It consists of LowParse, a verified combinator
library, and QuackyDucky, an untrusted message format specification language
compiler.")
    ;; FIXME:
    ;;
    ;;  File "rfc_fstar_compiler.ml", line 136, characters 41-51:
    ;;  136 |   | "uint32" | "uint32_le" -> 4, 4, Some 4294967295
    (supported-systems %64bit-supported-systems)
    (license license:asl2.0)))

(define-public fstar
  (package
    (name "fstar")
    (version "2024.09.05")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/FStarLang/FStar")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1ckx08ap54lrx1fkiddgkhlj0m84bmqabr5fihhq8p7njdd3m869"))))
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

(define-public karamel
  ;; From `git describe --tags'.
  (let ((commit "a37aecdea20deee2f6d7536de655b75069310c8f")
        (revision "1049"))
    (package
      (name "karamel")
      (version (git-version "1.0.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/FStarLang/karamel")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "0b786jh5gzvv6r3mkxpsckyw44jq86d3wk45cfic58f56prxpvhm"))))
      (build-system gnu-build-system)
      (arguments
       (list #:tests? #f ;; TODO.
             #:make-flags #~(list (string-append "CC=" #$(cc-for-target))
                                  (string-append "PREFIX=" #$output))
             #:phases
             #~(modify-phases %standard-phases
                 ;; Avoid using git to create version file.
                 (replace 'configure
                   (lambda _
                     (with-output-to-file "lib/Version.ml"
                       (lambda ()
                         (format #t "let version = ~s~%" #$version)))))
                 (add-after 'install 'wrap-program
                   (lambda _
                     (wrap-program (string-append #$output "/bin/krml")
                       `("FSTAR_HOME" = (,#$(this-package-input "fstar")))))))))
      (native-inputs
       (list dune
             fstar
             ocaml
             ocaml-findlib
             ocaml-menhir
             which))
      (propagated-inputs
       (list ocaml-fix
             ocaml-uucp
             ocaml-visitors
             ocaml-wasm))
      (inputs (list fstar))
      (home-page "https://github.com/FStarLang/karamel")
      (synopsis "Extract F* programs to C")
      (description "KaRaMeL (formerly known as KReMLin) is a tool to extract
F* code to readable C code.")
      (license (list license:asl2.0 license:expat)))))
