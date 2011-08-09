#! /usr/bin/mzscheme
#lang scheme
(require (planet dherman/set:5:0))


(define sortedString
  (lambda (str)
    (apply string (sort (string->list str) char<?))))


(define addWord
  (lambda (table unsortedWord)
    (let ((sortedWord (sortedString unsortedWord)))
      (hash-set! table sortedWord
                 (set-add unsortedWord (hash-ref table sortedWord
                                                 (lambda () empty-set)))))))


(when (< (length (vector->list (current-command-line-arguments))) 1)
  (display "usage: jumble_solver.sm DICT_FILE [DICT_FILE] ...\n")
  (exit))

(let ((sortedToOrigs (make-hash)))
  (for ([dictFileName (current-command-line-arguments)])
       (for ((origWord (in-lines (open-input-file dictFileName))))
            (addWord sortedToOrigs origWord)))

  (display "$ ")
  (for ((jumbledWord (in-lines)))
       (cond ((string? jumbledWord)
              (letrec ((sortedWord (sortedString jumbledWord))
                       (origWords (hash-ref sortedToOrigs sortedWord '())))
                (if (eq? origWords '())
                  (display "no anagrams found in dictionary")
                  (for ((origWord origWords))
                       (display origWord)
                       (display #\space)))
                (newline)
                (display "$ ")))))
  (newline))


