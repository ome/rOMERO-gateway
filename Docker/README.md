# Docker

#### Build a docker image
CD into this directory and run ```docker build -t romero .```

#### Run the image
You can run the image anytime with:
```docker run --rm -ti romero```
This will immediately give you an R prompt.

#### Load the Gateway methods
Now source the ```gateway.R``` script:
``` source("R/gateway.R") ```

#### Connect to an OMERO server
```connect("user", "test", "localhost")```


