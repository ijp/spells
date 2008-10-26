;; named-args.scm -- unit tests for named-args.scm
;; arch-tag: d9028ca2-2ea4-11d9-a288-00404513c0a4

;; Copyright (C) 2004, 2005 by Free Software Foundation, Inc.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Start date: Thu Nov 04, 2004 22:02

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU Lesser General Public License as published by
;; the Free Software Foundation; either version 2.1 of the License, or
;; (at your option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.

;;; Code:

;; define/named-args tests

(define/named-args (named-plus (a 5) (b 1)) +)
(define/named-args (greater-a? (af 5) (bf 1) (gt #f)) (set! gt (> af bf)) gt)
(define/named-args (inc-val (val 0)) (+ 1 val))

(testeez
 "named-args - basic"
 (test/eqv "shuffle order 1" 18 (named-plus (b 13) (a 5)))
 (test/eqv "shuffle order 2"
           (named-plus (b 23) (a 12)) (named-plus (a 12) (b 23)))
 (test/eqv "single arg 1"
           (named-plus (b 3)) (named-plus (a 5) (b 3)))
 (test/eqv "single arg 2"
           (named-plus (a 3)) (named-plus (b 1) (a 3)))
 (test/eqv "no args"
           (named-plus) (named-plus (a 5) (b 1))))

(testeez
 "named-args - forms body"
 (test/eq "shuffle order 1" (greater-a? (bf 3) (af 5)) #t)
 (test/eq "shuffle order 2"
          (and (greater-a? (bf 11) (af 12)) (greater-a? (af 12) (bf 11)))
          #t)
 (test/eq "single arg 1" (greater-a? (bf 8)) #f)
 (test/eq "single arg 2"  (greater-a? (af 3)) #t)
 (test/eq "no args"  (greater-a?) #t))

(testeez
 "named-args - single form"
 (test/eqv "no args" (inc-val) 1)
 (test/eqv "1 arg" (inc-val (val 41)) 42))

;; define/optional-args tests

(define/optional-args (opt-plus a b (optional (c 0) (d 0))) (+ a b c d))
(define/optional-args (inc-val/opt (optional (val 0))) (+ 1 val))

(testeez
 "opt-args - basic"
 (test/eqv "four given" 22 (opt-plus 13 5 3 1))
 (test/eqv "three given" (opt-plus 14 4 3) (opt-plus 13 5 3))
 (test/eqv "two given" (opt-plus 6 12) (opt-plus 13 5)))

(testeez
 "opt-args - single form"
 (test/eqv "no args" (inc-val/opt) 1)
 (test/eqv "1 arg" (inc-val/opt 41) 42))

;;; opt-args.scm ends here