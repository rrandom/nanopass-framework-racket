#lang racket
(require rackunit
         syntax/macro-testing
         "../main.rkt")

(define-language L1
  (terminals
    (symbol (s)))
  (Expr (e)
    s
    (foo e)))

(printf "Testing Pass Definition error improvements...\n")

;; Case 1: Outer Check - Unrecognized pass input NT
(check-exn #rx"unrecognized pass input non-terminal 'x' for language 'L1', expected one of: \\(Expr\\)"
  (lambda ()
    (convert-compile-time-error
      (define-pass p1 : (L1 x) (ir) -> L1 () (Expr : Expr (ir) -> Expr () ir)))))

;; Case 2: Inner Check - Unrecognized clause input NT
(check-exn #rx"unrecognized input non-terminal 'InvalidNT' for language 'L1', expected one of: \\(Expr\\)"
  (lambda ()
    (convert-compile-time-error
      (define-pass p2 : L1 (ir) -> L1 ()
        (Expr : InvalidNT (ir) -> Expr () ir)))))

;; Case 3: Inner Check - Unrecognized clause output NT
(check-exn #rx"unrecognized output non-terminal 'InvalidNT' for language 'L1', expected one of: \\(Expr\\)"
  (lambda ()
    (convert-compile-time-error
      (define-pass p3 : L1 (ir) -> L1 ()
        (Expr : Expr (ir) -> InvalidNT () ir)))))

;; Case 4: Meta-variable type mismatch
;; 's' is a terminal (symbol), but we are matching it against 'Expr' (non-terminal).
(check-exn #rx"type mismatch for meta-variable 's'; expected nonterminal 'Expr', but meta-variable has type 'symbol'"
  (lambda ()
    (convert-compile-time-error
      (define-pass p4 : L1 (ir) -> L1 ()
        (Expr : Expr (ir) -> Expr ()
          [(foo ,s) `(foo ,s)])))))

(printf "All Phase 1.3 tests passed!\n")
