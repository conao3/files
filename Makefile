REPOS := curl 'https://api.github.com/users/conao3/repos?per_page=1000' | jq -r '.[].name'

header: $(REPOS:%=.make-header-%)
.make-header-%: clojure/resources/header.svg.mustache
	java -jar clojure/target/uberjar/files-0.1.0-standalone.jar create-header $*

