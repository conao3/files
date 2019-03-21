REPOS := curl 'https://api.github.com/users/conao3/repos?per_page=1000' | jq -r '.[].name'

header: $(REPOS: %=.make-header-%)
.make-header-%:
