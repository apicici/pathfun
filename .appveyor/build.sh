pip install hererocks

export PATH="$PATH:$HOME/.local/bin"

hererocks env --lua 5.1 -rlatest
source env/bin/activate
luarocks install moonscript

mkdir -p pathfun
cd src && moonc -t ../pathfun .
cd ..
zip -r build.zip pathfun
zip -r build.zip docs
zip -j build.zip *.md
zip -j build.zip example.gif
zip -j build.zip .appveyor/*.md
