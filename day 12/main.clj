(:require '[clojure.java.io])
(:require '[clojure.string])
(:require '[clojure.lang.PersistentQueue])

(def lines (with-open [rdr (clojure.java.io/reader "input")] (into [] (line-seq rdr))))
(def heightmap
  (into [] (map (fn [str] (into [] (map #(- (int %) (if (< (int %) 97) (if (= (int %) 83) 83 44) 97)) str))) lines)))
(def start (first (filter (fn [[_ _ _ column]] (not= column -1))
                        (map-indexed #(list 0 0 %1 (.indexOf (into [] %2) \S)) lines))))
(def end (first (filter (fn [[_ column]] (not= column -1))
                        (map-indexed #(list %1 (.indexOf (into [] %2) \E)) lines))))
(def size (list (count heightmap) (count (first heightmap))))
(defn update-position [[len i x y], valuemap] (filter (fn [[_ _ new-x new-y]]
                                                    (if (and (>= new-x 0) (>= new-y 0) (< new-x (first size)) (< new-y (last size)) (<= (get-in heightmap [new-x new-y]) (inc (get-in heightmap [x y]))) (<= i (get-in valuemap [x y])))
                                                      true
                                                      false))
                                                  (vector (list len i (+ x 1) y) (list len i (- x 1) y) (list len i x (+ y 1)) (list len i x (- y 1)))))
(defn find-route [heightmap]
  (loop [valuemap (into [] (replicate (count heightmap) (into [] (replicate (count (first heightmap)) 1000)))),
         queue (conj clojure.lang.PersistentQueue/EMPTY start)]
    (if (or (seq queue) (= [(first (peek queue)) (last (peek queue))] end))
      (let [[len i x y] (peek queue)]
        (recur (assoc valuemap x (assoc (valuemap x) y len)) (reduce conj (pop queue) (update-position [(if (= (get-in heightmap [x y]) 0) 1 (inc len)) (inc i) x y] valuemap))))
      (get-in valuemap end))))
(println (find-route heightmap))