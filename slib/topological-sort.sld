;;; "tsort.scm" Topological sort
;;; Copyright (C) 1995 Mikael Djurfeldt
;;; This code is in the public domain.

;;; The algorithm is inspired by Cormen, Leiserson and Rivest (1990)
;;; "Introduction to Algorithms", chapter 23

;; Packaged for R7RS Scheme by Peter Lane, 2017

(define-library
  (slib topological-sort)
  (export topological-sort)
  (import (scheme base)
          (srfi 69))  ;; TODO: update to SRFI 125?

  (begin

    ;;@code{(require 'topological-sort)} or @code{(require 'tsort)}
    ;;@ftindex topological-sort
    ;;@ftindex tsort

    ;;@noindent
    ;;The algorithm is inspired by Cormen, Leiserson and Rivest (1990)
    ;;@cite{Introduction to Algorithms}, chapter 23.

    ;;@body
    ;;@defunx topological-sort dag pred
    ;;where
    ;;@table @var
    ;;@item dag
    ;;is a list of sublists.  The car of each sublist is a vertex.  The cdr is
    ;;the adjacency list of that vertex, i.e. a list of all vertices to which
    ;;there exists an edge from the car vertex.
    ;;@item pred
    ;;is one of @code{eq?}, @code{eqv?}, @code{equal?}, @code{=},
    ;;@code{char=?}, @code{char-ci=?}, @code{string=?}, or @code{string-ci=?}.
    ;;@end table
    ;;
    ;;Sort the directed acyclic graph @1 so that for every edge from
    ;;vertex @var{u} to @var{v}, @var{u} will come before @var{v} in the
    ;;resulting list of vertices.
    ;;
    ;;Time complexity: O (|V| + |E|)
    ;;
    ;;Example (from Cormen):
    ;;@quotation
    ;;Prof. Bumstead topologically sorts his clothing when getting
    ;;dressed.  The first argument to @0 describes which
    ;;garments he needs to put on before others.  (For example,
    ;;Prof Bumstead needs to put on his shirt before he puts on his
    ;;tie or his belt.)  @0 gives the correct order of dressing:
    ;;@end quotation
    ;;
    ;;@example
    ;;(require 'tsort)
    ;;@ftindex tsort
    ;;(tsort '((shirt tie belt)
    ;;         (tie jacket)
    ;;         (belt jacket)
    ;;         (watch)
    ;;         (pants shoes belt)
    ;;         (undershorts pants shoes)
    ;;         (socks shoes))
    ;;       eq?)
    ;;@result{}
    ;;(socks undershorts pants shoes watch shirt belt tie jacket)
    ;;@end example
    (define (topological-sort dag pred)
      (if (null? dag)
        '()
        (let* ((adj-table (make-hash-table pred))
               (sorted '()))
          (letrec ((visit
                     (lambda (u adj-list)
                       ;; Color vertex u
                       (hash-table-set! adj-table u 'colored)
                       ;; Visit uncolored vertices which u connects to
                       (for-each (lambda (v)
                                   (let ((val (hash-table-ref/default adj-table v #f)))
                                     (if (not (eq? val 'colored))
                                       (visit v (or val '())))))
                                 adj-list)
                       ;; Since all vertices downstream u are visited
                       ;; by now, we can safely put u on the output list
                       (set! sorted (cons u sorted)))))
            ;; Hash adjacency lists
            (for-each (lambda (def)
                        (hash-table-set! adj-table (car def) (cdr def)))
                      (cdr dag))
            ;; Visit vertices
            (visit (caar dag) (cdar dag))
            (for-each (lambda (def)
                        (let ((val (hash-table-ref/default adj-table (car def) #f)))
                          (if (not (eq? val 'colored))
                            (visit (car def) (cdr def)))))
                      (cdr dag)))
          sorted)))
    ))

