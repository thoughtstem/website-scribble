#lang at-exp racket

(provide scribble->html
         scribble-files
         scribble-includes)

(require scribble/manual 
         scribble/decode 
         scribble/render 
         scribble/html-render 
         scribble/base-render
         xml
         web-server/templates
         (only-in website html/inline site-dir page style/inline include-css iframe script/inline)
         racket/runtime-path)

(define-runtime-path here ".")

(define (scribble-files)
 (list
  (page css/manual-racket.css (file->string (build-path here "css" "manual-racket.css")))
  (page css/manual-style.css (file->string (build-path here "css" "manual-style.css")))
  (page css/scribble-style.css (file->string (build-path here "css" "scribble-style.css")))
  (page css/scribble.css (file->string (build-path here "css" "scribble.css")))))

(define (scribble-includes)
 (list 
   @script/inline{
    function resizeIframe(obj) {
      obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
    }
   }

  ;No longer necessary with iframe trick
  #;
  (include-css "css/scribble.css")
  #;
  (include-css "css/scribble-style.css")
  #;
  (include-css "css/manual-racket.css")
  ))

(define (scribble->html doc name)
 (thunk*
  (define dest-dir (build-path (site-dir) name))

  (render 
     (list doc) 
     (list name)
     #:dest-dir dest-dir)

  (list
   (iframe 'src: (~a name "/" name ".html") 
    'frameborder: "0" 
    'scrolling: "no"
    'onload: "var t = this;setInterval(function(){resizeIframe(t)},1000);"
    'style: "width:100%; border: none;"))

  ;The iframe trick is simpler.
  ; Below was my earlier implementation, which we'll have to return to if we want to
  ; do some kind of deeper embedding of the content, independent of the iframe sandbox...

  #;
  (define x
   (xexpr->string
    (list-set ;snipes out id="main"
     (first
      (drop ;Gets main
       (third ;Gets maincolumn
        (rest ;Gets children of body
         (third ;Gets body
          (rest ;Gets children of html
           (xml->xexpr 
            (document-element 
             (read-xml 
               (open-input-file (build-path (site-dir) name (~a name ".html"))))))))))
       2))
     1 '([class "scribble-extracted"]))))

  #;
  (define hacked-x
    (regexp-replaces x
      `([#px"src=\"(pict_*\\d*.png)\"" 
            ,(~a "src=\"" name "/\\1\"")])))

  #;
  (html/inline hacked-x)
  ))

(module+ test
  (require rackunit website/bootstrap)
         

  (require (lib "adventure/scribblings/manual.scrbl"))
  (render (list
            (scribble-files)
            (page index.html
                (content #:head (scribble-includes)
                  (scribble->html doc "temp"))))
          #:to "out")

  (check-true 
    (directory-exists? (build-path here "out" "temp"))))


