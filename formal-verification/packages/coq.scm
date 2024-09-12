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
  #:use-module (guix utils)
  #:use-module (nongnu packages coq)
  #:use-module (ice-9 match))

(define-public compcert-for-vst
  (package
    (inherit compcert)
    (name "compcert-for-vst")
    (arguments
     (list #:configure-flags
           #~(list "-coqdevdir"
                   (string-append #$output "/lib/coq/user-contrib/compcert")
                   "-clightgen"
                   "-ignore-coq-version"
                   "-install-coq-dev"
                   "-use-external-Flocq"
                   "-use-external-MenhirLib")
           #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (replace 'configure
                 (lambda* (#:key configure-flags #:allow-other-keys)
                   (apply invoke "./configure"
                          #$(match (or (%current-target-system) (%current-system))
                              ("armhf-linux" "arm-eabihf")
                              ("i686-linux" "x86_32-linux")
                              (s s))
                          "-prefix" #$output
                          configure-flags))))))
    (propagated-inputs (list coq-flocq coq-menhirlib))))

(define-public coq-ceres
  (package
    (name "coq-ceres")
    (version "0.4.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/Lysxia/coq-ceres")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "080nldsxmrxdan6gd0dvdgswn3gkwpy5hdqwra6wlmh8zzrs9z7n"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ;; No test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq))
    (home-page "https://github.com/Lysxia/coq-ceres")
    (synopsis "S-expression serialization for Coq")
    (description "This package provides a S-expression serialization and
de-serialization for Coq as an alternative to debug data structures.")
    (license license:expat)))

;; FIXME: Using this version because we are stuck with Coq 8.18 as Why3
;; doesn't support Coq 8.20 yet, also 2.x versions don't build with
;; Coq 8.18, so use 1.19.3 which is the latest one known to work.
(define-public coq-elpi
  (package
    (name "coq-elpi")
    (version "1.19.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/LPCIC/coq-elpi")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "05zw0dgvpxxc4f9zmkaw8wlz301612wbly0m2n26zdcklm9q7m86"))))
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

(define-public coq-ext-lib
  (package
    (name "coq-ext-lib")
    (version "0.12.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/coq-community/coq-ext-lib")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0ikc83qcnghd8mlzdabdr1akcfclsbss2anp0wx0df0jk5pfa94m"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ;; all target runs the test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq))
    (home-page "https://github.com/coq-community/coq-ext-lib")
    (synopsis "Collection of useful theories in Coq")
    (description "This package provides a generic collection of useful
theories for Coq that can be used in other developments.")
    (license license:bsd-2)))

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

(define-public coq-json
  (package
    (name "coq-json")
    (version "0.1.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/liyishuai/coq-json")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "07argz5jszkhd98bhzfisb50qz9af8whxq590y0pzf88dv6l0jcl"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ;; No test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq ocaml-menhir))
    (propagated-inputs (list coq-ext-lib coq-menhirlib coq-parsec))
    (home-page "https://github.com/liyishuai/coq-json")
    (synopsis "JSON encoder and decoder for Coq")
    (description "This package provides a JSON encoder and decoder for Coq.")
    (license license:bsd-3)))

(define-public coq-kami
  (let ((revision "0")
        (commit "de880ce21dc927b050e33e803c903238978f8021"))
    (package
      (name "coq-kami")
      (version (git-version "0.0.3" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/mit-plv/kami")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1lhavmrcqdcd1psskqifgnfl8ypi741lng32ms4wch3cwnhdqici"))))
      (build-system gnu-build-system)
      (arguments
       (list #:make-flags
             #~(list (string-append "COQLIBINSTALL=" #$output
                                    "/lib/coq/user-contrib"))
             #:tests? #f ; No test suite.
             #:phases
             #~(modify-phases %standard-phases
                 (delete 'configure))))
      (native-inputs (list coq))
      (home-page "https://github.com/mit-plv/kami")
      (synopsis "Parametric hardware specification for Coq")
      (description "Kami is a platform for high-level parametric hardware
specification and its modular verification.")
      (license license:expat))))

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
      (propagated-inputs (list coq-regexp))
      (inputs (list coq-menhirlib))
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

(define-public coq-mathcomp-algebra-tactics
  (package
    (name "coq-mathcomp-algebra-tactics")
    (version "1.2.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/math-comp/algebra-tactics")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0nwj563pkq126323dl8pp67cl3zx6iklgha7qk2fggy38xa3brza"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:test-target "test-suite"
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq ocaml))
    (propagated-inputs (list coq-elpi coq-mathcomp-2 coq-mathcomp-zify))
    (inputs (list ocaml-zarith)) ; Propagate in Coq.
    (home-page "https://github.com/math-comp/algebra-tactics")
    (synopsis "Algebra tactics for Mathematical Components Coq library")
    (description "This library provides @code{ring}, @code{field}, @code{lra},
@code{nra}, and @code{psatz} tactics for the Mathematical Components library.
These tactics use the algebraic structures defined in the MathComp library and
their canonical instances for the instance resolution, and do not require any
special instance declaration, like the `Add Ring` and `Add Field` commands.
Therefore, each of these tactics works with any instance of the respective
structure, including concrete instances declared through Hierarchy Builder,
abstract instances, and mixed concrete and abstract instances, e.g.,
@code{int * R} where `R` is an abstract commutative ring.  Another key feature
of Algebra Tactics is that they automatically push down ring morphisms and
additive functions to leaves of ring/field expressions before applying the
proof procedures.")
    (license license:cecill-b)))

