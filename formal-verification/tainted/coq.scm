;;; SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (formal-verification tainted coq)
  #:use-module (formal-verification nonfree coq)
  #:use-module (gnu packages coq)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

;; To update this list, run this on the original VCS checkout:
;;
;;   guix shell bash coreutils ripgrep --pure -- \
;;     bash -c "rg 'Module Info.' -l | sort"
;;
;; Then stylize accordingly.
(define %coq-vst-generated
  '("aes/aes.v"
    "atomics/hashtable_atomic.v"
    "atomics/kvnode_atomic.v"
    "atomics/sim_atomics.v"
    "concurrency/threads.v"
    "hmacdrbg/hmac_drbg.v"
    "mailbox/atomic_exchange.v"
    "mailbox/mailbox.v"
    "progs64/append.v"
    "progs64/bin_search.v"
    "progs64/bst.v"
    "progs64/field_loadstore.v"
    "progs64/float.v"
    "progs64/global.v"
    "progs64/incrN.v"
    "progs64/incr.v"
    "progs64/io_mem.v"
    "progs64/io.v"
    "progs64/logical_compare.v"
    "progs64/message.v"
    "progs64/min64.v"
    "progs64/min.v"
    "progs64/nest2.v"
    "progs64/nest3.v"
    "progs64/object.v"
    "progs64/printf.v"
    "progs64/ptr_cmp.v"
    "progs64/revarray.v"
    "progs64/reverse.v"
    "progs64/shift.v"
    "progs64/strlib.v"
    "progs64/sumarray.v"
    "progs64/switch.v"
    "progs64/union.v"
    "progs64/VSUpile/apile.v"
    "progs64/VSUpile/fast/fastapile.v"
    "progs64/VSUpile/fast/fastpile.v"
    "progs64/VSUpile/main.v"
    "progs64/VSUpile/onepile.v"
    "progs64/VSUpile/pile.v"
    "progs64/VSUpile/stdlib.v"
    "progs64/VSUpile/triang.v"
    "progs/append.v"
    "progs/bin_search.v"
    "progs/bst_oo.v"
    "progs/bst.v"
    "progs/cast_test.v"
    "progs/cond.v"
    "progs/dotprod.v"
    "progs/even.v"
    "progs/fib.v"
    "progs/field_loadstore.v"
    "progs/float.v"
    "progs/floyd_tests.v"
    "progs/funcptr.v"
    "progs/global.v"
    "progs/incr2.v"
    "progs/incrN.v"
    "progs/incr.v"
    "progs/insertionsort.v"
    "progs/int_or_ptr.v"
    "progs/io_mem.v"
    "progs/io.v"
    "progs/libglob.v"
    "progs/load_demo.v"
    "progs/logical_compare.v"
    "progs/loop_minus1.v"
    "progs/memmgr/malloc.v"
    "progs/memmgr/mmap0.v"
    "progs/merge.v"
    "progs/message.v"
    "progs/min64.v"
    "progs/min.v"
    "progs/nest2.v"
    "progs/nest3.v"
    "progs/objectSelfFancyOverriding.v"
    "progs/objectSelfFancy.v"
    "progs/objectSelf.v"
    "progs/object.v"
    "progs/odd.v"
    "progs/peel.v"
    "progs/pile/apile.v"
    "progs/pile/fast/fastapile.v"
    "progs/pile/fast/fastpile.v"
    "progs/pile/incr/incr.v"
    "progs/pile/main.v"
    "progs/pile/onepile.v"
    "progs/pile/pile.v"
    "progs/pile/stdlib.v"
    "progs/pile/triang.v"
    "progs/printf.v"
    "progs/ptr_compare.v"
    "progs/queue2.v"
    "progs/queue.v"
    "progs/revarray.v"
    "progs/reverse_client.v"
    "progs/reverse.v"
    "progs/rotate.v"
    "progs/stackframe_demo.v"
    "progs/store_demo.v"
    "progs/string.v"
    "progs/strlib.v"
    "progs/structcopy.v"
    "progs/sumarray2.v"
    "progs/sumarray.v"
    "progs/switch.v"
    "progs/tree.v"
    "progs/union.v"
    "progs/VSUpile/apile.v"
    "progs/VSUpile/fast/fastapile.v"
    "progs/VSUpile/fast/fastpile.v"
    "progs/VSUpile/incr/incr.v"
    "progs/VSUpile/main.v"
    "progs/VSUpile/onepile.v"
    "progs/VSUpile/pile.v"
    "progs/VSUpile/stdlib.v"
    "progs/VSUpile/triang.v"
    "sha/hkdf.v"
    "sha/hmac.v"
    "sha/sha.v"
    "tweetnacl20140427/tweetnaclVerifiableC.v"))

