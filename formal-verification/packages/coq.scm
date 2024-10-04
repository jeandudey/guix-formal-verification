;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages coq)
  #:use-module (formal-verification packages prolog)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages coq)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages python)
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

(define-public coq-bedrock2
  (package
    (name "coq-bedrock2")
    (version "0.0.8")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mit-plv/bedrock2")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1ay5hnr7yg6x9m2xbsrwwly6zg8grqjf0kqpaw91h81vzflsqr78"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "EXTERNAL_DEPENDENCIES=1"
                   "EXTERNAL_COQUTIL=1"
                   (string-append "CC=" #$(cc-for-target))
                   (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ;; No test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-before 'build 'change-directory
                 (lambda _
                   (chdir "bedrock2"))))))
    (native-inputs (list coq python-minimal))
    (propagated-inputs (list coq-util))
    (home-page "https://github.com/mit-plv/bedrock2")
    (synopsis "Language for low-level programming in Coq")
    (description "This package provides the definition of the Bedrock2
language for low-level programming.")
    (license license:expat)))

(define-public coq-bedrock2-compiler
  (package
    (inherit coq-bedrock2)
    (name "coq-bedrock2-compiler")
    (arguments
     (list #:make-flags
           #~(list "EXTERNAL_DEPENDENCIES=1"
                   "EXTERNAL_COQUTIL=1"
                   "EXTERNAL_RISCV_COQ=1"
                   (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ;; No test suite.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-before 'build 'change-directory
                 (lambda _
                   (chdir "compiler"))))))
    (native-inputs (list coq python-minimal))
    (propagated-inputs (list coq-bedrock2 coq-riscv coq-util))
    (synopsis "Compiler for Bedrock2 to RISC-V in Coq")
    (description "This package provides a compiler for the Bedrock2 targeting
RISC-V, using Coq.")))

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
    (version "2.0.0.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/LPCIC/coq-elpi")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1zzblsmrvj9ggx1kgp8xs2s348s6xkmkvd3fl2kn4vfpiklmfafj"))))
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
    (inputs (list ocaml-stdlib-shims))
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

(define-public coq-fcf
  (package
    (name "coq-fcf")
    (version "8.16")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/adampetcher/fcf")
                     (commit (string-append
                               "coq_"
                               (string-replace-substring version "." "_")))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0gdwns0ijwy4hxfvhfyjzp7rhw4l3yjgcrmxvhliyilwk1bqjhm1"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (replace 'configure
                 (lambda _
                   (invoke "coq_makefile"
                           "-f" "_CoqProject"
                           "-o" "Makefile"))))))
    (native-inputs (list coq))
    (home-page "https://github.com/adampetcher/fcf")
    (synopsis "@acronym{FCF, Foundational Cryptography Framework} for Coq")
    (description "This package provides the @acronym{FCF, Foundational
Cryptography Framework} for machine-checked proofs of cryptography for Coq.")
    (license license:asl2.0)))

(define-public coq-hierarchy-builder
  (package
    (name "coq-hierarchy-builder")
    (version "1.7.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/math-comp/hierarchy-builder")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1601sgqb9yhnanjbkvla4dzp7d5xqrlc8gvwh44jgak6k2w9x92s"))))
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

(define-public coq-itree
  (package
    (name "coq-itree")
    (version "5.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/DeepSpec/InteractionTrees")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1ihfq9dynckgbcsk95v8rn9ychkm00dhb7q7f5qzyzqrx7nz78mc"))))
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
    (propagated-inputs (list coq-paco coq-ext-lib))
    (home-page "https://github.com/DeepSpec/InteractionTrees")
    (synopsis "Represent impure and recursive programs in Coq")
    (description "This package provides a library allowing the representation
of impure and recursive programs in Coq with equational reasoning.")
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
        (commit "3ab094327db916f9db7569c8a378113c5d0da748"))
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
                  "0gads2al46ii7h77q20wbjyd41a2c2cvc21ld3mn390irx5vs9rh"))))
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
    (inputs '())
    (propagated-inputs (list coq-hierarchy-builder))))

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

;; FIXME: Compilation of coq-mathcomp-finmap-2 fails to this one does not
;; compile.
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
    (propagated-inputs (list coq-mathcomp-2))))

;; FIXME: Fails to build on 8.18 for some reason.
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
    (propagated-inputs (list coq-mathcomp-2))))

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

