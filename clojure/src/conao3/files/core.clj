(ns conao3.files.core
  (:require [clojure.string :as string]
            [clojure.tools.cli :refer [parse-opts]]
            [conao3.files.mustache :as mustache])
  (:gen-class))

(def cli-options
  ;; An option with a required argument
  [
   ;; ["-v" nil "Verbosity level"
   ;;  :id :verbosity
   ;;  :default 0
   ;;  :update-fn inc] ; Prior to 0.4.1, you would have to use:
   ;; ;; :assoc-fn (fn [m k _] (update-in m [k] inc))
   ;; A boolean option defaulting to nil
   ["-h" "--help" "Show this help"]])

(defn usage [options-summary]
  (string/join
   \newline
   ["docker-emacs helper CLI tool."
    ""
    "Usage: lein run <actions> [options]"
    ""
    "Actions:"
    "  create-header NAME     Create header image"
    ""
    "Options:"
    options-summary
    ""
    "Please refer to the readme for more information."]))

(defn error-msg [errors]
  (str "The following errors occurred while parsing your command:\n\n"
       (string/join \newline errors)))

(defn validate-args
  "Validate command line arguments. Either return a map indicating the program
  should exit (with a error message, and optional ok status), or a map
  indicating the action the program should take and the options provided."
  [args]
  (let [{:keys [options arguments errors summary]} (parse-opts args cli-options)]
    (cond
      (:help options) ; help => exit OK with usage summary
      {:exit-message (usage summary) :ok? true}

      errors ; errors => exit with description of errors
      {:exit-message (error-msg errors)}

      ;; custom validation on arguments
      ;; (and (= 1 (count arguments))
      ;;      (#{"create-header"} (first arguments)))
      ;; {:action (first arguments) :options options}

      (and (= 2 (count arguments))
           (#{"create-header"} (first arguments)))
      {:action (first arguments)
       :options `[~(fnext arguments) ~@options]}

      :else ; failed custom validation => exit with usage summary
      {:exit-message (usage summary)})))

(defn exit [status msg]
  (println msg)
  (System/exit status))

(defn -main [& args]
  (println (str "o  " (.toString (java.util.Date.))))
  (let [{:keys [action options exit-message ok?]} (validate-args args)]
    (if exit-message
      (exit (if ok? 0 1) exit-message)
      (case action
        "create-header" (mustache/create-header options))))
  (println (str "o  " (.toString (java.util.Date.))))
  (shutdown-agents))
