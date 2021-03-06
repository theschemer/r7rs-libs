;;; sets.sls --- Purely Functional Sets

;; Copyright (C) 2012 Ian Price <ianprice90@googlemail.com>

;; Author: Ian Price <ianprice90@googlemail.com>

;; This program is free software, you can redistribute it and/or
;; modify it under the terms of the new-style BSD license.

;; You should have received a copy of the BSD license along with this
;; program. If not, see <http://www.debian.org/misc/bsd.license>.

;; Packaged for R7RS Scheme by Peter Lane, 2017

;; -------------------------------------------------------------------

(define-library 
  (pfds set)
  (export set?
          make-set
          set-member?
          set-insert
          set-remove
          set-size
          set<?
          set<=?
          set=?
          set>=?
          set>?
          subset?
          proper-subset?
          set-map
          set-fold
          list->set
          set->list
          set-union
          set-intersection
          set-difference
          set-ordering-procedure
          )
  (import (scheme base)
          (pfds bounded-balance-tree)
          (only (pfds list-helpers) fold-left))

  (begin

    (define dummy #f)

    ;;; basic sets

    ;;> set? : any -> boolean
    ;;> returns #t if the object is a set, #f otherwise
    (define-record-type <set>
                        (%make-set tree)
                        set?
                        (tree set-tree ))

    ;;> set-ordering-procedure : set -> (any any -> boolean)
    ;;> returns the ordering procedure used internally by the set.
    (define (set-ordering-procedure set)
      (bbtree-ordering-procedure (set-tree set)))

    ;;> make-set : (any any -> boolean) -> set
    ;;> returns a new empty set ordered by the < procedure
    (define (make-set <)
      (%make-set (make-bbtree <)))

    ;; provide a (make-equal-set) function?

    ;;> set-member? : set any -> boolean
    ;;> returns true if element is in the set
    (define (set-member? set element)
      (bbtree-contains? (set-tree set) element))

    ;;> set-insert : set any -> set
    ;;> returns a new set created by inserting element into the set argument
    (define (set-insert set element)
      (%make-set (bbtree-set (set-tree set) element dummy)))

    ;;> set-remove : set element -> set
    ;;> returns a new set created by removing element from the set
    (define (set-remove set element)
      (%make-set (bbtree-delete (set-tree set) element)))

    ;;> set-size : set -> non-negative integer
    ;;> returns the number of elements in the set
    (define (set-size set)
      (bbtree-size (set-tree set)))

    ;;; set equality

    ;;> set<=? : set set -> boolean
    ;;> returns #t if set1 is a subset of set2, #f otherwise, i.e. if all
    ;;> elements of set1 are in set2.
    (define (set<=? set1 set2)
      (let ((t (set-tree set2)))
        (bbtree-traverse (lambda (k _ l r b)
                           (and (bbtree-contains? t k)
                                (l #t)
                                (r #t)))
                         #t
                         (set-tree set1))))

    ;;> set<? : set set -> boolean
    ;;> returns #t if set1 is a proper subset of set2, #f otherwise. That
    ;;> is, if all elements of set1 are in set2, and there is at least one
    ;;> element of set2 not in set1.
    (define (set<? set1 set2)
      (and (< (set-size set1)
              (set-size set2))
           (set<=? set1 set2)))

    ;;> set>=? : set set -> boolean
    ;;> returns #t if set2 is a subset of set1, #f otherwise.
    (define (set>=? set1 set2)
      (set<=? set2 set1))

    ;;> set>? : set set -> boolean
    ;;> returns #t if set2 is a proper subset of set1, #f otherwise.
    (define (set>? set1 set2)
      (set<? set2 set1))

    ;;> set=? : set set -> boolean
    ;;> returns #t if every element of set1 is in set2, and vice versa, #f
    ;;> otherwise.
    (define (set=? set1 set2)
      (and (set<=? set1 set2)
           (set>=? set1 set2)))

    ;;> subset? : set set -> boolean
    ;;> same as set<=?
    (define subset? set<=?)

    ;;> proper-subset? : set set -> boolean
    ;;> same as set<?
    (define proper-subset? set<?)

    ;;; iterators

    ;;> set-map : (any -> any) set -> set
    ;;> returns the new set created by applying proc to each element of the set
    (define (set-map proc set)
      ;; currently restricted to returning a set with the same ordering, I
      ;; could weaken this to, say, comparing with < on the object-hash,
      ;; or I make it take a < argument for the result set.
      (let ((tree (set-tree set)))
        (%make-set
          (bbtree-fold (lambda (key _ tree)
                         (bbtree-set tree (proc key) dummy))
                       (make-bbtree (bbtree-ordering-procedure tree))
                       tree))))

    ;;> set-fold : (any any -> any) any set -> any
    ;;> returns the value obtained by iterating the procedure over each
    ;;> element of the set and an accumulator value. The value of the
    ;;> accumulator is initially base, and the return value of proc is used
    ;;> as the accumulator for the next iteration.
    (define (set-fold proc base set)
      (bbtree-fold (lambda (key value base)
                     (proc key base))
                   base
                   (set-tree set)))

    ;;; conversion

    ;;> list->set : Listof(any) (any any -> any) -> set
    ;;> returns the set containing all the elements of the list, ordered by <.
    (define (list->set list <)
      (fold-left set-insert 
                 (make-set <)
                 list))

    ;;> set->list : set -> Listof(any)
    ;;> returns all the elements of the set as a list
    (define (set->list set)
      (set-fold cons '() set))

    ;;; set operations

    ;;> set-union : set set -> set
    ;;> returns the union of set1 and set2, i.e. contains all elements of
    ;;> set1 and set2.
    (define (set-union set1 set2)
      (%make-set (bbtree-union (set-tree set1) (set-tree set2))))

    ;;> set-intersection : set set -> set
    ;;> returns the intersection of set1 and set2, i.e. the set of all
    ;;> items that are in both set1 and set2.
    (define (set-intersection set1 set2)
      (%make-set (bbtree-intersection (set-tree set1) (set-tree set2))))

    ;;> set-difference : set set -> set
    ;;> returns the difference of set1 and set2, i.e. the set of all items
    ;;> in set1 that are not in set2.
    (define (set-difference set1 set2)
      (%make-set (bbtree-difference (set-tree set1) (set-tree set2))))

    ))

