;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages coq)
  #:use-module (gnu packages)
  #:use-module (gnu packages coq)
  #:use-module (gnu packages ocaml)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

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
                     (let ((bin (string-append #$output "/bin")))
                       (install-file "coqlex" bin)))))))
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
