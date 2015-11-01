if(!exists("connect", mode="function"))
  source("/home/dominik/workspace/rOMERO/R/gateway.R")

connect("root", "omero", "localhost")

datasets <- listDatasets()

print(datasets)

disconnect()
