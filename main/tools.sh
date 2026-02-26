echo "the beginning of the tool assembly..."
echo "NextRAMAICF..."
clang++ -std=c++17 -O3 -DNDEBUG -o ./tools/nextramaicf ./source/nextramaicf.cpp
echo "...done"
echo "...global done"
