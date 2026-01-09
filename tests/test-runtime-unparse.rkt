#lang racket
(require "../main.rkt"
         rackunit)

(define-language L1
  (entry Expr)
  (terminals
    (symbol (s)))
  (Expr (e)
    s
    (Wrap stmt))
  (Stmt (stmt)
    (MyStmt e)))

(define-parser parse-L1 L1)

(define-pass p1 : L1 (x) -> L1 ()
  (Expr : Expr (expr) -> Expr ()
    [else (if (eq? expr 'bad)
              (parse-L1 '(Wrap (MyStmt bad))) ;; Valid Expr
              'invalid-atom)])) ;; Invalid atom

;; Test 1: Invalid atom matches regex
(check-exn #rx"expected Expr but got invalid-atom"
           (lambda () (p1 'not-bad)))

(define-pass p-mix : L1 (x) -> L1 ()
  (Expr : Expr (expr) -> Expr ()
    [else
     (let ([r (parse-L1 '(Wrap (MyStmt bad)))])
       (nanopass-case (L1 Expr) r
         [(Wrap ,stmt) stmt]
         [else (error "setup failed")]))])) ;; Returns Stmt, expecting Expr

(printf "Testing Runtime Unparsing Error...\n")
(with-handlers ([exn:fail? (lambda (e)
                             (printf "Caught expected error: ~a\n" (exn-message e))
                             (if (regexp-match? #rx"expected Expr but got #<language:L1: \\(MyStmt bad\\)>" (exn-message e))
                                 (printf "PASS: Error message contains readable record.\n")
                                 (begin
                                   (printf "FAIL: Regex check failed.\n")
                                   (raise e))))])
  (p-mix 's))
