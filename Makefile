DATEDETAIL := $(shell date '+%Y/%m/%d %H:%M:%S')

REPOS      := $(shell curl https://api.github.com/users/conao3/repos?per_page=1000 | jq -r '.[].name')
HEADER     := $(REPOS:%=header/png/%.png)

HEADERFLUG := $(if $$CHROME_PATH,--chrome $$CHROME_PATH,)

##################################################

.PHONY: all debug commit merge push

all: debug $(HEADER)

debug:
	@echo 'REPOS=' $(REPOS)
	@echo 'HEADERFLUG=' $(HEADERFLUG)

header/png/%.png: clojure/target/uberjar/files-0.1.0-standalone.jar clojure/resources
	cd clojure; java -jar target/uberjar/files-0.1.0-standalone.jar create-header $* $(HEADERFLUG)

clojure/target/uberjar/files-0.1.0-standalone.jar: clojure/src/conao3/files
	cd clojure; lein uberjar

########################################

checkout:
	git checkout master
	git checkout -b travis-$$TRAVIS_JOB_NUMBER
	echo "job $$TRAVIS_JOB_NUMBER at $(DATEDETAIL)" >> commit.log

commit:
	git diff --cached --stat | tail -n1 >> commit.log
	git add .
	git commit --allow-empty -m "generate (job $$TRAVIS_JOB_NUMBER) [skip ci]"

merge:
	git checkout master
	git merge --no-ff travis-$$TRAVIS_JOB_NUMBER -m "merge travis-$$TRAVIS_JOB_NUMBER [skip ci]"

push:
	git push origin master
