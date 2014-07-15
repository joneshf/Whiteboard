; # Generate random strings, useful for ID's and such
(defn randomString [numchars]
    (let [pool "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"]
             (apply str (for [i (range numchars)] 
                (.charAt pool (Math/floor (* (Math/random) (count pool))))
    ))))
; A list of generated valid characters


; (map char (concat (range 48 58) (range 66 91) (range 97 123)))

; (defn randString 
;     ([numchars] (randString 0 numchars "")) 
;     ([start, stop, string] 
;         (if (= start stop) 
;             (string) 
;             (let [s (str string (.charAt pool (Math/floor (* (Math/random) (count pool)))))]
;                 (randString (inc start) stop s)
;             )))
; )

; (let [pool (apply str (map char (concat (range 48 58) (range 66 91) (range 97 123))))] 
;     (randString 20))