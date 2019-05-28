Jupyter server
==============

Spin up a Jupyter server with Docker:

CD into this directory and run:
```
docker build .

```

Note: If you want to build a specific version or branch:
```
docker build --build-arg ROMERO_VERSION=0.4.5
docker build --build-arg ROMERO_BRANCH_USER=ome ROMERO_BRANCH=master
```
