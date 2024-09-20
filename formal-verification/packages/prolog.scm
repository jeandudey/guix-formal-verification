;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages prolog)
  #:use-module (formal-verification packages serialization)
  #:use-module (gnu packages ocaml)
  #:use-module (guix build-system dune)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public elpi
  (package
    (name "elpi")
    (version "1.18.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/LPCIC/elpi")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0xkq1l4s4kvkwd4x0zjvqn4gs7vkrh5x7hk611r74yq3yiwlj06f"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-menhir
           ocaml-ppx-deriving
           ocaml-re
           ocaml-yojson))
    (inputs
     (list ocaml-easy-format     ; Propagate on ocaml-biniou.
           ocaml-camlp-streams)) ; Likewise.
    (native-inputs (list atd))
    (home-page "https://github.com/LPCIC/elpi")
    (synopsis "Embeddable λProlog interpreter")
    (description "This package provides the @acronym{ELPI, Embeddable Lambda
Prolog Interpreter} that can be embedded into applications written in the
OCaml programming language.  It comes with an @acronym{API, Application
Programming Interface} for the interpreter and with a @acronym{FFI, Foreign
Function Interface} for defining built-in predicates and data types, as well
as quotations and similar interfaces that are useful to adapt the language to
the desired application.")
    (license license:lgpl2.1+)))
