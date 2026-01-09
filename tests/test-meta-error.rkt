#lang racket
(require "../main.rkt")

(define-language L1
  (terminals
    (symbol (s)))
  (Expr (e)
    s
    (foo e)))

;; Trigger "unrecognized meta variable" error in meta-parser
(define-pass p : L1 (ir) -> L1 ()
  (Expr : Expr (ir) -> Expr ()
    [(foo ,x) `(foo ,x)])) ;; x is not a recognized meta-var for s or Expr