(define-public coq-vst
  (package
    (name "coq-vst")
    (version "2.14")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/PrincetonUniversity/VST")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (modules '((guix build utils)))
              (snippet
               #~(begin
                   (for-each delete-file '#$%coq-vst-generated)
                   (delete-file-recursively "doc/graphics")
                   (delete-file-recursively "concurrency/paco_old")
                   (delete-file-recursively "compcert_new")))
              (sha256
               (base32
                "137c04a8c3qr5y83v1jdpx1gbp3qf9mzmdjjw9r7d6cm1mjkaxrl"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "COMPCERT=inst_dir"
                   (string-append "CLIGHTGEN="
                                  #$(this-package-input "compcert-for-vst")
                                  "/bin/clightgen")
                   (string-append "COMPCERT_INST_DIR="
                                  #$(this-package-input "compcert-for-vst")
                                  "/lib/coq/user-contrib/compcert/")
                   (string-append "INSTALLDIR=" #$output
                                  "/lib/coq/user-contrib/VST"))
           #:test-target "test"
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'patch-pwd
                 (lambda _
                   (substitute* "util/coqflags"
                     (("/bin/pwd") "pwd"))))
               ;; FIXME: These files are not automatially generated like the
               ;; others, send a PR to fix this.
               (add-after 'patch-pwd 'generate-clight-sources
                 (lambda _
                   (with-directory-excursion "concurrency"
                     (format #t "generate-clight-sources: `concurrency/threads.c'~%" )
                     (invoke "clightgen" "-normalize" "threads.c"))

                   (with-directory-excursion "progs"
                     (for-each (lambda (file)
                                 (format #t "generate-clight-sources: `progs/~a'~%" file)
                                 (invoke "clightgen" "-normalize" file))
                               '("cast_test.c" "float.c" "floyd_tests.c"
                                 "global.c" "load_demo.c" "nest2.c" "nest3.c"
                                 "objectSelf.c" "objectSelfFancy.c"
                                 "objectSelfFancyOverriding.c" "ptr_compare.c"
                                 "queue.c" "queue2.c" "reverse.c"
                                 "reverse_client.c" "store_demo.c" "structcopy.c"
                                 "sumarray2.c" "switch.c" "union.c")))

                   (with-directory-excursion "progs64"
                     (for-each (lambda (file)
                                 (format #t "generate-clight-sources: `progs64/~a'~%" file)
                                 (invoke "clightgen" "-normalize" file))
                               '("append.c" "bin_search.c" "bst.c"
                                 "float.c" "field_loadstore.c" "global.c"
                                 "incr.c" "logical_compare.c" "message.c"
                                 "min.c" "min64.c" "nest2.c" "nest3.c"
                                 "object.c" "revarray.c" "reverse.c"
                                 "strlib.c" "sumarray.c" "switch.c"
                                 "union.c")))))
               (delete 'configure))))
    (native-inputs (list coq))
    (propagated-inputs (list compcert-for-vst))
    (home-page "https://vst.cs.princeton.edu/")
    (synopsis "Toolset for proving functional correctness of C programs")
    (description "This package provides the @acronym{VST, Verified Software
Toolchain}, for proving the functional correctness of C programs.")
    (license license:bsd-2)))
