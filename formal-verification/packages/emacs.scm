;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (guix build-system emacs)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public emacs-quick-peek
  (let ((commit "03a276086795faad46a142454fc3e28cab058b70")
        (revision "0"))
    (package
      (name "emacs-quick-peek")
      (version (git-version "1.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/cpitclaudel/quick-peek")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1kzsphzc9n80v6vf00dr2id9qkm78wqa6sb2ncnasgga6qj358ql"))))
      (build-system emacs-build-system)
      (home-page "https://github.com/cpitclaudel/quick-peek")
      (synopsis "Inline windows for Emacs")
      (description "This package provides an Emacs library for creating inline
windows or pop-ups.")
      (license license:gpl3+))))
