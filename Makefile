REPOS := $(shell curl 'https://api.github.com/users/conao3/repos?per_page=1000' | jq -r '.[].name')
HEADER := $(REPOS:%=header/png/%.png)

all: $(HEADER)

header/png/%.png: clojure/target/uberjar/files-0.1.0-standalone.jar clojure/resources
	cd clojure; java -jar target/uberjar/files-0.1.0-standalone.jar create-header $*

clojure/target/uberjar/files-0.1.0-standalone.jar: clojure/src
	cd clojure; lein uberjar
