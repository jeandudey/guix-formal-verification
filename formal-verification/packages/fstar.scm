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

(define-public karamel
  ;; From `git describe --tags'.
  (let ((commit "5dac5b6ef91c63c61d1ebe08071b32fae7e01d06")
        (revision "869"))
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
                  "081l6bin6dllszwz4kj6ing6r5sbvf6w28y75mam9qj2ac0zxwi7"))))
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
      (license license:asl2.0))))
