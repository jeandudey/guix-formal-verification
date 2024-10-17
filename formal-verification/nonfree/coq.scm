;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification nonfree coq)
  #:use-module (formal-verification packages coq)
  #:use-module (gnu packages base)
  #:use-module (gnu packages coq)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (nongnu packages coq)
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
