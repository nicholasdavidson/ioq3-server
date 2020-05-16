# ioq3-server
A docker container for ioq3 based on a debian 10 distroless image

# Build instructions
Copy the *.pk3 files from your official q3 install into the pk3 directory.
```docker build . -t ioq3:latest```

# Running instructions
```docker run --rm -ioq3:latest```

Remember not to push the image containing ID's copyrighted pk3 files to a public Docker registry!

# Configuring
Edit the config files in cfg/ - I suggest you create a local branch you never push if you're going to do this.

# Running in azure
Don't leave the server up, it (at time of writing) costs about £1 a day to run this server. At that cost long-term it'd be 
cheaper to use a dedicated server, this container is designed to be spun up and shut down when you just want a quick  game of
q3 dm.
1. Install the tool jq the az commandline tools.
2. Sign up for the free tier of Azure
3. Sign up for a free Dockerhub account.
4. Create a private repo called ioq3-server
5. Generate a new access token - you'll use this as the value for dh_password
6. `$ cp parameters.json.example parameters.json`
7. Fill in all the values in `parameters.json`:

| Parameter | Description|
|-----------|------------|
|dh_user|the username you registered with for docker-hub|
|dh_password|The value of the access token you created|
|docker_image_path|Usually `<du_user>/ioq3-server:latest`|
|az_container_name|The name of the container to create in azure.|
|az_region|The location in Azure to create the server in, choose one close to the players from the list output of  `az account list-locations`|

8. Then run `make az-deploy` and wait.
9. To tidy up the server run: `make az-destroy`