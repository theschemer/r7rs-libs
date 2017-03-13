; "math-real.scm": mathematical functions restricted to real numbers
; Copyright (C) 2006 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

;; Packaged for R7RS Scheme by Peter Lane, 2017
;;
;; Changes to original:
;; 1. Assumes complex and real numbers supported
;; 2. renamed abs to real-abs to be consistent with other functions, 
;;    and avoid a clash with (scheme base)

(define-library
  (slib math-real)
  (export real-exp
          real-ln
          real-log
          real-sin
          real-cos
          real-tan
          real-asin
          real-acos
          real-atan
          atan
          real-sqrt
          real-expt
          quo
          rem
          mod
          ln
          real-abs
          make-rectangular
          make-polar)
  (import (scheme base)
          (scheme inexact)
          (slib common))

  (begin
    ;@
    (define (quo x1 x2) (truncate (/ x1 x2)))
    (define (rem x1 x2) (- x1 (* x2 (quo x1 x2))))
    (define (mod x1 x2) (- x1 (* x2 (floor (/ x1 x2)))))

    (define (must-be-real name proc)
      (and proc
           (lambda (x1)
             (if (real? x1) (proc x1) (slib:error name x1)))))
    (define (must-be-real+ name proc)
      (and proc
           (lambda (x1)
             (if (and (real? x1) (>= x1 0))
               (proc x1)
               (slib:error name x1)))))
    (define (must-be-real-1+1 name proc)
      (and proc
           (lambda (x1)
             (if (and (real? x1) (<= -1 x1 1))
               (proc x1)
               (slib:error name x1)))))
    ;@
    (define ln log)
    (define real-abs  (must-be-real 'abs abs))
    (define real-sin  (must-be-real 'real-sin sin))
    (define real-cos  (must-be-real 'real-cos cos))
    (define real-tan  (must-be-real 'real-tan tan))
    (define real-exp  (must-be-real 'real-exp exp))
    (define real-ln   (must-be-real+ 'ln ln))
    (define real-sqrt (must-be-real+ 'real-sqrt sqrt))
    (define real-asin (must-be-real-1+1 'real-asin asin))
    (define real-acos (must-be-real-1+1 'real-acos acos))

    (define (must-be-real2 name proc)
      (and proc
           (lambda (x1 x2)
             (if (and (real? x1) (real? x2))
               (proc x1 x2)
               (slib:error name x1 x2)))))
    ;@
    (define make-rectangular
      (must-be-real2 'make-rectangular make-rectangular))
    (define make-polar
      (must-be-real2 'make-polar make-polar))

    ;@
    (define real-log
      (and ln
           (lambda (base x)
             (if (and (real? x) (positive? x) (real? base) (positive? base))
               (/ (ln x) (ln base))
               (slib:error 'real-log base x)))))

    ;@
    (define (real-expt x1 x2)
      (cond ((and (real? x1)
                  (real? x2)
                  (or (not (negative? x1)) (integer? x2)))
             (expt x1 x2))
            (else (slib:error 'real-expt x1 x2))))

    ;@
    (define real-atan
      (lambda (y . x)
        (if (and (real? y)
                 (or (null? x)
                     (and (= 1 (length x))
                          (real? (car x)))))
          (atan y x)
          (slib:error 'real-atan y x))))

    ))
