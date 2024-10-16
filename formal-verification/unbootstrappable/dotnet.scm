;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification unbootstrappable dotnet)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module ((nonguix licenses) #:prefix license:))

(define-public mono
  (package
    (name "mono")
    (version "6.12.0.199")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://download.mono-project.com/sources"
                                  "/mono/mono-" version ".tar.xz"))
              (sha256
               (base32
                "1xcf8wrz0n5m0lwis5bz06h18shc94a0jpyl70ibm9jkada0v1f0"))))
    (build-system gnu-build-system)
    (home-page "https://www.mono-project.com/")
    (arguments
     (list ;; A test, delegate2.exe, fails with an System.NotImplementedException: The method or operation is not implemented.
           ;; Ref https://github.com/mono/mono/issues/21549
           #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (add-before 'bootstrap 'prepare-bootstrap
                 (lambda _
                   (patch-shebang "external/bdwgc/autogen.sh"))))))
    (native-inputs
     (list autoconf
           automake
           gnu-gettext
           libtool))
    (inputs (list python
                  cmake
                  gcc
                  git
                  which
                  libx11
                  perl
                  zlib))
    (synopsis "Cross platform, open source .NET framework")
    (description "Mono is a software platform designed to allow developers to
easily create cross platform applications. It is an open source implementation
of Microsoft's .NET Framework based on the ECMA standards for C# and the
Common Language Runtime.")
    (license (list license:bsd-1 license:expat license:mpl1.1 license:asl2.0
                   (license:nonfree "See https://raw.githubusercontent.com/mono/mono/main/LICENSE and https://raw.githubusercontent.com/mono/mono/main/PATENTS.TXT")))))
