# This script is executed inside the build container to build MapCache
cd /app/build
rm CMakeCache.txt || true 
cmake .. ${BUILD_OPTIONS}
make -j$(nproc) 
cp /app/build/*mapcache* /output/
cp /app/build/cgi/mapcache.fcgi /output/