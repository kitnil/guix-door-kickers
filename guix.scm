;; GNU Guix package recipe for Door Kickers game
;; Copyright © 2020 Oleg Pykhalov <go.wigust@gmail.com>
;; Released under the GNU GPLv3 or any later version.

(use-modules ((guix licenses) #:prefix license:)
             (gnu packages audio)
             (gnu packages base)
             (gnu packages compression)
             (gnu packages elf)
             (gnu packages games)
             (gnu packages gcc)
             (gnu packages gl)
             (gnu packages xiph)
             (gnu packages xorg)
             (gnu packages)
             (guix build-system trivial)
             (guix download)
             (guix packages)
             (guix utils)
             (tome4 packages gogextract))

;;; Commentary:
;;;
;;; This module provides GNU Guix package recipes for Door Kickers game.  You
;;; need to buy on GOG.com (<https://www.gog.com/>) and place installer shell
;;; script to current guix.scm file's directory.
;;;
;;; Then install the game with command:
;;; guix install $(guix build --system=i686-linux -f ./guix.scm)
;;;
;;; Code:

(define-public door-kickers
  (package
    (name "door-kickers")
    (version "2.7.0.11")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "file://" (dirname (current-filename))
                           "/gog_door_kickers_2.7.0.11.sh"))
       (file-name (string-append name "-" version))
       (sha256
        (base32
         "0c1m8zgi1iavix56g5sipjczzac0awn2135y20vf8ind9s0r2wwk"))))
    (build-system trivial-build-system)
    (inputs
     `(("gogextract" ,gogextract)
       ("mesa" ,mesa)
       ("libxxf86vm" ,libxxf86vm)
       ("libx11" ,libx11)
       ("libtheora" ,libtheora)
       ("libogg" ,libogg)
       ("gcc" ,gcc-7 "lib")
       ("openal" ,openal)
       ("glibc" ,glibc)
       ("patchelf" ,patchelf)))
    (native-inputs
     `(("unzip" ,unzip)))
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (let ((file-name (string-append ,name "-" ,version ".sh"))
               (bin (string-append %output "/bin"))
               (share (string-append %output "/share/" ,name)))
           (use-modules (guix build utils))
           (setenv "PATH"
                   (string-append
                    (assoc-ref %build-inputs "gogextract") "/bin" ":"
                    (assoc-ref %build-inputs "unzip") "/bin"))
           (copy-file (assoc-ref %build-inputs "source") file-name)
           (invoke "gogextract" file-name ".")
           (invoke "unzip" "data.zip")
           (mkdir-p share)
           (copy-recursively "data/noarch/game" share)
           (invoke (string-append (assoc-ref %build-inputs "patchelf") "/bin/patchelf")
                   "--set-interpreter"
                   (string-append (assoc-ref %build-inputs "glibc") "/lib/ld-linux.so.2")
                   (string-append share "/DoorKickers"))
           (mkdir-p bin)
           (with-output-to-file (string-append bin "/door-kickers")
             (lambda ()
               (display "#!/bin/sh")
               (newline)
               (format #t "cd ~a~%" share)
               (format #t "LD_LIBRARY_PATH=~a~%"
                       (string-join (list (string-append (assoc-ref %build-inputs "openal") "/lib")
                                          (string-append (assoc-ref %build-inputs "mesa") "/lib")
                                          (string-append (assoc-ref %build-inputs "libx11") "/lib")
                                          (string-append (assoc-ref %build-inputs "libxxf86vm") "/lib")
                                          (string-append (assoc-ref %build-inputs "gcc") "/lib")
                                          (string-append (assoc-ref %build-inputs "libtheora") "/lib")
                                          (string-append (assoc-ref %build-inputs "libogg") "/lib")
                                          (string-append share "/data/noarch/game/linux_libs"))
                                    ":"))
               (display "export LD_LIBRARY_PATH")
               (newline)
               (format #t "exec -a door-kickers ./DoorKickers ~s~%" "$@")))
           (chmod (string-append bin "/door-kickers") #o555)
           #t))))
    (home-page "https://www.gog.com/game/door_kickers")
    (synopsis "Real-time strategy game")
    (description "This package provides Door Kickers real-time strategy
game.")
    (license license:gpl3+)))

door-kickers
