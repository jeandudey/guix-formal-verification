;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages rust)
  #:use-module (formal-verification packages ocaml)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages multiprecision)
  #:use-module (guix build-system dune)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public ocaml-charon
  (let ((revision "0")
        (commit "bb09c0eb02f3de84661f802cb14a9a1f94d075c7"))
    (package
      (name "ocaml-charon")
      (version (git-version "0.1.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/AeneasVerif/charon")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1kzjlg87v4m7s1mg8qd0w9hh4qfv44nd429n44j6jr81hhdjjh75"))))
      (build-system dune-build-system)
      (arguments
       (list #:tests? #f
             #:phases
             #~(modify-phases %standard-phases
                 (add-after 'unpack 'patch-test-libraries
                   (lambda _
                     (substitute* "charon-ml/tests/dune"
                       (("libraries core charon")
                        "libraries core charon re")))))))
      (inputs
       (list gmp
             ocaml-core
             ocaml-easy-logging
             ocaml-menhir
             ocaml-ppx-deriving
             ocaml-re
             ocaml-unionfind
             ocaml-visitors
             ocaml-yojson
             ocaml-zarith))
      (home-page "https://github.com/AeneasVerif/charon")
      (synopsis "Deserialization and printing of ULLBC ASTs")
      (description "This package provides a OCaml library that deserializes
and allows the @acronym{AST, Abstract Syntax Tree} of @acronym{ULLBC,
Unstructured Low-Level Borrow Calculus}.")
      (license license:asl2.0))))
