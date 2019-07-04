library(romero.gateway)

# Very simple example showing how to connect to an OMERO server.
# Also useful as template to start your own scripts.

server <- OMEROServer(host = "localhost", username = "xx", password = "xx", port = as.integer(4064))
server <- connect(server)

# By default you are working in the context of your default group.
# If the data you want to access is in another group, you have to 
# switch the group context:
server <- setGroupContext(server, 'other group')

# Disconnect again from the server
disconnect(server)
