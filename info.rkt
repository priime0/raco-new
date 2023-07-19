#lang info

(define name "raco-new")
(define collection "raco-new")
(define pkg-desc "A raco command for quickly creating new projects")
(define pkg-authors '(priime0))
(define version "0.1")
(define license 'MIT)

(define deps '("base"))
(define raco-commands
  '(("new"
     raco-new/main
     "create and set up a new project"
     110)))
