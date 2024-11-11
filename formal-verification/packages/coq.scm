;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages coq)
  #:use-module (formal-verification packages prolog)
  #:use-module (gnu packages base)
  #:use-module (gnu packages coq)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages python)
  #:use-module (guix build-system dune)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (ice-9 match))

(define-public coq-aac-tactics
  (package
    (name "coq-aac-tactics")
    (version "8.18.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/coq-community/aac-tactics")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "16l5a46f5cawsd8avsw3j4r8rpyhj6rbqifi7afv655jl3vbp5sn"))))
    (build-system dune-build-system)
    (arguments
     (list #:tests? #f ;; No test suite.
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'install-symlink
                 (lambda _
                   (mkdir-p (string-append #$output "/lib/coq/user-contrib"))
                   (symlink (string-append #$output
                                           "/lib/ocaml/site-lib/coq"
                                           "/user-contrib/AAC_tactics/")
                            (string-append #$output
                                           "/lib/coq/user-contrib/AAC_tactics")))))))
    (native-inputs (list coq))
    (home-page "https://coq-community.org/aac-tactics/")
    (synopsis "Coq plugin providing tactics for rewriting")
    (description "This package provides a Coq plugin with tactics for
rewriting universally quantified equations, modulo associative (and
possibly commutative) operators. ")
    (license license:lgpl3+)))

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
    ;; NOTE:
    ;;
    ;; Coq < Coq <
    ;; Coq < Toplevel input, characters 25-35:
    ;; > Local Set Printing Width 2147483647.
    ;; >                          ^^^^^^^^^^
    ;; Error: This number is too large.
    (supported-systems %64bit-supported-systems)
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

(define-public coq-coquelicot/mathcomp-2
  (package
    (inherit coq-coquelicot)
    (name "coq-coquelicot-mathcomp-2")
    (propagated-inputs
     (list coq-mathcomp-2))))

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

(define-public coq-infotheo
  ;; From `git describe --tags'.
  (let ((revision "3")
        (commit "5a1e1cb3b66adf7ad76db3a61be9eae0f70fa88c"))
    (package
      (name "coq-infotheo")
      (version (git-version "0.7.2" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/affeldt-aist/infotheo")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1gmfmwj2ja83yl24b5ry64aygz8av5x8vvm8s9lhpv69nfriwb2d"))))
      (build-system gnu-build-system)
      (arguments
       (list #:make-flags
             #~(list (string-append "COQLIBINSTALL=" #$output
                                    "/lib/coq/user-contrib"))
             #:tests? #f ;; No tests.
             #:phases
             #~(modify-phases %standard-phases
                 (delete 'configure))))
      (native-inputs (list coq ocaml which))
      (propagated-inputs
       (list coq-hierarchy-builder
             coq-interval/mathcomp-2
             coq-mathcomp-2
             coq-mathcomp-algebra-tactics
             coq-mathcomp-analysis))
      (inputs (list ocaml-zarith)) ; Propagate in Coq.
      (home-page "https://github.com/affeldt-aist/infotheo/")
      (synopsis "Information theory and linear error correcting codes for Coq")
      (description "This package provides a Coq library for reasoning about
information theory,linear error correcting codes and discrete probabilities.")
      (license license:lgpl2.1+))))

(define-public coq-interval/mathcomp-2
  (package
    (inherit coq-interval)
    (name "coq-interval-mathcomp-2")
    (propagated-inputs
     (list coq-bignums
           coq-coquelicot/mathcomp-2
           coq-flocq
           coq-mathcomp-2))))

(define-public coq-iris
  (package
    (name "coq-iris")
    (version "4.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://gitlab.mpi-sws.org/iris/iris.git/")
                     (commit (string-append "iris-" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1wr1jigzgl4fajl5jv4lanmb8nk4k6wdakakmxhfp5drxwhqgs0y"))))
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
    (propagated-inputs (list coq-stdpp))
    (home-page "https://github.com/DeepSpec/InteractionTrees")
    (synopsis "Represent impure and recursive programs in Coq")
    (description "This package provides a library allowing the representation
of impure and recursive programs in Coq with equational reasoning.")
    ;; Code is BSD-3 and documentation CC-BY 4.0
    (license (list license:bsd-3 license:cc-by4.0))))

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
           coq-mathcomp-bigenough/mathcomp-2
           coq-mathcomp-finmap/mathcomp-2))
    (home-page "https://github.com/math-comp/analysis")
    (synopsis "Real analysis library for Coq")
    (description "This library provides real analysis library for Coq, using
the Mathematical Components library.")
    (license license:cecill-c)))

(define-public coq-mathcomp-bigenough/mathcomp-2
  (package
    (inherit coq-mathcomp-bigenough)
    (name "coq-mathcomp-bigenough-mathcomp-2")
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

(define-public coq-mathcomp-finmap/mathcomp-2
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
    (inputs '())))

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

(define-public coq-parseque
  (package
    (name "coq-parseque")
    (version "0.2.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/coq-community/parseque")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1dmcdb9rx01n2wz7fdrxlb4qwk71s25fwzjn9m912nb3fvl5kidj"))))
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
    (home-page "https://github.com/coq-community/parseque")
    (synopsis "Total parser combinator library for Coq")
    (description "This package provides a total parser combinator library
for Coq, based on the agdarsec library for Adga.")
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

(define-public coq-relation-algebra
  (package
    (name "coq-relation-algebra")
    (version "1.7.10")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/damien-pous/relation-algebra")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "001p60kh0ppdmvhmy3il5hvhnkn5qinzdlv4hckwpcdbwvhwrhv9"))))
    (build-system gnu-build-system)
    (arguments
     (list #:configure-flags #~'("--enable-ssr" "--enable-aac")
           #:make-flags
           #~(list (string-append "COQLIBINSTALL=" #$output
                                  "/lib/coq/user-contrib")
                   (string-append "COQPLUGININSTALL=" #$output
                                  "/lib/ocaml/site-lib"))
           #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (replace 'configure
                 (lambda* (#:key configure-flags #:allow-other-keys)
                   (apply invoke "bash" "./configure" configure-flags))))))
    (native-inputs (list ocaml coq))
    (propagated-inputs (list coq-aac-tactics coq-mathcomp-2))
    (home-page "https://github.com/damien-pous/relation-algebra")
    (synopsis "Relation algebra for Coq")
    (description "This package provides a modular library about relation
algebra: those algebras admitting heterogeneous binary relations as a
model, ranging from partially ordered monoid to residuated Kleene allegories
and @acronym{KAT, Kleene Algebra with Tests}.")
    (license license:lgpl3+)))

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

(define-public coq-simple-io
  (package
    (name "coq-simple-io")
    (version "1.10.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/Lysxia/coq-simple-io")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1v4hi8mf257bnmmfyajjzgh04d35ffnmrkdy0kb64cfipf203dzb"))))
    (build-system dune-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'install-symlink
                 (lambda _
                   (mkdir-p (string-append #$output "/lib/coq/user-contrib"))
                   (symlink (string-append #$output
                                           "/lib/ocaml/site-lib/coq"
                                           "/user-contrib/SimpleIO/")
                            (string-append #$output
                                           "/lib/coq/user-contrib/SimpleIO")))))))
    (native-inputs (list coq ocaml ocaml-cppo ocamlbuild))
    (inputs (list gmp))
    (propagated-inputs (list coq-ext-lib))
    (home-page "https://github.com/Lysxia/coq-simple-io")
    (synopsis "Library I/O programming in Coq")
    (description "This package provides a Coq library to perform I/O in a
style similar to Haskell.")
    (license license:expat)))

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
