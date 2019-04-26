all:

# This Makefile require imageMagic and mustache command
#
#   $ brew install imageMagic
#   $ gem install mustache

# xargs parallel option
P ?= 12

DIRS := headers/png headers/svg

##################################################

.PHONY: all headers checkout commit merge push clean

all: $(DIRS) headers

##############################

$(DIRS):
	mkdir -p $@

headers:
	curl https://api.github.com/users/conao3/repos?per_page=1000 | \
	  jq -r '.[] | .name' | \
	  xargs -n1 -t -P$(P) -I% bash -c \
	    "echo '{\"name\" : \"%\"}' | \
	      mustache - mustache/headers.svg.mustache > blob/headers/svg/%.svg && \
	      convert blob/headers/svg/%%.svg blob/headers/png/%.png && \
	      echo %"

##############################

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

clean:
	rm -rf $(DIRS)
