(require racket/string minikanren)

(define-syntax ->
  (syntax-rules ()
    [(_ x) x]
    [(_ x (f . args) more ...) (-> (f x . args) more ...)]
    [(_ x f more ...) (-> (f x) more ...)]))

(struct machine (hud buttons) #:transparent)

(define (parse-line line)
  (match (regexp-match
          #px"\\[([^]]+)\\]\\s+([^\\{]+)\\s+\\{([^}]+)\\}"
          line)
    [(list _ hud-str buttons-str joltage-str)
     (machine (parse-hud hud-str) (parse-buttons buttons-str))]))

(define (parse-input filename)
  (map parse-line (file->lines filename)))

(define (hud-chars->bits chars)
  (for/list ([c chars]) (if (char=? c #\#) 1 0)))

(define (parse-hud hud-str)
  (-> hud-str
      (string->list)
      (hud-chars->bits)))

(define (parse-buttons-outer button-str)
  (regexp-match*
   #px"\\(([^)]+)\\)"
   button-str
   #:match-select second))

(define (parse-buttons-inner outer-strs)
  (for/list ([csv outer-strs])
    (map string->number (string-split csv ","))))

(define (parse-buttons button-str)
  (-> button-str
      parse-buttons-outer
      parse-buttons-inner))

(define (conso h t ls)
  (== (cons h t) ls))

(define (bito n)
  (conde
    [(== n 0)]
    [(== n 1)]))

(define (xor2o a b c)
  (conde
    [(== a 0) (== b 0) (== c 0)]
    [(== a 0) (== b 1) (== c 1)]
    [(== a 1) (== b 0) (== c 1)]
    [(== a 1) (== b 1) (== c 0)]))

(define (xor-listo ls out)
  (conde
    [(== ls '()) (== out 0)]
    [(fresh (h t prev-out)
       (bito h)
       (conso h t ls)
       (xor-listo t prev-out)
       (xor2o h prev-out out))]))

(define (lighto press-bits hud-bit)
  (xor-listo press-bits hud-bit))

(define (lightso press-bits-per-light hud-bits)
  (conde
    [(== press-bits-per-light '())
     (== hud-bits '())]
    [(fresh (pb-current pb-rest hud-current hud-rest)
       (conso pb-current pb-rest     press-bits-per-light)
       (conso hud-current hud-rest   hud-bits)
       (lighto pb-current hud-current)
       (lightso pb-rest hud-rest))]))

(define (relevant-buttons-per-light hud buttons)
  (for/list ([i (in-range (length hud))])
    (filter (lambda (button) (member i button)) buttons)))

(define (n-bitso n bit-vars)
  (if (zero? n)
      (== bit-vars '())
      (fresh (b rest)
        (bito b)
        (== bit-vars (cons b rest))
        (n-bitso (- n 1) rest))))

(define (membero x ls)
  (conde
    [(fresh (a d)
       (conso a d ls)
       (== a x))]
    [(fresh (a d)
       (conso a d ls)
       (membero x d))]))

(define (button-light-contribo button press-bit light-idx contrib)
  (conda
    [(membero light-idx button)
     (== contrib press-bit)]
    [(== contrib 0)]))

(define (light-idx-contribo buttons press-bits light-idx hud-bit)
  (conde
    [(== buttons '()) (== press-bits '()) (== hud-bit 0)]
    [(fresh (btn rest-btns press rest-press-bits contrib rest-xor)
       (conso btn rest-btns buttons)
       (conso press rest-press-bits press-bits)
       (bito press)
       (button-light-contribo btn press light-idx contrib)
       (light-idx-contribo rest-btns rest-press-bits light-idx rest-xor)
       (xor2o contrib rest-xor hud-bit))]))

(define (machineo buttons press-bits hud-bits)
  (machineo/rec buttons press-bits hud-bits 0))

(define (machineo/rec buttons press-bits hud-bits idx)
  (conde
    [(== hud-bits '())]
    [(fresh (t rest-hud-bits)
       (conso t rest-hud-bits hud-bits)
       (light-idx-contribo buttons press-bits idx t)
       (machineo/rec buttons press-bits rest-hud-bits (add1 idx)))]))

(define (first-n-solutions machine n)
  (run n (press-bits)
    (n-bitso (length (machine-buttons machine)) press-bits)
    (machineo (machine-buttons machine) press-bits (machine-hud machine))))

(define (comparator a b)
  (< (apply + a) (apply + b)))

(define (best-solution solutions)
  (first (sort solutions comparator)))

(define machines (parse-input "input.txt"))

(define press-bits (map (lambda (m) (first-n-solutions m 10)) machines))

(define best-press-counts (map (lambda (pb) (apply + (best-solution pb))) press-bits))

(apply + best-press-counts)
