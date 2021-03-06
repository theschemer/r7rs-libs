
(import (except (scheme base) quotient remainder modulo)
        (slib math-integer)
        (srfi 64))

(test-begin "slib-math-integer")

(test-equal 16 (integer-expt 2 4))
(test-equal 1 (integer-expt 0 0))
(test-equal 0 (integer-expt 0 2))
(test-error (integer-expt 0 -2))
(test-error (integer-expt 2 -2))
(test-error (integer-expt 2.1 4))
(test-error (integer-expt 2 4.1))

(test-error (integer-log 2.3 3))
(test-error (integer-log 2 3.2))
(test-equal 3 (integer-log 2 9))

(test-error (integer-sqrt -2))
(test-equal 3 (integer-sqrt 9))
(test-equal 3 (integer-sqrt 10))

(test-error (quotient 4 2.3))
(test-error (quotient 4.1 2))
(test-error (remainder 4 2.3))
(test-error (remainder 4.1 2))
(test-error (modulo 4 2.3))
(test-error (modulo 4.1 2))

(test-equal 1 (quotient 3 2))
(test-equal 2 (round-quotient 3 2))

(test-end)

