(ns conao3.files.util
  (:require [clojure.java.io :as io])
  (:gen-class))

(defn move-file [oldpath newpath]
  (let [oldfile (.getAbsoluteFile (io/file oldpath))
        newfile (.getAbsoluteFile (io/file newpath))]
    (when-not (.exists oldfile)
      (throw (java.io.FileNotFoundException. "Not found sourcefile.")))
    (.mkdirs (.getParentFile newfile))
    (io/copy oldfile newfile)
    (.delete oldfile)))
