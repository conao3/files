(ns conao3.files.mustache
  (:require [clostache.parser :as mustache])
  (:gen-class))

(defn create-header-svg [name]
  (-> (str "./images/svg/" name ".svg")
      (spit (mustache/render-resource "header.svg.mustache" {:name name}))))