(define-public coq-metacoq
  (package
    (name "coq-metacoq")
    (version "1.3.1-8.18")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/MetaCoq/metacoq")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0dk3sn8vfgnzd0wlaxda21vpdk8bjns28rnlwrpsradh1gh2d9ig"))))
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f ;; FIXME.
           #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib")
                   (string-append "COQPLUGININSTALL=" #$output
                                  "/lib/ocaml/site-lib"))
           #:phases
           #~(let ((build (lambda (dir)
                            (lambda args
                              (with-directory-excursion dir
                                (apply (assoc-ref %standard-phases 'build)
                                       args)
                                (apply (assoc-ref %standard-phases 'install)
                                       args))))))
               (modify-phases %standard-phases
                 (replace 'configure
                   (lambda _
                     (invoke "bash" "configure.sh")
                     (setenv "COQPATH"
                             (string-append (getenv "COQPATH") ":" #$output
                                            "/lib/coq/user-contrib"))
                     (setenv "OCAMLPATH"
                             (string-append (getenv "OCAMLPATH") ":" #$output
                                            "/lib/ocaml/site-lib"))))
                 (delete 'build)
                 (add-after 'configure 'build-utils
                   (build "utils"))
                 (add-after 'build-utils 'build-common
                   (build "common"))
                 (add-after 'build-common 'build-template-coq
                   (build "template-coq"))
                 (add-after 'build-template-coq 'build-translations
                   (build "translations"))
                 (add-after 'build-translations 'build-pcuic
                   (build "pcuic"))
                 (add-after 'build-pcuic 'build-template-pcuic
                   (build "template-pcuic"))
                 (add-after 'build-template-pcuic 'build-quotation
                   (build "quotation"))
                 (add-after 'build-quotation 'build-safechecker
                   (build "safechecker"))
                 (add-after 'build-safechecker 'build-safechecker-plugin
                   (build "safechecker-plugin"))
                 (add-after 'build-safechecker-plugin 'build-erasure
                   (build "erasure"))
                 (add-after 'build-erasure 'build-erasure-plugin
                   (build "erasure-plugin"))
                 (delete 'install)))))
    (native-inputs (list ocaml coq))
    (propagated-inputs
     (list coq-equations
           ocaml-stdlib-shims))
    (home-page "https://metacoq.github.io/")
    (synopsis "Formalization of Coq in Coq")
    (description "MetaCoq is a project formalizing Coq in Coq and provinding
tools for manipulation of Coq terms and development of certified Coq plugins
in Coq.")
    (license license:expat)))

(define-public coq-paco
  (package
    (name "coq-paco")
    (version "4.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/snu-sf/paco")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (modules '((guix build utils)))
              (snippet
                #~(for-each delete-file (find-files "src" "g?paco.*\\.v$")))
              (sha256
               (base32
                "1il0mzbvdgmxk6k315ak04j27l7pqazw1s3xxayyk2k17y5jsxk0"))))
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f ;; No test suite.
           #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:phases
           #~(modify-phases %standard-phases
               (add-before 'build 'generate-sources
                 (lambda _
                   (with-directory-excursion "metasrc"
                     (invoke "bash" "./build.sh"))))
               (add-after 'generate-sources 'change-directory
                 (lambda _
                   (chdir "src")))
               (delete 'configure)
               (replace 'install
                 (lambda* (#:key make-flags #:allow-other-keys)
                   (apply invoke "make" "-f" "Makefile.coq" "install" make-flags))))))
    (native-inputs (list coq python-2))
    (home-page "https://github.com/snu-sf/paco")
    (synopsis "Parametric coinduction for Coq")
    (description "Paco is a library for parametric coinduction.")
    (license license:bsd-3)))

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

(define-public coq-prime
  (package
    (name "coq-prime")
    (version "8.18")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/thery/coqprime")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "18a3jswc1aqq7y91sz0f84nvklmkxxnx1gbanq914nmbhw8w3ri8"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "COQBIN="
                   (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f ;; FIXME.
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq))
    (propagated-inputs (list coq-bignums))
    (home-page "https://github.com/thery/coqprime")
    (synopsis "Primer numbers for Coq")
    (description "This package provides a prime number library for Coq.")
    (license license:lgpl2.1)))

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

