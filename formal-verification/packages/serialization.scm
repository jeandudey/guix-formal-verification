;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages serialization)
  #:use-module (gnu packages check)
  #:use-module (gnu packages dlang)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-check)
  #:use-module (gnu packages python-xyz)
  #:use-module (guix build-system dune)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public atd
  (package
    (name "atd")
    (version "2.15.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ahrefs/atd")
                     (commit version)))
              (file-name (git-file-name name version))
              (modules '((guix build utils)))
              (snippet
               #~(for-each delete-file (find-files "." "\\.jar$")))
              (sha256
               (base32
                "037wx51nnygyb28dfzbf3hfzsbpbhvbqxljr6bc2d17vsdxclch1"))))
    (build-system dune-build-system)
    (arguments
     (list ; ldc does not compile for 32 bit.
           #:tests? (target-64bit?)
           #:phases
           #~(modify-phases %standard-phases
               ;; FIXME: Some tests are disabled due to missing dependencies.
               (add-after 'unpack 'delete-dune-files
                 (lambda _
                   (for-each delete-file '("atdj/test/dune"
                                           "atds/test/dune"))))
               ;; D compiler needs this to build tests.
               (add-before 'build 'set-CC-environment-variable
                 (lambda _
                   (setenv "CC" #$(cc-for-target)))))))
    (native-inputs
     (append (if (target-64bit?) (list ldc) '())
             (list ocaml-alcotest
                  ocaml-menhir
                  python-flake8
                  python-jsonschema
                  python-minimal
                  python-mypy
                  python-pytest)))
    (propagated-inputs (list ocaml-biniou ocaml-yojson))
    (inputs (list ocaml-camlp-streams
                  ocaml-cmdliner
                  ocaml-easy-format
                  ocaml-re))
    (home-page "https://github.com/ahrefs/atd")
    (synopsis "Static types for JSON APIs")
    (description "This package provides @acronym{ATD, Adaptable Type
Definitions}, it is a syntax for defining cross-language data types.  It is
used as an input to generate efficient and type-safe serializers,
de-serailizers and validators.  The following programming languages are
supported and their corresponding binaries: 

@itemize
@item C++: @code{atdcpp}.
@item D: @code{atdd}.
@item Java: @code{atdj}.
@item OCaml and Melange: @code{atdgen}.
@item Python: @code{atdpy}.
@item Scala: @code{atds}.
@item TypeScript: @code{atdts}.
@end itemize

Also tools to work with ATD files are provided:

@itemize
@item The @code{atdcat} program with the @code{-jsonschema} argument can be
used to translate from ATD definitions to a JSON schema.
@item The @code{atddiff} program can be used to compare two revisions of an
ATD file and report incompatibilities.
@end itemize")
    (license license:bsd-3)))
