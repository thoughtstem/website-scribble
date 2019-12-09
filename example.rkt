#lang racket

#|
(require "./main.rkt")
(require (prefix-in adventure: (lib "adventure/scribblings/manual.scrbl")))
(require (prefix-in survival: (lib "survival/scribblings/manual.scrbl")))

(define adventure-embed (scribble->html adventure:doc "adventure-docs"))
(define survival-embed (scribble->html survival:doc "survival-docs"))

(require website/bootstrap)

;For additional reflection on what the lang provides (what functions, what keywords, etc...?)
(require adventure/lang/main)

(render (bootstrap
            (list
              (scribble-files)

              (page index.html
                      (content
                        #:head (scribble-includes)
                       (container
                        (h1 "Docs!")
                        (row
                         (col-6
                          (card 
                           (card-body
                            (card-text adventure-embed))))
                         (col-6
                          (card 
                           (card-body
                            (card-text survival-embed))))))))))
          #:to "out")

|#
