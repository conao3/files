all:

P ?= 12

##################################################

.PHONY: all debug commit merge push
.PRECIOUS: header/svg/%.svg

all: header debug $(HEADER)

##############################

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

clean-v:
	find header/png header/svg -type f | xargs -n1 echo "remove:"

clean:
	find header/png header/svg -type f | xargs rm -f
