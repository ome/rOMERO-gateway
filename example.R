# This example needs a couple of images with ROIs on the OMERO server
# At least one image should be tagged with "treatment1"
# At least one image should be tagged with "treatment2"
# At least one image should be tagged with both
# At least one image should not be tagged with either of them (acting as "control")
#
# The purpose is to check if the size of ROIs is significantly different for the two treatments

library(psych)

source("R/gateway.R")

# Connect to OMERO
connect("user", "test", "localhost", 4064)

# The dataset we're dealing with
datasetId <- 101
# The name of tags
treatment1Tag <- "treatment1"
treatment2Tag <- "treatment2"

dataset <- getDataset(datasetId)

# Briefly check what images the dataset contains
images <- listImages(datasetId)
for(image in images) {
  print(image$getName())
}

# Define the data frame
df <- data.frame(Treatment1 = logical(), Treatment2 = logical(), CellSize = numeric())

# Loop over the images and gather the data
for(image in images) {
  annos <- listImageAnnotations(image)
  rois <- listROIs(image)  
  
  treatment1 <- FALSE
  treatment2 <- FALSE
  
  for(anno in annos) {
    if(.jinstanceof(anno, "omero/gateway/model/TagAnnotationData")) {
      tag <- .jcast(anno, "omero/gateway/model/TagAnnotationData")
      value <- tag$getTagValue()
      if(value == treatment1Tag)
        treatment1 <- TRUE
      if(value == treatment2Tag)
        treatment2 <- TRUE
    }
  }
  
  for (roi in rois) {
    row <- c(treatment1, treatment2, as.numeric(roi$getArea()))
    df[nrow(df) + 1, ] <- row
  }
}

# Plot the data for a brief overview
boxplot(df$CellSize~df$Treatment1+df$Treatment2, ylab = "Cell Size", xlab ="Treatments",
        names = c("Control", "Treatment1", "Treatment2", "Combined"), 
        col = c("red", "green", "green", "green"))

# Nice plot, want to keep it in OMERO, so plot it again and attach it to the dataset
tmpfile <- "/tmp/boxplot.png"
png(tmpfile)
boxplot(df$CellSize~df$Treatment1+df$Treatment2, ylab = "Cell Size", xlab ="Treatments",
        names = c("Control", "Treatment1", "Treatment2", "Combined"), 
        col = c("red", "green", "green", "green"))
dev.off()
addFile(tmpfile, dataset)

# Check means and variances
df.control <- subset(df, df$Treatment1 == FALSE & df$Treatment2 == FALSE)
df.t1only <- subset(df, df$Treatment1 == TRUE & df$Treatment2 == FALSE)
df.t2only <- subset(df, df$Treatment1 == FALSE & df$Treatment2 == TRUE)
df.combined <- subset(df, df$Treatment1 == TRUE & df$Treatment2 == TRUE)

describe(df.control$CellSize); qqnorm(df.control$CellSize); qqline(df.control$CellSize)

describe(df.t1only$CellSize); qqnorm(df.t1only$CellSize); qqline(df.t1only$CellSize)

describe(df.t2only$CellSize); qqnorm(df.t2only$CellSize); qqline(df.t2only$CellSize)

describe(df.combined$CellSize); qqnorm(df.combined$CellSize); qqline(df.combined$CellSize)

var.test(df.control$CellSize, df.t1only$CellSize)
var.test(df.control$CellSize, df.t2only$CellSize)
var.test(df.control$CellSize, df.combined$CellSize)

t.test(df.control$CellSize, df.t1only$CellSize)
t.test(df.control$CellSize, df.t2only$CellSize)
t.test(df.control$CellSize, df.combined$CellSize)

# Build a model
model <- lm(df$CellSize~as.factor(df$Treatment1)*as.factor(df$Treatment2))
summary(model)
par(mfrow=c(2,2)) # Display four plots in one
plot(model)

# Attach the results to the dataset
tmpfile <- "/tmp/linear_model.txt"
sink(tmpfile)
summary(model)
sink()
addFile(tmpfile, dataset)
tmpfile <- "/tmp/linear_model.png"
png(tmpfile)
par(mfrow=c(2,2))
plot(model)
dev.off()
addFile(tmpfile, dataset)

disconnect()
