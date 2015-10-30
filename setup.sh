# We need to pull in the long tree of plugins recursively
# Since the pelican-plugins git project also links to some 
# plugins as submodules. 

git submodule update --init --recursive

# The project tends to point to certain commits, but
# We probably don't want that, so let's update everything to master
git submodule foreach --recursive 'git checkout master; git pull'

