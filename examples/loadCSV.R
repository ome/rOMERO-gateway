####
# Connect to an OMERO server and import a CSV file
####

# Connect to the server
server <- OMEROServer(host="localhost", username = "root", password = "omero")
server <- connect(server)

# Load the CSV with the original file ID 1
data <- loadCSV(server, 1)

disconnect(server)
