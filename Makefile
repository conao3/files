all:

# This Makefile require imageMagic and mustache command
#
#   $ brew install imageMagic
#   $ gem install mustache

# xargs parallel option
P ?= 12

REPOS :=

DIRS := blob/headers/png blob/headers/svg

##################################################

.PHONY: all headers headers-client checkout commit merge push clean

all: headers

##############################

$(DIRS):
	mkdir -p $@

headers: $(DIRS)
	$(MAKE) headers-client \
	REPOS="$(shell curl https://api.github.com/users/conao3/repos\?per_page=1000 | jq -r '.[] | .name')"

headers-client: $(REPOS:%=blob/headers/png/%.png)

blob/headers/png/%.png: blob/headers/svg/%.svg
	convert $< $@

blob/headers/svg/%.svg:
	echo '{\"name\" : \"$*\"}' | mustache - mustache/header.svg.mustache > $@

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
