;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages maths)
  #:use-module (gnu packages maths)
  #:use-module (guix git-download)
  #:use-module (guix packages))

;; This is inteded for use by FStar as newer versions of Z3 produce
;; regressions.
;;
;; Remove once FStar supports latest Z3 releases.
;;
;; See: <https://github.com/FStarLang/FStar/issues/2431>.
;;
;; Also needed by Dafny.
(define-public z3-4.8.5
  (package
    (inherit z3)
    (name "z3")
    (version "4.8.5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/Z3Prover/z3")
                     (commit (string-append "Z3-" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "11sy98clv7ln0a5vqxzvh6wwqbswsjbik2084hav5kfws4xvklfa"))))))
