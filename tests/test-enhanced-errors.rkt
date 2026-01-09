#lang racket
(require rackunit
         syntax/macro-testing
         "../main.rkt")

;; 1.1 验证 Meta-parser 报错包含建议
(printf "Testing Meta-parser error improvements...\n")
(check-exn #rx"unrecognized meta-variable 'x' in language 'L1', expected one of: \\(s e\\)"
           (lambda ()
             (convert-compile-time-error
              (let ()
                (define-language L1 (terminals (symbol (s))) (Expr (e) s (foo e)))
                (define-pass p : L1 (ir) -> L1 () (Expr : Expr (ir) -> Expr () [(foo ,x) `(foo ,x)]))
                (void)))))

;; 1.2 验证 Language Definition 报错包含项名称
(printf "Testing Language Definition error improvements...\n")
(check-exn #rx"unrecognized terminal 'non-existent' in subtract, expected one of: \\(symbol\\)"
           (lambda ()
             (convert-compile-time-error
              (let ()
                (define-language L-base (terminals (symbol (s))) (Expr (e) s))
                ;; terminals 减法需要 (term (meta ...)) 格式
                (define-language L-ext (extends L-base) (terminals (- (non-existent ()))))
                (void)))))

(check-exn #rx"unrecognized production 'Expr2' in subtract, expected one of: \\(s\\)"
           (lambda ()
             (convert-compile-time-error
              (let ()
                (define-language L-base (terminals (symbol (s))) (Expr (e) s))
                ;; 生产式减法
                (define-language L-ext (extends L-base) (Expr (e) (- Expr2)))
                (void)))))

(printf "All Phase 1 tests passed!\n")
