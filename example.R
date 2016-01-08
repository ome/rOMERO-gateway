source("init.R")

server <- OMEROServer(username = "user", password = "test")
server <- connect(server)
object <- loadObject(server, "DatasetData", 101)
object
test <- disconnect(server)
