# !/bin/bash
# Script to build the build environment and run the build for different architectures
export ARCH=amd64
PS3="Enter a number: "
select opt in "amd64" "arm64v8"; do
    case $opt in
        "amd64")
            export ARCH=amd64
            export TAG="-$ARCH"
            export PLATFORM=""
            break
            ;;
        "arm64v8")
            export ARCH=arm64v8
            export TAG="-$ARCH"
            export PLATFORM="--platform linux/arm64"
            break
            ;;
        *)
            echo "Invalid option $REPLY"
            ;;
    esac
done  

mkdir $(pwd)/bin/${ARCH} || true

docker build $PLATFORM -t builder$TAG --build-arg ARCH=${ARCH} -f Dockerfile.arch.build .

docker run $PLATFORM -it --rm \
  -v $(pwd):/app \
  -v $(pwd)/bin/${ARCH}:/output \
  builder$TAG bash -c /app/build.sh
