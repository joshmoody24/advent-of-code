(require '[clojure.string :as str])

(defn parse-input [path]
  (let [[range-strs id-strs]
        (-> path
            (slurp)
            (str/split #"\n\n")
            (#(mapv str/split-lines %)))]
    {:ranges (mapv
              #(mapv Long/parseLong (str/split % #"-"))
              range-strs)
     :ids (mapv Long/parseLong id-strs)}))

(def data
  (parse-input "input.txt"))

(defn in-range? [id range]
  (and (>= id (first range)) (<= id (second range))))

(defn in-any-range? [ranges id]
  (some #(in-range? id %) ranges))

(def part-1-answer
  (->>
   (:ids data)
   (filter #(in-any-range? (:ranges data) %))
   (count)))

part-1-answer

(defn overlap? [r1 r2]
  (<=
   (max (first r1) (first r2))
   (min (second r1) (second r2))))

(defn size [[lo hi]]
  (inc (- hi lo)))

; confusing name but I like the rhyme
; adds a new range to a minimal set of ranges
(defn append-or-extend [minimal-range-set range]
  (if-let [prev-range (last minimal-range-set)]
    (if (overlap? range prev-range)
      (conj
       (pop minimal-range-set)
       [(first prev-range)
        (max (second prev-range) (second range))])
      (conj minimal-range-set range))
    [range]))

(defn merge-ranges [ranges]
  (->> ranges
       (sort-by first)
       (reduce append-or-extend [])))

(def part-2-answer
  (->>
   (sort-by first (:ranges data))
   (merge-ranges)
   (map size)
   (reduce +)))

part-2-answer
