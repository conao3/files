(ns conao3.files.mustache
  (:require [clostache.parser :as mustache]
            [clojure.java.io :as io]
            [clojure.java.shell :refer [sh]])
  (:gen-class))

(defn create-header-svg [name]
  (-> (str "../headers/svg/" name ".svg")
      (spit (mustache/render-resource "header.svg.mustache" {:name name}))))

(defn create-header-png [name]
  (let [svgfile (io/file (str "../headers/svg" name ".svg"))]
    (when-not (.exists svgfile) (create-header-svg name))
    (sh "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
        "--headless"
        "--disable-gpu"
        "--screenshot=screenshot.png"
        "--window-size=1000,170"
        (str "file://" (.getCanonicalPath svgfile))))

(defn create-header [name]
  (create-header-svg name)
  (create-header-png name))

