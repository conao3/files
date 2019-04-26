REPOS      := $(shell curl https://api.github.com/users/conao3/repos?per_page=1000 | jq -r '.[].name')
HEADER     := $(REPOS:%=header/png/%.png)

CHROME_PATH ?=
HEADERFLUG := $(if $(CHROME_PATH),--chrome $(CHROME_PATH),)

P ?= 12

##################################################

.PHONY: all debug commit merge push
.PRECIOUS: header/svg/%.svg

all: header debug $(HEADER)

##############################

header:
	curl https://api.github.com/users/conao3/repos?per_page=1000 | \
	  jq -r '.[] | .name' | \
	  xargs -n1 -P$(P) -t -I%% bash -c \
	    "echo '{\"name\" : \"%%\"}' | mustache - mustache/header.svg.mustache > blob/header/svg/%%.svg"

debug:
	@echo 'REPOS=' $(REPOS)
	@echo 'HEADERFLUG=' $(HEADERFLUG)

header/svg/%.svg: clojure/target/uberjar/files-0.1.0-standalone.jar clojure/resources
	cd clojure; java -jar target/uberjar/files-0.1.0-standalone.jar create-header-svg $* $(HEADERFLUG)

header/png/%.png: header/svg/%.svg
	convert $< $@

clojure/target/uberjar/files-0.1.0-standalone.jar: clojure/src/conao3/files
	cd clojure; lein uberjar

########################################

checkout:
	git checkout master
	git checkout -b travis-$$TRAVIS_JOB_NUMBER
	echo "job $$TRAVIS_JOB_NUMBER at $(shell date '+%Y/%m/%d %H:%M:%S')" >> commit.log

commit:
	git diff --cached --stat | tail -n1 >> commit.log
	git add .
	git commit --allow-empty -m "generate (job $$TRAVIS_JOB_NUMBER) [skip ci]"

merge:
	git checkout master
	git merge --no-ff travis-$$TRAVIS_JOB_NUMBER -m "merge travis-$$TRAVIS_JOB_NUMBER [skip ci]"

push:
	git push origin master

clean-v:
	find header/png header/svg -type f | xargs -n1 echo "remove:"

clean:
	find header/png header/svg -type f | xargs rm -f
