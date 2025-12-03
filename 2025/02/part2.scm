(define in-port (open-input-file "input.txt"))
(define input (read-line in-port))

(define-syntax ->>
  (syntax-rules ()
    ((->> x) x) 
    ((->> x (fn args ...) rest ...) (->> (fn args ... x) rest ...))
    ((->> x fn rest ...) (->> (fn x) rest ...))))

(define (split delimiter text) ((string-splitter 'delimiter delimiter) text))

(define (is-repeat-of slice rest)
  (cond
    ((string=? rest "") #t)
    ((> (string-length slice) (string-length rest)) #f)
    (else (and
            (string=? slice (substring rest 0 (string-length slice)))
            (is-repeat-of slice (substring rest (string-length slice) (string-length rest)))))))

(define (any lst)
  (cond
    ((null? lst) #f)
    ((car lst) #t)
    (else (any (cdr lst)))))

(define (all-slices-up-to-half-helper str n acc)
  (if (> n (/ (string-length str) 2))
      acc
      (all-slices-up-to-half-helper str (+ n 1) (cons (substring str 0 n) acc))))

(define (all-slices-up-to-half str)
  (all-slices-up-to-half-helper str 1 '()))

(define (is-invalid-id str)
  (any (map (lambda (n) (is-repeat-of n str)) (all-slices-up-to-half str))))

(define (process-range i end acc)
  (if (> i end)
      acc
      (let
        ((new-acc (if (is-invalid-id (number->string i)) (+ acc i) acc)))
        (process-range (+ i 1) end new-acc))))

(->> input
     (split #\,)
     (map (lambda (n) (split #\- n)))
     (map (lambda (pair) (map string->number pair)))
     (map (lambda (pair) (process-range (car pair) (car (cdr pair)) 0)))
     (apply +)
     )



