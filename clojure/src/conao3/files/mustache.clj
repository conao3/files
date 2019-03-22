(ns conao3.files.mustache
  (:require [clostache.parser :as mustache]
            [clojure.string :as string]
            [clojure.java.io :as io]
            [clojure.java.shell :refer [sh]]
            [conao3.files.util :as util])
  (:gen-class))

(defn create-header-svg [name options]
  (-> (str "../header/svg/" name ".svg")
      (spit (mustache/render-resource "header.svg.mustache" {:name name}))))

(defn create-header-png [name {:keys [chrome] :as options}]
  (let [svgpath (str "../header/svg/" name ".svg")
        pngpath (str "../header/png/" name ".png")
        svgfile (io/file svgpath)]
    (when-not (.exists svgfile) (create-header-svg name))
    (let [ret (sh "bash" "-c"
                  (string/join
                   " "
                   [(if chrome chrome
                        "/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome")
                    "--headless"
                    "--disable-gpu"
                    "--screenshot=screenshot.png"
                    "--window-size=1000,170"
                    (str "file://" (.getCanonicalPath svgfile))]))]
      (when-not (zero? (:exit ret))
        (throw (java.lang.Exception. (string/join
                                      " "
                                      ["[conao3]: Fail convert command"
                                       "Return Value:" (:exit ret)
                                       "Message:" (:out ret) (:err ret)])))))
    (util/move-file "./screenshot.png" pngpath)))

(defn create-header [options]
  (let [name (first (:rest options))]
    (create-header-svg name options)
    (create-header-png name options)))
