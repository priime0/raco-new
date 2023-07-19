#lang racket

(require racket/cmdline)
(require raco/command-name)

(define args
  (command-line
   #:program (short-program+command-name)
   #:args    args
   args))

(define (@ . strs)
  (displayln (string-join (map ~a strs) " ")))

(define (@e . strs)
  (displayln (~a "ERROR: " (string-join (map ~a strs) " "))))

(unless (= 1 (length args))
  (@e "Expected a single argument (the new project name) but instead got args: ["
     (string-join args ", ")
     "]")
  (exit 1))

(define proj-name (car args))

(@ "Making project" proj-name "...")

(define proj-root (~a proj-name))
(define proj-main (~a proj-root "/" proj-name))
(define proj-lib  (~a proj-main "-lib"))
(define proj-doc  (~a proj-main "-doc"))
(define proj-test (~a proj-main "-test"))

(when (directory-exists? proj-root)
  (@e "Directory" proj-root "already exists")
  (exit 1))

(for ([dir (list proj-root proj-main proj-lib proj-doc proj-test)])
  (@ "Creating directory" dir)
  (make-directory dir))

(define info-suffix "/info.rkt")
(define info-main (~a proj-main info-suffix))
(define info-lib  (~a proj-lib  info-suffix))
(define info-doc  (~a proj-doc  info-suffix))
(define info-test (~a proj-test info-suffix))

(define (write-lines file lines)
  (define op (open-output-file file))
  (define contents (string-join lines "\n"))
  (write contents op))

(@ "Creating file" info-main)
(write-lines info-main
             `("#lang info"
               ""
               ,(format "(define name \"~a\")" proj-name)
               "(define collection 'multi"
               "(define pkg-desc \"\")"
               "(define pkg-authors '())"
               "(define version \"0.1.0\""
               "(define license 'MIT)"
               ""
               ,(format "(define deps '(~a ~a))"
                        (~a proj-name "-lib")
                        (~a proj-name "-doc"))))

(@ "Creating file" info-lib)
(write-lines info-lib
             `("#lang info"
               ""
               "(define collection 'multi)"
               "(define version \"0.1.0\")"
               "(define license 'MIT)"
               ""
               "(define deps '(\"lib\"))"
               ""
               ,(format "(define setup-collects '(~a))" proj-name)))

(@ "Creating file" info-doc)
(write-lines info-doc
             `("#lang info"
               ""
               "(define license 'MIT)"
               ,(format "(define collection ~a)" proj-name)
               ,(format "(define scribblings '((~a (multi-page))))"
                        (~a "scribblings/" proj-name))))

(@ "Creating file" info-test)
(write-lines info-test
             `("#lang info"
               ""
               "(define collection \"tests\")"
               "(define license 'MIT)"
               ""
               "(define deps '())"
               "(define build-deps '(\"base\"))"
               ""
               ,(format "(define update-implies '(~a))"
                        (~a proj-name "-lib"))))

(@ "Creating file" (~a proj-root "/.gitignore"))
(write-lines (~a proj-root "/.gitignore")
             `(".DS_Store"
               "compiled/"
               "*~"
               "*.bak"
               "\\#*"
               ".\\#*"
               "doc/"))

(@ "Project" proj-name "created")
(exit 0)
