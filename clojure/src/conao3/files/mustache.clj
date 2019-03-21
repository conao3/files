(ns conao3.files.mustache
  (:require [clostache.parser :as mustache]
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
    (sh "/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome"
        "--headless"
        "--disable-gpu"
        "--screenshot=screenshot.png"
        "--window-size=1000,170"
        (str "file://" (.getCanonicalPath svgfile)))
    (util/move-file "./screenshot.png" pngpath)))

(defn create-header [name]
  (create-header-svg name)
  (create-header-png name))
