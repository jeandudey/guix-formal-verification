;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification unbootstrappable vale-language)
  #:use-module (formal-verification unbootstrappable dotnet)
  #:use-module (gnu packages compression)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (nonguix build-system binary))

;; NOTE: There's already a vale package in GNU Guix, so just use vale-language
;; to differentiate.
;;
;; Can't be bootstrapped because there's no .NET is not
;; bootstrappable.
;;
;; We should also try to build from source though, same rationale as Dafny.
(define-public vale-language
  (package
    (name "vale-language")
    (version "0.3.20")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/project-everest/vale"
                                  "/releases/download/v" version
                                  "/vale-release-" version ".zip"))
              (file-name (string-append name "-" version ".zip"))
              (sha256
               (base32
                "0hdssdrlb6fzbvw4k3qr1x3wjcraksjxibpxv8smiwlq41js6jlq"))))
    (build-system binary-build-system)
    (arguments
     (list #:install-plan
           #~'(("bin" #$(string-append "share/" name "-" version "/bin")))

           #:validate-runpath? #f
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'wrap-program
                 (lambda* (#:key inputs #:allow-other-keys)
                   (define (wrap-program-mono name)
                     (call-with-output-file (string-append #$output "/bin/" name)
                       (lambda (port)
                         (format port "#!~a~%exec ~s ~s \"$@\"~%"
                                 (search-input-file inputs "bin/bash")
                                 (search-input-file inputs "bin/mono")
                                 (string-append #$output "/share/" #$name "-"
                                                #$version "/bin/" name
                                                ".exe"))
                         (chmod (string-append #$output "/bin/" name) #o755))))

                   (mkdir-p (string-append #$output "/bin"))
                   (wrap-program-mono "vale")
                   (wrap-program-mono "importFStarTypes"))))))
    (native-inputs (list unzip))
    (inputs (list mono))
    (home-page "https://github.com/project-everest/vale")
    (synopsis "@acronym{VALE, Verified Assembly Language for Everest}")
    (description "This package provides @acronym{VALE, Verified Assembly
Language for Everest}, a tool for constructing formally verified
high-performance assembly language code, with an emphasis on cryptographic
code.  It uses existing verification frameworks, such as Dafny and F*
(FStar), for formal verification.  Supports multiple architectures such as
x86, x64 and ARM.")
    (supported-systems '("x86_64-linux"))
    (license license:asl2.0)))
