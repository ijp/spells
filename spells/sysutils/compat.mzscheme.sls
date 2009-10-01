;; Copyright (C) 2008, 2009 Andreas Rottmann <a.rottmann@gmx.at>
;; Copyright (C) 2005, 2007 Jose Antonio Ortega Ruiz <jao@gnu.org>

;; Authors: Andreas Rottmann <a.rottmann@gmx.at>
;;          Jose Antonio Ortega Ruiz <jao@gnu.or>

;; This program is free software, you can redistribute it and/or
;; modify it under the terms of the new-style BSD license.

;; You should have received a copy of the BSD license along with this
;; program. If not, see <http://www.debian.org/misc/bsd.license>.

;;; Commentary:

;;; Code:
#!r6rs

(library (spells sysutils compat)
  (export lookup-environment-variable
          current-process-environment
          find-exec-path
          host-info)

  (import (rnrs)
          (only (mzscheme) getenv system-type find-executable-path))

  (define lookup-environment-variable getenv)

  (define (current-process-environment)
    (raise (condition
            (make-implementation-restriction-violation)
            (make-who-condition 'current-process-environment)
            (make-message-condition "Not supported on PLT Scheme"))))

  (define (find-exec-path prog)
    (find-executable-path prog #f))

  (define (host-info)
    (values "unknown" "unknown "(symbol->string (system-type 'os)))))