(define-public coq-rewriter
  (package
    (name "coq-rewriter")
    (version "0.0.11")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mit-plv/rewriter")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "131ykd1sl6l45yzxiq3kh69rkgc98sj9qhafl17dj8phr79hx2k9"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "EXTERNAL_BEDROCK2=1"
                   "EXTERNAL_COQUTIL=1"
                   "EXTERNAL_DEPENDENCIES=1"
                   (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib")
                   (string-append "COQPLUGININSTALL=" #$output
                                  "/lib/ocaml/site-lib"))
           #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list ocaml coq))
    (home-page "https://github.com/mit-plv/rewriter")
    (synopsis "Reflective PHOAS rewriting for Coq")
    (description "This package provides a Coq library for reflective
@acronym{PHOAS, Parametric Higher-Order Abstract Syntax} rewriting or
pattern-matching compilation framework for simply-typed equalities and
let-lifting.")
    (license (list license:asl2.0 license:bsd-1 license:expat))))

;; NOTE: Is this considered as a generated source? hs-to-coq fails to build on
;; recent GHC versions and hasn't been maintained in a year, perhaps this code
;; has also been modified manually.
(define-public coq-riscv
  (package
    (name "coq-riscv")
    (version "0.0.5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mit-plv/riscv-coq")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0spikk6rxnpccm044g9cj6jy1jff0mb852ji9nw09c42aryc2lwy"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "-f" "Makefile.coq.all"
                   (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               ;; The Makefile for some reason fails to install the built
               ;; files, so just tell it to generate the Coq Makefile and
               ;; handle it manually.
               (replace 'configure
                 (lambda _
                   (invoke "make" "Makefile.coq.all"
                           "EXTERNAL_COQUTIL=1"
                           "EXTERNAL_DEPENDENCIES=1"))))))
    (native-inputs (list coq))
    (propagated-inputs (list coq-util))
    (home-page "https://github.com/mit-plv/riscv-coq")
    (synopsis "RISC-V specification in Coq")
    (description "This package provides a RISC-V specification for Coq
generated using @code{hs-to-coq}, with manually written Coq code.")
    (license license:bsd-3)))

