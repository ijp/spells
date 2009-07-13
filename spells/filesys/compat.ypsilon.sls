;;; compat.ypsilon.sls --- filesys compat library for Ypsilon.

;; Copyright (C) 2009 Andreas Rottmann <a.rottmann@gmx.at>

;; Author: Andreas Rottmann <a.rottmann@gmx.at>

;; This program is free software, you can redistribute it and/or
;; modify it under the terms of the new-style BSD license.

;; You should have received a copy of the BSD license along with this
;; program. If not, see <http://www.debian.org/misc/bsd.license>.

;;; Commentary:

;;; Code:
#!r6rs


(library (spells filesys compat)
  (export file-exists?
          create-directory
          create-symbolic-link
          create-hard-link
          delete-file
          rename-file

          file-regular?
          file-directory?
          file-symbolic-link?
          file-readable?
          file-writable?
          file-executable?
          file-modification-time
          file-size-in-bytes

          directory-fold*

          working-directory
          with-working-directory

          library-search-paths)
  (import (rnrs base)
          (rnrs conditions)
          (rnrs exceptions)
          (rnrs io ports)
          (prefix (rnrs files) rnrs:)
          (srfi :8 receive)
          (spells pathname)
          (spells time-lib)
          (prefix (core files) yp:)
          (prefix (core primitives) yp:))

  (define x->f x->namestring)

  (define (file-exists? pathname)
    (rnrs:file-exists? (x->f pathname)))

  (define (create-directory pathname)
    (yp:create-directory (x->f pathname)))

  (define (create-symbolic-link old-pathname new-pathname)
    (yp:create-symbolic-link (x->f old-pathname) (x->f new-pathname)))

  (define (create-hard-link old-pathname new-pathname)
    (yp:create-hard-link (x->f old-pathname) (x->f new-pathname)))

  (define (delete-file pathname)
    (let ((fname (x->f pathname)))
      (if (rnrs:file-exists? fname)
          (yp:delete-file fname))))

  (define (rename-file source-pathname target-pathname)
    (yp:rename-file (x->f source-pathname) (x->f target-pathname)))

  (define (file-regular? pathname)
    (yp:file-regular? (x->f pathname)))
  (define (file-directory? pathname)
    (yp:file-directory? (x->f pathname)))
  (define (file-symbolic-link? pathname)
    (yp:file-symbolic-link? (x->f pathname)))

  (define (make-file-check pred who)
    (lambda (pathname)
      (let ((fname (x->f pathname)))
        (if (rnrs:file-exists? fname)
            (pred fname)
            (raise (condition
                    (make-error)
                    (make-who-condition who)
                    (make-i/o-file-does-not-exist-error fname)))))))

  (define-syntax define-file-check
    (syntax-rules ()
      ((_ id pred)
       (define id (make-file-check pred 'id)))))
  
  (define-file-check file-readable? yp:file-readable?)
  (define-file-check file-writable? yp:file-writable?)
  (define-file-check file-executable? yp:file-executable?)

  (define (file-modification-time pathname)
    (let ((nsecs (yp:file-stat-mtime (x->f pathname))))
      (posix-timestamp->time-utc (div nsecs #e1e9) (mod nsecs #e1e9))))

  (define (file-size-in-bytes pathname)
    (yp:file-size-in-bytes (x->f pathname)))

  (define (dot-or-dotdot? f)
    (or (string=? "." f) (string=? ".." f)))

  (define (directory-fold* pathname combiner . seeds)
    (define (full-pathname entry)
      (pathname-with-file pathname (pathname-file (x->pathname entry))))
    (let loop ((entries (yp:directory-list (x->f pathname))) (seeds seeds))
      (if (null? entries)
          (apply values seeds)
          (let ((entry (car entries)))
            (cond ((dot-or-dotdot? entry)
                   (loop (cdr entries) seeds))
                  (else
                   (receive (continue? . new-seeds)
                            (apply combiner (full-pathname entry) seeds)
                     (if continue?
                         (loop (cdr entries) new-seeds)
                         (apply values new-seeds)))))))))


  (define (working-directory)
    (yp:current-directory))

  (define (with-working-directory dir thunk)
    (let ((wd (yp:current-directory)))
      (dynamic-wind
        (lambda () (yp:current-directory
                    (x->f (pathname-as-directory (x->pathname dir)))))
        thunk
        (lambda () (yp:current-directory wd)))))


  (define library-search-paths yp:scheme-library-paths)

  )