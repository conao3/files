(ns conao3.files.mustache
  (:require [clostache.parser :as mustache]
            [clojure.string :as string]
            [clojure.java.io :as io]
            [clojure.java.shell :refer [sh]]
            [conao3.files.util :as util])
  (:gen-class))

(defn create-header-svg [name]
  (-> (str "../header/svg/" name ".svg")
      (spit (mustache/render-resource "header.svg.mustache" {:name name}))))

(defn create-header-png [name]
  (let [svgpath (str "../header/svg/" name ".svg")
        pngpath (str "../header/png/" name ".png")
        svgfile (io/file svgpath)]
    (when-not (.exists svgfile) (create-header-svg name))
    (println (str "aa " (.toString (java.util.Date.))))
    (sh "bash" "-c"
        (string/join
         " "
         ["/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome"
          "--headless"
          "--disable-gpu"
          "--screenshot=screenshot.png"
          "--window-size=1000,170"
          (str "file://" (.getCanonicalPath svgfile))]))
    (println (str "bb " (.toString (java.util.Date.))))
    (util/move-file "./screenshot.png" pngpath)
    (println (str "cc " (.toString (java.util.Date.))))))

(defn create-header [args]
  (let [name (first args)]
    (println (str "a  " (.toString (java.util.Date.))))
    (create-header-svg name)
    (println (str "b  " (.toString (java.util.Date.))))
    (create-header-png name)
    (println (str "c  " (.toString (java.util.Date.))))))
