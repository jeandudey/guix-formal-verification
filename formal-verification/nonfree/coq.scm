;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification nonfree coq)
  #:use-module (formal-verification packages coq)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages coq)
  #:use-module (gnu packages ocaml)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (nongnu packages coq)
  #:use-module ((nonguix licenses) #:prefix license:)
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
      ;; NOTE: Some mention INRIA NonCommercial license.
      (license (list license:expat (license:nonfree ""))))))

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
      ;;
      ;; Also contains code from Coq lex from the patch.
      (license (list license:lgpl3 (license:nonfree ""))))))
