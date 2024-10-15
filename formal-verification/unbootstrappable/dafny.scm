;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification unbootstrappable dafny)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages icu4c)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (nongnu packages dotnet)
  #:use-module (nonguix build-system binary))

;; NOTE: Can't be bootstrapped because there's no .NET is not
;; bootstrappable.
;;
;; Ideally introduce a .NET build system to build this from source
;; even though .NET is not bootstrappable, but would improve the situation
;; a bit.
(define-public dafny
  (package
    (name "dafny")
    (version "4.8.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/dafny-lang/dafny"
                                  "/releases/download/v" version "/dafny-"
                                  version "-x64-ubuntu-20.04.zip"))
              (file-name (string-append name "-" version ".zip"))
              (sha256
               (base32
                "0mgas0q7wpj66a5nz2mk575j8qczf7ymp082wyj41np86azin19y"))))
    (build-system binary-build-system)
    (arguments
     (list #:patchelf-plan
           #~'(("dafny" ("gcc" "glibc")))

           #:install-plan
           #~'(("." #$(string-append "share/" name "-" version)
                #:exclude ("allow_on_mac.sh"
                           "z3/bin/z3-4.8.5"
                           "z3/bin/z3-4.12.1")))

           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'install-symbolic-link
                 (lambda _
                   (mkdir-p (string-append #$output "/bin"))
                   (symlink (string-append #$output "/share/" #$name "-"
                                           #$version "/dafny")
                            (string-append #$output "/bin/dafny"))))
               (add-after 'install-symbolic-link 'wrap-program
                 (lambda _
                   (wrap-program (string-append #$output "/bin/dafny")
                    `("LD_LIBRARY_PATH" ":" prefix
                      ,(list (string-append #$(this-package-input "icu4c")
                                            "/lib")))))))))
    (native-inputs (list unzip))
    (inputs
     (list `(,gcc "lib")
           glibc
           icu4c))
    ;(inputs (list dotnet))
    (home-page "https://dafny.org/")
    (synopsis "Dafny programming language")
    (description "Dafny is a verification-aware programming language,
supporting interactive verification of the program while it is being typed to
flag any errors, show counter-examples, etc.  Dafny can compile to C#, Go,
Python, Java or JavaScript.")
    (supported-systems '("x86_64-linux"))
    (license license:expat)))
