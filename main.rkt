#lang play
(require "machine.rkt")
;(print-only-errors #t) 
;;;;;;;;;;;;;;;;;;;;;;;
;; Language definition
;;;;;;;;;;;;;;;;;;;;;;;

#|
<s-expr> ::= <num>
         | <id>
         | {+ <s-expr> <s-expr>}
         | {with {<s-expr> : <type> <s-expr>} <s-expr>}
         | {fun {<id>  : <s-expr>} [: <type>] <expr>}
         | {<expr> <expr>}         
 
<type> ::= Num
         | {<type> -> <type>}}
|#
(deftype Expr
  (num n)
  (add l r)
  (id s) 
  (fun id targ body tbody)
  (fun-db body)
  (acc n) ;Se usa para la pregunta 3
  (app fun-id arg-expr))

(deftype Type
  (TNum)
  (TFun arg ret))


(define (parse-type s-expr)
  (match s-expr
    ['Num (TNum)]
    [(list arg '-> ret ) (TFun (parse-type arg) (parse-type ret))]
    [else (error "Parse error")]
    )
  )

(define (parse s-expr)
  (match s-expr
    [(? number?) (num s-expr)]
    [(list '+ l r) (add (parse l) (parse r))]
    
    [(list 'with (list id ': idtype idval) body) (app (fun id (parse-type idtype)
                                                      (parse body) #f)
                                                 (parse idval))]

    [(? symbol?) (id s-expr)]
    [(list 'fun (list id ': idtype) ': bodytype body) (fun id (parse-type idtype) (parse body) (parse-type bodytype))]
    [(list 'fun (list id ': idtype) body) (fun id (parse-type idtype) (parse body) #f)]
    [(list l r) (if (or (equal? l '+) (equal? l 'fun) (equal? l 'with))
                    (error "Parse error")
                    (app (parse l) (parse r)))]
    
 ) )


(define (deBruijn expr)#f)
(define (compile expr) #f)
;(define (typeof expr)
;(define (typecheck s-expr) #f)
(define (typed-compile s-expr) #f)


(define (typeof expr)
    (match expr
     [(num n) (if (number? n) (TNum) #f)]
     [(add l r) (if (equal? (typeof l) (TNum))
                    (if (equal? (typeof r) (TNum))
                        (TNum)
                        (error "Type error in expression add position 2: expected Num found "  (typeof r)))
                    (error "Type error in expression add position 1: expected Num found "  (typeof l) ))
                    ]
     [(fun id idtype body bodytype)
      (let ([newbody (replaceFun id idtype body)])
        (if (equal? bodytype #f)
            (if (equal? newbody idtype)
                (TFun idtype newbody);;
                (if (add? body)
                    (if (equal? idtype (typeof body))
                        (TFun idtype (typeof body))
                        (error (string-append "Type error in expression fun position 2: expected " (string-append (type2str idtype) (string-append " found "(type2str newbody ))))))
                    (error (string-append "Type error in expression fun position 2: expected " (string-append (type2str idtype) (string-append " found "(type2str newbody ))))))
                )
            
            (if (equal? bodytype idtype)
                (TFun idtype bodytype)
                (
                 error (string-append "Type error in expression fun position 1: expected " (string-append  (type2str bodytype) (string-append " found " (type2str idtype)))))
                )
            
            )
        ) ]      
     [(app l r) (if (fun? l)
                    (let ([funl (typeof l)])
                      (if (fun? r)
                          (error  (string-append "Type error in expression app position 2: expected "  (string-append (type2str (TFun-arg funl)) (string-append " found {Num -> Num}"))))
                          (if (equal? (typeof r) (TFun-arg funl))
                              funl
                              (error "Type error in expression app position 2: expected "  (string-append (type2str (TFun-arg funl)) (string-append " found " (type2str (typeof r))))))
                          )
                      )
                    (error (string-append "Type error in expression app position 1: expected {Num -> Num} found " (type2str l)))
                    )]
      [else (error (string-append "Type error: No type for identifier: " (type2str expr)))]
 ))
;Para una función con el tipo de retorno anotado, se valida que la expresión del
;     cuerpo tenga el mismo tipo que el tipo de retorno declarado.
;Para una función sin el tipo de retorno anotado, el tipo resultante considera el tipo calculado del cuerpo de la función.
;Para la aplicación de función se valida que la expresión en posición de función es efectivamente una función y
;     que el tipo de la expresión de argumento de la aplicación coincide con el tipo esperado del argumento de la función.







(define (replaceFun idx idtype body)
  (match body
    [(id x) (if (equal? x idx) idtype "error?")]
    [(add l r) (TFun (replaceFun idx idtype l) (replaceFun idx idtype r))] ;qual xd
    [(num n) TNum]
    )
  )
(define (type2str type)
  (match type
    [(TNum) "Num"]
    [(TFun l r) (string-append "{"(string-append (type2str l)  (string-append " -> " (string-append (type2str l) "}"))))]
    [(id x) (symbol->string x)]
    [TNum "Num"]
   ))

(define (symbol-append l r)
  (let ([left (if (symbol? l) (symbol->string l) l )]
        [right (if (symbol? r) (symbol->string r) r )])
  (string->symbol (string-append left right ))))


(define (type2sym type)
  (match type
    [(TNum) "Num"]
    [(TFun l r) (~a (list  (type2sym l)   "->" (type2sym l)  ))]
    [(id x) (symbol->string x)]
    [TNum "Num"]
   ))


(define (typecheck s-expr)
 (string->symbol (type2sym (typeof (parse s-expr)))))





;vs


;;bssssssssssssssssssssss

;(print-only-errors #t)
'(todo fain?)


;; parse-type
(test (parse-type 'Num) (TNum))
(test (parse-type '{Num -> Num}) (TFun (TNum) (TNum)))
(test (parse-type '{{Num -> Num} -> Num}) (TFun (TFun (TNum) (TNum)) (TNum)) )
(test (parse-type '{{Num -> Num} -> {Num -> Num}}) (TFun (TFun (TNum) (TNum)) (TFun (TNum) (TNum))) )
(test (parse-type '{Num -> {Num -> {Num -> Num}}}) (TFun (TNum) (TFun (TNum) (TFun (TNum) (TNum)))) )
(test (parse-type '{Num -> {{Num -> Num} -> Num}}) (TFun (TNum) (TFun (TFun (TNum) (TNum)) (TNum))) )

(test/exn (parse-type '{}) "Parse error")
(test/exn (parse-type '{ -> Num}) "Parse error")
(test/exn (parse-type '{Num -> Num -> Num}) "Parse error")

;; parse
(test (parse '{+ 1 3})            (add (num 1) (num 3)))
(test (parse '{+ 1 {+ 1 1}})      (add (num 1) (add (num 1) (num 1))))
(test (parse '{+ {+ 1 1} 1})      (add (add (num 1) (num 1)) (num 1) ))


(test (parse '{with {y : Num 2} {+ x y}})   (app (fun 'y (TNum) (add (id 'x) (id 'y)) #f)(num 2)))
(test (parse '{with {x : Num 5} {+ x 3}})  (app (fun 'x (TNum)(add (id 'x) (num 3)) #f)  (num 5)))
(test (parse '{with {y : Num 3} {+ 1 {+ y 1}}})  (app (fun 'y (TNum) (add (num 1) (add (id 'y) (num 1))) #f)  (num 3)))

(test (parse '{fun {x : Num} : Num {+ x 1}}) (fun 'x (TNum) (add (id 'x) (num 1)) (TNum)) )
(test (parse '{fun {x : Num} : Num 6}) (fun 'x (TNum)  (num 6) (TNum)) )
(test (parse '{{fun {x : Num} : Num {+ x x}} {fun {x : Num} : Num 5}})  (app (fun 'x (TNum) (add (id 'x) (id 'x)) (TNum)) (fun 'x (TNum) (num 5) (TNum))))
(test (parse '{fun {x : Num} : Num {+ 2 3}}) (fun 'x (TNum) (add (num 2) (num 3)) (TNum)))

(test/exn  (parse '{+ 1})     "Parse error")
(test/exn  (parse '{with {y : Num 2} })  "Parse error")
(test/exn  (parse '{fun 1})     "Parse error")


;; typeof
(test (typeof (parse '{+ 1 3})) (TNum))
(test (typeof (parse '{+ {+ 1 2} 4})) (TNum))
(test (typeof (parse '{+ {+ 1 2} {+ 4 5}})) (TNum))

(test (typeof (parse '{fun {x : Num} : Num 5}))  (TFun (TNum) (TNum)) )
(test (typeof (parse '{fun {x : Num} x}))  (TFun (TNum) (TNum)) )
(test (typeof (parse '{fun {x : Num} : Num {+ 2 3}})) (TFun (TNum) (TNum)))





(parse '{fun {x : Num} x})
(test (typeof (parse '{fun {x : Num} x}))  (TFun (TNum) (TNum)) )
(parse '{with {x : Num 5} x})
(test (typeof (parse '{with {x : Num 5} x}))  (TFun (TNum) (TNum)) )

(parse '{{fun {x : Num} : Num {+ 2 3}} 5})
(test (typeof (parse '{{fun {x : Num} : Num {+ 2 3}} 5}) ) (TFun (TNum) (TNum)))
(parse '{with {x : Num 5} {+ 2 3}})                             
(test (typeof (parse '{with {x : Num 5} {+ 2 3}}) ) (TFun (TNum) (TNum)))

(parse '{{fun {x : Num} : Num {+ 2 x}} 5})
(test (typeof (parse '{{fun {x : Num} : Num {+ 2 x}} 5}) ) (TFun (TNum) (TNum)))


(parse '{with {x : Num 5} {+ 2 x}})                               ;;;;;;;;;;;;;;
"aka v"
(test (typeof (parse '{with {x : Num 5} {+ 2 x}}) ) (TFun (TNum) (TNum)))
"aka ^"







(test/exn (typeof (parse '{fun {x : Num} : {Num -> Num} 10}))
  "Type error in expression fun position 1: expected {Num -> Num} found Num" )
(test/exn (typeof (parse '{{fun {x : Num} : Num {+ x x}} {fun {x : Num} : Num 5}}))
  "Type error in expression app position 2: expected Num found {Num -> Num}" )
(test/exn (typeof (parse '{Num {fun {x : Num} : Num 3}}))
  "Type error in expression app position 1: expected {Num -> Num} found Num" )
(test/exn (typeof (parse 'y))
  "Type error: No type for identifier: y"  )



;typecheck
(test (typecheck '3) 'Num)
(test (typecheck  '{fun {f : Num} : Num 10}) '{Num -> Num})
 
(test/exn (typecheck  '{+ 2 {fun {x : Num} : Num x}})  "Type error in expression + position 2: expected Num found {Num -> Num}")
