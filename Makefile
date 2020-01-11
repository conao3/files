all:

REPOS :=

DIRS := .make blob/headers/png blob/headers/svg

# from conao3/imagick:7.0.8
IMAGICK  := conao3/imagick-roboto:1.0.0
MUSTACHE := conao3/mustache:1.1.0

##################################################

.PHONY: all headers headers-client checkout commit merge push clean
.PRECIOUS: blob/headers/svg/%.svg

all: headers

##############################

headers: .make/github-cache-1 .make/github-cache-2 .make/github-cache-3
	$(MAKE) headers-client REPOS="$(shell cat $^ | jq -r '.[] | .name')"

headers-client: $(REPOS:%=blob/headers/png/%.png)

blob/headers/png/%.png: blob/headers/svg/%.svg blob/headers/png
	docker run -v $$(pwd)/blob:/blob --rm $(IMAGICK) convert /$< /$@

blob/headers/svg/%.svg: mustache/header.svg.mustache blob/headers/svg
	echo '{"name" : "$*"}' | docker run --rm -i -v $$(pwd)/mustache:/mustache $(MUSTACHE) - $< > $@

##############################

checkout:
	git checkout $(TRAVIS_BRANCH)
	git checkout -b travis-$$TRAVIS_JOB_NUMBER

commit:
	git add .
	echo -n "job $$TRAVIS_JOB_NUMBER at " >> commit.log
	echo -n "$$(TZ=Asia/Tokyo date '+%Y/%m/%d %H:%M:%S (%Z)') " >> commit.log
	echo "make:$$(git diff --cached --stat | tail -n1)" >> commit.log
	git add commit.log
	git commit --allow-empty -m "generate (job $$TRAVIS_JOB_NUMBER) [skip ci]"

merge:
	git checkout master
	git merge --no-ff travis-$$TRAVIS_JOB_NUMBER -m "merge travis-$$TRAVIS_JOB_NUMBER [skip ci]"

push:
	git push origin master

##############################

$(DIRS):
	mkdir -p $@

.make/github-cache-%: .make
	curl https://api.github.com/users/conao3/repos\?per_page=100\&page=$* > $@

##############################


clean:
	rm -rf $(DIRS)
