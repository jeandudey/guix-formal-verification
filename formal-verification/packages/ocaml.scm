;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages ocaml)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages python)
  #:use-module (guix build-system dune)
  #:use-module (guix build-system ocaml)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

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

(define-public ocaml-process
  (package
    (name "ocaml-process")
    (version "0.2.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/dsheets/ocaml-process")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32 "0m1ldah5r9gcq09d9jh8lhvr77910dygx5m309k1jm60ah9mdcab"))))
    (build-system ocaml-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))))
    (native-inputs (list ocaml-alcotest ocaml-findlib ocamlbuild))
    (home-page "https://github.com/dsheets/ocaml-process")
    (synopsis "Use commands as functions")
    (description "This package provides a OCaml library, @code{process}, that
makes it easy to use commands as functions.")
    (license license:isc)))

(define-public ocaml-stdint
  (package
    (name "ocaml-stdint")
    (version "0.7.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/andrenth/ocaml-stdint")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0c5l1pbwcvj0ak7fc6adp5jgh83p4bc9qgx4rfnzyc24dn8gllrf"))))
    (build-system dune-build-system)
    (arguments
     (list ;; FIXME: Some tests are failing, see:
           ;; <https://github.com/andrenth/ocaml-stdint/issues/59>.
           #:tests? #f))
    (propagated-inputs (list ocaml-odoc))
    (native-inputs (list ocaml-qcheck))
    (home-page "https://github.com/andrenth/ocaml-stdint")
    (synopsis "Fixed with integer types")
    (description "The stdint library provides signed and unsigned integer
types of various fixed widths: 8, 16, 24, 32, 40, 48, 56, 64 and 128 bit.

This interface is similar to @code{Int32} and @code{Int64} from the base
library but provides more functions and constants:

@itemize
@item Arithmetic and bit-wise operations.
@item Constants for maximum and minimum values.
@item Infix operators conversion to and from every other integer type,
including @code{int}, @code{float} and @code{nativeint}.
@item Parsing from and conversion to readable strings (binary, octal, decimal,
hexademical).
@item Conversion to and from buffers in both big endian and little endian byte
order.
@end itemize")
    (license license:expat)))

(define-public ocaml-visitors
  (package
    (name "ocaml-visitors")
    (version "20210608")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://gitlab.inria.fr/fpottier/visitors")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1p75x5yqwbwv8yb2gz15rfl3znipy59r45d1f4vcjdghhjws6q2a"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ppxlib ocaml-ppx-deriving ocaml-result))
    (home-page "https://gitlab.inria.fr/fpottier/visitors")
    (synopsis "Traverse and transform data structures")
    (description "This package provides a library to traverse and transform
data structures in OCaml by extending @code{ppx_deriving} which generates
object-oriented visitors for traversing and transforming data structures.")
    (license license:lgpl2.1)))

(define-public ocaml-wasm
  (package
    (name "ocaml-wasm")
    (version "2.0.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/WebAssembly/spec")
                     (commit (string-append "opam-" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1nyfpylky6pi4c9nna5r31zrkccl1lynpzcm9d8nrn52icq3rsp5"))))
    (build-system ocaml-build-system)
    (arguments
     (list #:tests? (target-64bit?)
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-before 'build 'change-directory
                 (lambda _
                   (chdir "interpreter"))))))
    (native-inputs
     (list ocaml-findlib
           ocamlbuild
           python-minimal))
    (home-page "https://github.com/WebAssembly/spec")
    (synopsis "WebAssembly reference interpreter")
    (description "This package provides an official WebAssembly reference
interpreter.  The interpreter can:

@itemize
@item Parse, decode and validate modules in text or binary formats.
@item Execute scripts with module definitions, invocations and assertions.
@item Convert between text and binary format in both directions.
@item Export test scripts to self-contained JavaScript test cases.
@item Run as an interactive interpreter.
@end itemize")
    (license license:asl2.0)))
