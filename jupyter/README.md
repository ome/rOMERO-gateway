Jupyter server
==============

Spin up a Jupyter server with Docker:

CD into this directory and run:
```
docker build -t romero .

```
(this will build the romero.gateway from the current ome/master branch)

Note: If you want to build a specific version or branch use:
```
docker build --build-arg ROMERO_VERSION=0.4.5
docker build --build-arg ROMERO_BRANCH_USER=ome --build-arg ROMERO_BRANCH=master
```

Run the docker image:
```
docker run -it -p 8888:8888 romero
```

Go to the respective URL in your browser and create a new "OMERO R" notebook!
