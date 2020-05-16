# ioq3-server
A docker container for ioq3 based on a debian 10 distroless image

# Build instructions
Copy the *.pk3 files from your official q3 install into the pk3 directory.
Run docker build . -t ioq3:latest

# Running instructions
docker run --rm -ioq3:latest

# Configuring
Edit the config files in cfg/