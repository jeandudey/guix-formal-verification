;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages ocaml)
  #:use-module (guix build-system dune)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public ocaml-memtrace
  (package
    (name "ocaml-memtrace")
    (version "0.2.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/janestreet/memtrace")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1ny0vfvfxzrvd0csazzwi6iprz4rgkmh5fqmxhrxb00rvyn16sbm"))))
    (build-system dune-build-system)
    (home-page "https://github.com/janestreet/memtrace")
    (synopsis "Trace program memory usage")
    (description "This package provides a streaming client for OCaml's
@code{Memprof}, which generates compact traces of a program's memory usage.

The @code{MEMTRACE} environment variable can be used to set the trace file
name.")
    (license license:expat)))