(define-public coq-mathcomp-analysis
  (package
    (name "coq-mathcomp-analysis")
    (version "1.3.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/math-comp/analysis")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "18bx73mfac189anqxgghc4c7z4qv1knchrm23hrq4q9ia3i304xm"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq ocaml which))
    (propagated-inputs
     (list coq-mathcomp-2
           coq-mathcomp-bigenough-2
           coq-mathcomp-finmap-2))
    (inputs (list ocaml-zarith)) ; Propagate in Coq.
    (home-page "https://github.com/math-comp/analysis")
    (synopsis "Real analysis library for Coq")
    (description "This library provides real analysis library for Coq, using
the Mathematical Components library.")
    (license license:cecill-c)))

;; FIXME: The upstream Guix version uses the version 1 of mathcomp.
(define-public coq-mathcomp-bigenough-2
  (package
    (inherit coq-mathcomp-bigenough)
    (name "coq-mathcomp-bigenough-2")
    (version "1.0.1")
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ; No test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq ocaml))
    (propagated-inputs (list coq-mathcomp-2))
    (inputs (list ocaml-zarith)))) ; Propagate in Coq.

(define-public coq-mathcomp-finmap-2
  (package
    (inherit coq-mathcomp-finmap)
    (name "coq-mathcomp-finmap")
    (version "2.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/math-comp/finmap")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "15mnhacy60kk3vrq9p6h08lhcjfpvh9bgpcw1wz2l3sm2yg1q7c2"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ; No test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq ocaml))
    (propagated-inputs (list coq-mathcomp-2))
    (inputs (list ocaml-zarith)))) ; Propagate in Coq.

(define-public coq-mathcomp-zify
  (package
    (name "coq-mathcomp-zify")
    (version "1.5.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/math-comp/mczify")
                     (commit (string-append version "+2.0+8.16"))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "18qfzm5hsxr5mm6ip4krcf9bi1aab0k83qzrd0x5f66xyld5i03f"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:test-target "test-suite"
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq ocaml))
    (propagated-inputs (list coq-elpi coq-mathcomp-2))
    (inputs (list ocaml-zarith))
    (home-page "https://github.com/math-comp/mczify")
    (synopsis "Micromega tactics for Mathematical Components Coq library")
    (description "This package provides a Coq library extending the
@code{zify} tactic to enable the use of arithmetic solvers of Coq for
goals stated with the definitions of the Mathematical Components library.")
    (license license:cecill-b)))

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

(define-public coq-parsec
  (package
    (name "coq-parsec")
    (version "0.1.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/liyishuai/coq-parsec")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0402pdp6mn161ligvlzsga3wqjrmxmrbj99v0k8a1wqp5ga23pa0"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ;; No test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq))
    (propagated-inputs (list coq-ceres coq-ext-lib))
    (home-page "https://github.com/liyishuai/coq-parsec")
    (synopsis "Monadic parser combinator library for Coq")
    (description "This package provides a monadic parser combinator library
for Coq.")
    (license license:expat)))

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

(define-public coq-vst
  (package
    (name "coq-vst")
    (version "2.14")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/PrincetonUniversity/VST")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "137c04a8c3qr5y83v1jdpx1gbp3qf9mzmdjjw9r7d6cm1mjkaxrl"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "COMPCERT=inst_dir"
                   (string-append "COMPCERT_INST_DIR="
                                  #$(this-package-input "compcert-for-vst")
                                  "/lib/coq/user-contrib/compcert/")
                   (string-append "INSTALLDIR=" #$output
                                  "/lib/coq/user-contrib/VST"))
           #:test-target "test"
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq))
    (propagated-inputs (list compcert-for-vst))
    (home-page "https://vst.cs.princeton.edu/")
    (synopsis "Toolset for proving functional correctness of C programs")
    (description "This package provides the @acronym{VST, Verified Software
Toolchain}, for proving the functional correctness of C programs.")
    (license license:bsd-2)))

(define-public coq-util
  (package
    (name "coq-util")
    (version "0.0.5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mit-plv/coqutil")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1b3fyb3npx950q9m5w23hylffgqa28c5ahk911p67n7w1804himy"))))
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
    (home-page "https://github.com/mit-plv/coqutil")
    (synopsis "Utility library for Coq")
    (description "This package provides various utilities for Coq.")
    (license license:expat)))
