;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages coq)
  #:use-module (gnu packages coq)
  #:use-module (gnu packages ocaml)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

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
