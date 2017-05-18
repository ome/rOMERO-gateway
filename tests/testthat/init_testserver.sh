#!/bin/bash

# Set up the data structure needed for the tests
# (see setup.csv)

cd $OMERO_HOME/bin

./omero login root@localhost -w omero
./omero obj new Dataset name=TestDataset
./omero obj new Project name=TestProject
./omero obj new ProjectDatasetLink parent=Project:1 child=Dataset:1
touch "8bit-unsigned&pixelType=uint8&sizeZ=3&sizeC=5&sizeT=7&sizeX=512&sizeY=512.fake"
./omero import "8bit-unsigned&pixelType=uint8&sizeZ=3&sizeC=5&sizeT=7&sizeX=512&sizeY=512.fake" -T Dataset:id:1

./omero obj new CommentAnnotation textValue=BlaBla
./omero obj new ImageAnnotationLink parent=Image:1 child=CommentAnnotation:1
touch test.csv
./omero upload test.csv
./omero obj new FileAnnotation file=OriginalFile:47
./omero obj new ImageAnnotationLink parent=Image:1 child=FileAnnotation:2

./omero obj new Screen name=TestScreen
touch "SPW&plates=1&plateRows=8&plateCols=8&fields=4&plateAcqs=1.fake"
./omero import "SPW&plates=1&plateRows=8&plateCols=8&fields=4&plateAcqs=1.fake" -T Screen:id:1

./omero obj new MapAnnotation
./omero obj map-set MapAnnotation:3 mapValue testkey testvalue
./omero obj new ScreenAnnotationLink parent=Screen:1 child=MapAnnotation:3