(define-public coq-rupicola
  (package
    (name "coq-rupicola")
    (version "0.0.10")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mit-plv/rupicola")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "10cmsni96i1a9lb99vyz8g9i5354fa6mjd1xnqnwin1ir7xgh2md"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "EXTERNAL_BEDROCK2=1"
                   "EXTERNAL_COQUTIL=1"
                   "EXTERNAL_DEPENDENCIES=1"
                   (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib"))
           #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list coq))
    (propagated-inputs (list coq-bedrock2 coq-util))
    (home-page "https://github.com/mit-plv/rupicola")
    (synopsis "Gallina to Bedrock2 compiler in Coq")
    (description "This package provides a compiler to convert Gallina to
Bedrock2 in Coq.")
    (license license:expat)))

;; To update this list, run this on the original VCS checkout:
;;
;;   guix shell bash coreutils ripgrep --pure -- \
;;     bash -c "rg 'Module Info.' -l | sort"
;;
;; Then stylize accordingly.
(define %coq-vst-generated
  '("aes/aes.v"
    "atomics/hashtable_atomic.v"
    "atomics/kvnode_atomic.v"
    "atomics/sim_atomics.v"
    "concurrency/threads.v"
    "hmacdrbg/hmac_drbg.v"
    "mailbox/atomic_exchange.v"
    "mailbox/mailbox.v"
    "progs64/append.v"
    "progs64/bin_search.v"
    "progs64/bst.v"
    "progs64/field_loadstore.v"
    "progs64/float.v"
    "progs64/global.v"
    "progs64/incrN.v"
    "progs64/incr.v"
    "progs64/io_mem.v"
    "progs64/io.v"
    "progs64/logical_compare.v"
    "progs64/message.v"
    "progs64/min64.v"
    "progs64/min.v"
    "progs64/nest2.v"
    "progs64/nest3.v"
    "progs64/object.v"
    "progs64/printf.v"
    "progs64/ptr_cmp.v"
    "progs64/revarray.v"
    "progs64/reverse.v"
    "progs64/shift.v"
    "progs64/strlib.v"
    "progs64/sumarray.v"
    "progs64/switch.v"
    "progs64/union.v"
    "progs64/VSUpile/apile.v"
    "progs64/VSUpile/fast/fastapile.v"
    "progs64/VSUpile/fast/fastpile.v"
    "progs64/VSUpile/main.v"
    "progs64/VSUpile/onepile.v"
    "progs64/VSUpile/pile.v"
    "progs64/VSUpile/stdlib.v"
    "progs64/VSUpile/triang.v"
    "progs/append.v"
    "progs/bin_search.v"
    "progs/bst_oo.v"
    "progs/bst.v"
    "progs/cast_test.v"
    "progs/cond.v"
    "progs/dotprod.v"
    "progs/even.v"
    "progs/fib.v"
    "progs/field_loadstore.v"
    "progs/float.v"
    "progs/floyd_tests.v"
    "progs/funcptr.v"
    "progs/global.v"
    "progs/incr2.v"
    "progs/incrN.v"
    "progs/incr.v"
    "progs/insertionsort.v"
    "progs/int_or_ptr.v"
    "progs/io_mem.v"
    "progs/io.v"
    "progs/libglob.v"
    "progs/load_demo.v"
    "progs/logical_compare.v"
    "progs/loop_minus1.v"
    "progs/memmgr/malloc.v"
    "progs/memmgr/mmap0.v"
    "progs/merge.v"
    "progs/message.v"
    "progs/min64.v"
    "progs/min.v"
    "progs/nest2.v"
    "progs/nest3.v"
    "progs/objectSelfFancyOverriding.v"
    "progs/objectSelfFancy.v"
    "progs/objectSelf.v"
    "progs/object.v"
    "progs/odd.v"
    "progs/peel.v"
    "progs/pile/apile.v"
    "progs/pile/fast/fastapile.v"
    "progs/pile/fast/fastpile.v"
    "progs/pile/incr/incr.v"
    "progs/pile/main.v"
    "progs/pile/onepile.v"
    "progs/pile/pile.v"
    "progs/pile/stdlib.v"
    "progs/pile/triang.v"
    "progs/printf.v"
    "progs/ptr_compare.v"
    "progs/queue2.v"
    "progs/queue.v"
    "progs/revarray.v"
    "progs/reverse_client.v"
    "progs/reverse.v"
    "progs/rotate.v"
    "progs/stackframe_demo.v"
    "progs/store_demo.v"
    "progs/string.v"
    "progs/strlib.v"
    "progs/structcopy.v"
    "progs/sumarray2.v"
    "progs/sumarray.v"
    "progs/switch.v"
    "progs/tree.v"
    "progs/union.v"
    "progs/VSUpile/apile.v"
    "progs/VSUpile/fast/fastapile.v"
    "progs/VSUpile/fast/fastpile.v"
    "progs/VSUpile/incr/incr.v"
    "progs/VSUpile/main.v"
    "progs/VSUpile/onepile.v"
    "progs/VSUpile/pile.v"
    "progs/VSUpile/stdlib.v"
    "progs/VSUpile/triang.v"
    "sha/hkdf.v"
    "sha/hmac.v"
    "sha/sha.v"
    "tweetnacl20140427/tweetnaclVerifiableC.v"))

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
              (modules '((guix build utils)))
              (snippet
               #~(begin
                   (for-each delete-file '#$%coq-vst-generated)
                   (delete-file-recursively "doc/graphics")
                   (delete-file-recursively "concurrency/paco_old")
                   (delete-file-recursively "compcert_new")))
              (sha256
               (base32
                "137c04a8c3qr5y83v1jdpx1gbp3qf9mzmdjjw9r7d6cm1mjkaxrl"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "COMPCERT=inst_dir"
                   (string-append "CLIGHTGEN="
                                  #$(this-package-input "compcert-for-vst")
                                  "/bin/clightgen")
                   (string-append "COMPCERT_INST_DIR="
                                  #$(this-package-input "compcert-for-vst")
                                  "/lib/coq/user-contrib/compcert/")
                   (string-append "INSTALLDIR=" #$output
                                  "/lib/coq/user-contrib/VST"))
           #:test-target "test"
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'patch-pwd
                 (lambda _
                   (substitute* "util/coqflags"
                     (("/bin/pwd") "pwd"))))
               ;; FIXME: These files are not automatially generated like the
               ;; others, send a PR to fix this.
               (add-after 'patch-pwd 'generate-clight-sources
                 (lambda _
                   (with-directory-excursion "concurrency"
                     (format #t "generate-clight-sources: `concurrency/threads.c'~%" )
                     (invoke "clightgen" "-normalize" "threads.c"))

                   (with-directory-excursion "progs"
                     (for-each (lambda (file)
                                 (format #t "generate-clight-sources: `progs/~a'~%" file)
                                 (invoke "clightgen" "-normalize" file))
                               '("cast_test.c" "float.c" "floyd_tests.c"
                                 "global.c" "load_demo.c" "nest2.c" "nest3.c"
                                 "objectSelf.c" "objectSelfFancy.c"
                                 "objectSelfFancyOverriding.c" "ptr_compare.c"
                                 "queue2.c" "store_demo.c" "structcopy.c"
                                 "sumarray2.c" "switch.c" "union.c")))

                   (with-directory-excursion "progs64"
                     (for-each (lambda (file)
                                 (format #t "generate-clight-sources: `progs64/~a'~%" file)
                                 (invoke "clightgen" "-normalize" file))
                               '("append.c" "bin_search.c" "bst.c"
                                 "float.c" "field_loadstore.c" "global.c"
                                 "logical_compare.c" "message.c" "min.c"
                                 "min64.c" "nest2.c" "nest3.c" "object.c"
                                 "revarray.c" "reverse.c" "strlib.c"
                                 "sumarray.c" "switch.c" "union.c")))))
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
    (version "0.0.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mit-plv/coqutil")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0vkja05cbrzzdcd5iv6awapjw3gdi8d61fwvyniyd1hs7np5vxvk"))))
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
