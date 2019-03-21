(ns conao3.files.mustache
  (:require [clostache.parser :as mustache])
  (:gen-class))

(defn create-header-svg [name]
  (-> (str "../headers/svg/" name ".svg")
      (spit (mustache/render-resource "header.svg.mustache" {:name name}))))

(defn create-header-png [name])

(defn create-header [name]
  (create-header-svg name)
  (create-header-png name))

