all:

# This Makefile require imageMagic and mustache command
#
#   $ brew install imageMagic
#   $ gem install mustache

# xargs parallel option
P ?= 12

DIRS := header/png header/svg

##################################################

.PHONY: all header checkout commit merge push clean

all: $(DIRS) header

##############################

$(DIRS):
	mkdir -p $@

header:
	curl https://api.github.com/users/conao3/repos?per_page=1000 | \
	  jq -r '.[] | .name' | \
	  xargs -n1 -t -P$(P) -I% bash -c \
	    "echo '{\"name\" : \"%\"}' | \
	      mustache - mustache/header.svg.mustache > blob/header/svg/%.svg && \
	      convert blob/header/svg/%%.svg blob/header/png/%.png && \
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
