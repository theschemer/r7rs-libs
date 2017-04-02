;; Original Test Suite from https://github.com/ijp/pfds
;; converted to use SRFI 64 tests by Peter Lane

(import (scheme base)
        (pfds deque)
        (only (srfi 1) fold)
        (srfi 64)
        (robin srfi64-utils)
        (srfi 95))

(test-begin "pfds-deque")

;; empty-deque
(test-assert (deque? (make-deque)))
(test-assert (deque-empty? (make-deque)))
(test-equal 0 (deque-length (make-deque)))

;; deque-insert 
(let ((deq (enqueue-front (make-deque) 'foo)))
  (test-assert (deque? deq))
  (test-equal 1 (deque-length deq)))
(let ((deq (enqueue-rear (make-deque) 'foo)))
  (test-assert (deque? deq))
  (test-equal 1 (deque-length deq)))
(test-equal 5 (deque-length
                (fold (lambda (pair deque)
                        ((car pair) deque (cdr pair)))
                      (make-deque)
                      `((,enqueue-front . 0)
                        (,enqueue-rear  . 1)
                        (,enqueue-front . 2)
                        (,enqueue-rear  . 3)
                        (,enqueue-front . 4)))))

;; deque-remove
(let ((deq (enqueue-front (make-deque) 'foo)))
  (let-values (((item0 deque0) (dequeue-front deq))
               ((item1 deque1) (dequeue-rear deq)))
              (test-equal 'foo item0)
              (test-equal 'foo item1)
              (test-assert (deque-empty? deque0))
              (test-assert (deque-empty? deque1))))
(let ((deq (fold (lambda (item deque)
                   (enqueue-rear deque item))
                 (make-deque)
                 '(0 1 2 3 4 5))))
  (let*-values (((item0 deque0) (dequeue-front deq))
                ((item1 deque1) (dequeue-front deque0))
                ((item2 deque2) (dequeue-front deque1)))
               (test-equal 0 item0)
               (test-equal 1 item1)
               (test-equal 2 item2)
               (test-equal 3 (deque-length deque2))))
(let ((deq (fold (lambda (item deque)
                   (enqueue-rear deque item))
                 (make-deque)
                 '(0 1 2 3 4 5))))
  (let*-values (((item0 deque0) (dequeue-rear deq))
                ((item1 deque1) (dequeue-rear deque0))
                ((item2 deque2) (dequeue-rear deque1)))
               (test-equal 5 item0)
               (test-equal 4 item1)
               (test-equal 3 item2)
               (test-equal 3 (deque-length deque2))))
(let ((empty (make-deque)))
  (test-for-error (dequeue-front empty))
  (test-for-error (dequeue-rear empty)))

;; mixed-operations
(let ((deque (fold (lambda (pair deque)
                     ((car pair) deque (cdr pair)))
                   (make-deque)
                   `((,enqueue-front . 0)
                     (,enqueue-rear  . 1)
                     (,enqueue-front . 2)
                     (,enqueue-rear  . 3)
                     (,enqueue-front . 4)))))
  (let*-values (((item0 deque) (dequeue-front deque))
                ((item1 deque) (dequeue-front deque))
                ((item2 deque) (dequeue-front deque))
                ((item3 deque) (dequeue-front deque))
                ((item4 deque) (dequeue-front deque)))
               (test-equal 4 item0)
               (test-equal 2 item1)
               (test-equal 0 item2)
               (test-equal 1 item3)
               (test-equal 3 item4))
  (let ((deq (fold (lambda (item deque)
                     (enqueue-rear deque item))
                   (make-deque)
                   '(0 1 2))))
    (let*-values (((item0 deque0) (dequeue-rear deq))
                  ((item1 deque1) (dequeue-front deque0))
                  ((item2 deque2) (dequeue-rear deque1)))
                 (test-equal 2 item0)
                 (test-equal 0 item1)
                 (test-equal 1 item2)
                 (test-assert (deque-empty? deque2)))))

;; list-conversion
(let ((id-list (lambda (list)
                 (deque->list (list->deque list))))
      (l1 '())
      (l2 '(1 2 3))
      (l3 '(4 5 6 7 8 9 10))
      (l4 (string->list "abcdefghijklmnopqrstuvwxyz")))
  (test-equal l1 (id-list l1))
  (test-equal l2 (id-list l2))
  (test-equal l3 (id-list l3))
  (test-equal l4 (id-list l4)))

(test-end)

