# Demo script
#
# Optionally use http://doitlive.readthedocs.io/en/stable/
# to make the demo more bulletproof.

#doitlive shell: /bin/bash
#doitlive prompt: smiley
#doitlive commentecho: false
#doitlive alias: c="clear"

cd ~/OpenStack/git/cinder

git tag to-backport 46b8da35
git checkout -t origin/stable/pike
################################################################
## Try the naive approach
git cherry-pick to-backport
git cherry-pick --abort

################################################################
## git-deps backporting demo
c
git deps -h
c

git deps -e origin/stable/pike to-backport^!
git deps -l -r -e origin/stable/pike to-backport^!

c
git deps -s -e origin/stable/pike

git cherry-pick d9af50b131fedfdf960eecff9093dfeadd6763af
git cherry-pick f36fc239804fb8fbf57d9df0320e2cb6d315ea10
git cherry-pick to-backport

c
git deps -r -e origin/stable/pike to-backport^! | tee deps.txt
git reset --hard origin/stable/pike
tsort deps.txt | tac | xargs -t git cherry-pick

################################################################
## git-explode
c
git explode -h
c
cd ~/nashville-git/test-repo
gitk --all &
git explode file-b master


################################################################
# git-splice removal of commits from a branch

git show-ref | awk '/\/topic/ {print $2}' | xargs -n1 -r git update-ref -d

# Remove a commit
git splice file-b-three-bar^!

ggrh @{1}  # reset

# Remove a commit range
git splice file-a-three-foo..file-a-eight-foo

ggrh @{1}

# Abort removing a commit range with conflicts
git splice file-b..file-a-eight-foo

git splice --in-progress
git splice --abort
git splice --in-progress

# Resolve conflicts when removing a commit range
git splice file-b..file-a-eight-foo
ggmt
git splice --continue

################################################################
# git-splice insertion of commits into a branch

# so that's for removing, not very exciting because rebase -i
# can already do that.
#
# But it can also splice commits into a branch as well as out of it.
# So let's add a feature branch

ggrh @{1}
bash ../create-repo.sh feature </dev/null

# Splice commit onto branch tip (same as cherry-pick)
git splice master file-c^!

ggrh @{1}

# Splice range onto branch tip (same as cherry-pick)
git splice master file-c^..feature^

ggrh @{1}

# Splice commit *into* branch
git splice master^ file-c^!

ggrh @{1}

# Splice a range *into* branch
git splice master^ file-c^..feature^

################################################################
# git-splice removal and insertion of commits from/into a branch

ggrh @{1}

git splice file-a-three-foo..file-a-eight-foo file-c^..feature^

################################################################
# git-transplant

ggrh @{1}

# transplant commit onto tip
git transplant file-a-eight-foo^! feature

ggrh @{1} && git branch -f feature feature@{1}

# transplant range onto tip
git transplant file-b-three-bar..master feature

ggrh @{1} && git branch -f feature feature@{1}

# transplant range inside branch
git transplant --after feature^ file-b-three-bar..master feature

ggrh @{1} && git branch -f feature feature@{1}

# transplant range onto new branch
git transplant --new-from=feature file-b-three-bar..master feature2

ggrh @{1} && git branch -D feature2

# transplant range inside new branch
git transplant --new-from=feature^^ file-b-three-bar..master feature2

ggrh @{1} && git branch -D feature2
