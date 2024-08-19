;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages coq)
  #:use-module (formal-verification packages prolog)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages coq)
  #:use-module (gnu packages ocaml)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

;; FIXME: Using this version because we are stuck with Coq 8.17 as Why3
;; doesn't support Coq 8.19 yet.
(define-public coq-elpi
  (package
    (name "coq-elpi")
    (version "1.18.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/LPCIC/coq-elpi")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0rkk84d25yy1p1rzzbf0w0glnykkxs0lkz4r5wi8kqd23ab8xw6r"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib")
                   (string-append "COQPLUGININSTALL=" #$output
                                  "/lib/ocaml/site-lib"))
           #:tests? #f ;; FIXME.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-after 'unpack 'patch-tests
                 (lambda _
                   (substitute* "Makefile"
                     (("\\$\\(MAKE\\) test-core") "")))))))
    (native-inputs (list coq ocaml-findlib ocaml which))
    (propagated-inputs (list elpi))
    (inputs (list ocaml-stdlib-shims ocaml-zarith))
    (home-page "https://github.com/LPCIC/coq-elpi")
    (synopsis "Coq plugin to define commands and tactics in λProlog")
    (description "This package provides Coq-ELPI, a Coq plugin providing the
@acronym{ELPI, Embeddable Lambda Prolog Interpreter} language to define new
commands and tactics.  For that purpose it provides an embedding of Coq's
terms into λProlog using the @acronym{HOAS, Higher-Order Abstract Syntax}
approach.  It also exports to ELPI a comprehensive set of Coq's primitives,
so that one can print a message, access the environment of theorems and data
types, define a new constant, declare implicit arguments, type classes
instances, and so on.")
    (license license:lgpl2.1+)))

;; FIXME: Using this version because we are stuck with Coq 8.17 as Why3
;; doesn't support Coq 8.19 yet.
(define-public coq-hierarchy-builder
  (package
    (name "coq-hierarchy-builder")
    (version "1.6.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/math-comp/hierarchy-builder")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0j3jws7ls79xnh4ghz2qpfcibpsa0fqywl3mj9xazf4fyz93djqk"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "DESTDIR=" #$output)
                   (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ;; all target runs the test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq ocaml which))
    (inputs (list ocaml-zarith)) ; Propagate in Coq.
    (propagated-inputs (list coq-elpi))
    (home-page "https://github.com/math-comp/hierarchy-builder")
    (synopsis "Declare hierarchy of algebraic data structures in Coq")
    (description "This package provides the @acronym{HB, Hierarchy Builder}
commands to declare a hierarchy of algebraic structures (or interfaces using
the computer science glossary) for the Coq system.

Given a structure, one can develop its theory, and that theory becomes
automatically applicable to all the examples of the structure.

Commands compile down to Coq modules, sections, records, coercions,
canonical structure instances and notations following the packed classes
disciplines which is at the core of the
@url{https://github.com/math-comp/math-comp, Mathematical Components} library.
All that complexity is hidden behind a few concepts and a few declarative Coq
commands.")
    (license license:expat)))

(define-public coq-lex
  (let ((revision "0")
        (commit "ded4153e73d71d08de300f226823bf7176949e01"))
    (package
      (name "coq-lex")
      (version (git-version "0.0.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://gitlab.inria.fr/wouedrao/coqlex")
                       (commit commit)))
                (file-name (git-file-name name version))
                (modules '((guix build utils)))
                (snippet
                 ;; Remove bundled coq-regexp. We provide it as a package
                 ;; with the patches from Coqlex.
                 #~(delete-file-recursively "regexp_opt"))
                (sha256
                 (base32
                  "11xzsg0ay1g89lfzrl9f3h40cfy84kwligxbr8xnl82l511wadhr"))
                (patches
                 (search-patches
                  "patches/coq-lex-external-coq-regexp.patch"))))
      (build-system gnu-build-system)
      (arguments
       (list #:make-flags
             #~'("EXEC=coqlex")
             #:parallel-build? #f ;; Out of order build causes a failure.
             #:tests? #f ;; No clear way to test.
             #:phases
             #~(modify-phases %standard-phases
                 (delete 'configure)
                 (replace 'install
                   (lambda _
                     (let ((CoqlexLib (string-append #$output "/share/CoqlexLib"))
                           (bin (string-append #$output "/bin")))
                       (install-file "coqlex" bin)

                       (mkdir-p CoqlexLib)
                       (for-each (lambda (file)
                                   (install-file file CoqlexLib))
                                 '("CoqLexUtils.v" "LexerDefinition.v"
                                   "MatchLen.v" "MatchLenSimpl.v" "RValues.v"
                                   "RegexpSimpl.v" "ShortestLen.v"
                                   "ShortestLenSimpl.v" "SubLexeme.v"))))))))
      (native-inputs (list coq ocaml ocaml-menhir))
      (inputs (list coq-menhirlib coq-regexp))
      (home-page "https://gitlab.inria.fr/wouedrao/coqlex")
      (synopsis "Formally verified lexical analyzer generator")
      (description "Coqlex is a formally verified tool for generating
scanners.  A scanner, sometimes called a tokenizer, is a program which
recognizes lexical patterns in text.  The coqlex program reads user specified
files for a description of a scanner to generate.  Coqlex generates a Coq
source file.")
      (license license:expat))))

(define-public coq-mathcomp-2
  (package
    (inherit coq-mathcomp)
    (name "coq-mathcomp")
    (version "2.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/math-comp/math-comp")
                     (commit (string-append "mathcomp-" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0v9xk013zymas3z9ikx0vwdc6yiv7d2lasjbncm30dg0my7bg7yw"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:test-target "test-suite"
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-after 'unpack 'change-directory
                 (lambda _
                   (chdir "mathcomp"))))))
    (native-inputs (list coq ocaml which))
    (propagated-inputs (list coq-hierarchy-builder))
    (inputs (list ocaml-zarith)))) ; Propagate in Coq.

(define-public coq-menhirlib
  (package
    (inherit ocaml-menhir)
    (name "coq-menhirlib")
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f ;; No test suite.
           #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'change-directory
                 (lambda _
                   (chdir "coq-menhirlib")))
               (delete 'configure))))
    (native-inputs (list coq))
    (propagated-inputs (list))
    (inputs (list))))

(define-public coq-regexp
  (let ((revision "0")
        (commit "da6d250506ea667266282cc7280355d13b27c68d"))
    (package
      (name "coq-regexp")
      (version (git-version "0.0.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/coq-contribs/regexp")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1s1rxrz6yq8j0ykd2ra0g9mj8ky2dvgim2ysjdn5yz514b36mc7x"))
                (patches
                 (search-patches
                  "patches/coq-regex-coqlex-additions.patch"))))
      (build-system gnu-build-system)
      (arguments
       (list #:make-flags
             #~(list (string-append "COQLIBINSTALL=" #$output
                     "/lib/coq/user-contrib"))
             #:tests? #f
             #:phases
             #~(modify-phases %standard-phases
                 (delete 'configure))))
      (native-inputs (list coq))
      (home-page "https://github.com/coq-contribs/regexp")
      (synopsis "")
      (description "")
      ;; TODO: License says on file://description that it is LGPL, however
      ;; version is not specified.
      (license license:lgpl3))))
