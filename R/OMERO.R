#' OME remote object class
#' This is basically a wrapper around the Pojo's of the Java Gateway
#' with a reference to the server.
#' 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export OMERO
#' @exportClass OMERO
#' @import rJava
OMERO <- setClass(
  
  "OMERO",
  
  slots = c(
    server = "OMEROServer",
    dataobject = "jobjRef"
  ),
  
  validity=function(object)
  {
    if(is.null(object@server)) {
      return("OMEROserver is missing!")
    }
    if(is.null(object@dataobject)) {
      return("OMERO object is missing!")
    }
    if(!.jinstanceof(object@dataobject, J("omero.gateway.model.DataObject"))) {
      return("OMERO object is not an instance of DataObject!")
    }
    return(TRUE)
  }
)

#' Casts a general OMERO object into its proper
#' type, e. g. Plate (if possible)
#' @param omero The OME object
#' @return The OMERO object casted to the proper type
#' @export cast
#' @exportMethod cast
#' @examples
#' \dontrun{
#' plate <- cast(object)
#' }
setGeneric(
  name = "cast",
  def = function(omero)
  {
    standardGeneric("cast")
  }
)

#' Get the ID of the OME object
#'
#' @param omero The OME object
#' @return The OMERO object ID
#' @export getOMEROID
#' @exportMethod getOMEROID
#' @examples
#' \dontrun{
#' id <- getOMEROID(object)
#' }
setGeneric(
  name = "getOMEROID",
  def = function(omero)
  {
    standardGeneric("getOMEROID")
  }
)

#' Get the type of the OME object
#'
#' @param omero The OME object
#' @return The OMERO type
#' @export getOMEROType
#' @exportMethod getOMEROType
#' @examples
#' \dontrun{
#' type <- getOMEROType(object)
#' }
setGeneric(
  name = "getOMEROType",
  def = function(omero)
  {
    standardGeneric("getOMEROType")
  }
)

#' Deletes an OME object
#'
#' @param omero The OME object
#' @export delete
#' @exportMethod delete
#' @examples
#' \dontrun{
#' delete(object)
#' }
setGeneric(
  name = "delete",
  def = function(omero)
  {
    standardGeneric("delete")
  }
)

#' Attaches a dataframe to an OME object
#'
#' @param omero The OME object
#' @param df The dataframe
#' @param name An optional name
#' @param ns An optional namespace for the file annotation
#' @return The OME object
#' @export attachDataframe
#' @exportMethod attachDataframe
#' @examples
#' \dontrun{
#' attachDataframe(project, df, name="Some data")
#' }
setGeneric(
  name = "attachDataframe",
  def = function(omero, df, name="R Dataframe", ns=NA)
  {
    standardGeneric("attachDataframe")
  }
)

#' Get the dataframes (name/id/annotationID) attached to an OME object
#'
#' @param omero The OME object
#' @return The names/ids of the attached dataframes
#' @export availableDataframes
#' @exportMethod availableDataframes
#' @examples
#' \dontrun{
#' availableDataframes(project)
#' }
setGeneric(
  name = "availableDataframes",
  def = function(omero)
  {
    standardGeneric("availableDataframes")
  }
)

#' Load a dataframe attached to an OME object
#'
#' @param omero The OME object
#' @param id The id of the dataframe
#' @param condition Only load rows which match the given condition (in which
#' case rowFrom, rowTo and columns parameter will be ignored), for example
#' (ColumnXYZ=='abc') (i.e. rows with value abc in the column with name ColumnXYZ)
#' @param rowFrom Load data from row
#' @param rowTo Load data to row
#' @param columns Only specified columns
#' @return The dataframe
#' @export loadDataframe
#' @exportMethod loadDataframe
#' @examples
#' \dontrun{
#' df <- loadDataframe(project, dataframe_id, rowFrom = 10, rowTo = 100)
#' }
setGeneric(
  name = "loadDataframe",
  def = function(omero, id, condition, rowFrom, rowTo, columns)
  {
    standardGeneric("loadDataframe")
  }
)

#' Describe a dataframe attached to an OME object
#'
#' @param omero The OME object
#' @param id The id of the dataframe
#' @return NA
#' @export describeDataframe
#' @exportMethod describeDataframe
#' @examples
#' \dontrun{
#' describeDataframe(project)
#' }
setGeneric(
    name = "describeDataframe",
    def = function(omero, id)
    {
      standardGeneric("describeDataframe")
    }
)

#' Attach a file to an OME object
#' 
#' @param omero The OME object
#' @param file The path to the file to attach
#' @return The file annotation
#' @export attachFile
#' @exportMethod attachFile
#' @examples
#' \dontrun{
#' file_annotation <- attachFile(project, file)
#' }
setGeneric(name="attachFile",
           def=function(omero, file)
           {
             standardGeneric("attachFile")
           }
)

#' Delete a file attached to an OME object
#'
#' @param omero The OME object
#' @param id The file annotation(!) id
#' @export deleteFile
#' @exportMethod deleteFile
#' @examples
#' \dontrun{
#' deleteFile(project, file_annotation_id)
#' }
setGeneric(
  name = "deleteFile",
  def = function(omero, id)
  {
    standardGeneric("deleteFile")
  }
)

#' Get all images of a container (Dataset, Project, Screen, Plate or Well)
#'
#' @param omero The OME container object
#' @param fieldIndex The field index (only for wells)
#' @return The images @seealso \linkS4class{Image}
#' @export getImages
#' @exportMethod getImages
#' @examples
#' \dontrun{
#' images <- getImages(project)
#' images <- getImages(dataset)
#' images <- getImages(screen)
#' }
setGeneric(
  name = "getImages",
  def = function(omero, fieldIndex)
  {
    standardGeneric("getImages")
  }
)

#' Casts a general OMERO object into its proper
#' type, e. g. Plate (if possible)
#' @param omero The OME object
#' @return The OMERO object casted to the proper type
#' @export cast
#' @exportMethod cast
setMethod(
  f = "cast",
  signature = "OMERO",
  definition = function(omero)
  {
    if(omero@dataobject$getClass()$getSimpleName() == 'ScreenData') {
      x <- Screen(server=omero@server, dataobject=omero@dataobject)
      return(x)
    }
    else if(omero@dataobject$getClass()$getSimpleName() == 'PlateData') {
      x <- Plate(server=omero@server, dataobject=omero@dataobject)
      return(x)
    }
    else if(omero@dataobject$getClass()$getSimpleName() == 'WellData') {
      x <- Well(server=omero@server, dataobject=omero@dataobject)
      return(x)
    }
    else if(omero@dataobject$getClass()$getSimpleName() == 'DatasetData') {
      x <- Dataset(server=omero@server, dataobject=omero@dataobject)
      return(x)
    }
    else if(omero@dataobject$getClass()$getSimpleName() == 'ProjectData') {
      x <- Project(server=omero@server, dataobject=omero@dataobject)
      return(x)
    }
    else if(omero@dataobject$getClass()$getSimpleName() == 'ImageData') {
      x <- Image(server=omero@server, dataobject=omero@dataobject)
      return(x)
    }
    return(omero)
  }
)

#' Get the ID of the OME object
#'
#' @param omero The OME object
#' @return The OMERO object ID
#' @export getOMEROID
#' @exportMethod getOMEROID
setMethod(
  f = "getOMEROID",
  signature = "OMERO",
  definition = function(omero)
  {
    return(as.integer(omero@dataobject$getId()))
  }
)

#' Get the type of the OME object
#'
#' @param omero The OME object
#' @return The OMERO type
#' @export getOMEROType
#' @exportMethod getOMEROType
setMethod(
  f = "getOMEROType",
  signature = "OMERO",
  definition = function(omero)
  {
    obj <- omero@dataobject
    return(obj$getClass()$getSimpleName())
  }
)

#' Deletes an OME object
#'
#' @param omero The OME object
#' @export delete
#' @exportMethod delete
setMethod(
  f = "delete",
  signature = "OMERO",
  definition = function(omero)
  {
    server <- omero@server
    obj <- omero@dataobject
    
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    fac <- gateway$getFacility(J("omero.gateway.facility.DataManagerFacility")$class)
    cb <- fac$delete(ctx, obj$asIObject())
    # Wait max 30 sec
    cb$loop(as.integer(100), .jlong(300))
    res <- cb$getResponse()
  }
)

#' Attaches a dataframe to an OME object
#'
#' @param omero The OME object
#' @param df The dataframe
#' @param name An optional name
#' @param ns An optional namespace for the file annotation
#' @return The OME object
#' @export attachDataframe
#' @exportMethod attachDataframe
setMethod(
  f = "attachDataframe",
  signature = "OMERO",
  definition = function(omero, df, name, ns=NA)
  {
   if(!is.data.frame(df)) {
     return(FALSE)
   } 
    headers <- names(df)
    types <- sapply(df, typeof) 
    classes <- sapply(df, class)
    
    TableDataColumn <- J("omero.gateway.model.TableDataColumn")
    
    jlistheaders <- new (J("java.util.ArrayList"))
    for(i in 1:length(types)) {
      if(types[i]=="double")
        jlistheaders$add(new (TableDataColumn, headers[i], i, J("java.lang.Double")$class)) 
      else if(types[i]=="integer")
        if(classes[i]=="factor")
          jlistheaders$add(new (TableDataColumn, headers[i], i, J("java.lang.String")$class)) 
        else
          jlistheaders$add(new (TableDataColumn, headers[i], i, J("java.lang.Long")$class)) 
      else if(types[i]=="logical")
        jlistheaders$add(new (TableDataColumn, headers[i], i, J("java.lang.Boolean")$class))
      else
        jlistheaders$add(new (TableDataColumn, headers[i], i, J("java.lang.String")$class))
    }
    
    nCols <- length(headers)
    nRows <- nrow(df)
    
    # TODO: Bad performace using Java ArrayLists, replace with arrays 
    jlistdata <- new (J("java.util.ArrayList"))
    for(i in 1:nCols) {
      jlistcoldata <- new (J("java.util.ArrayList"))
      for(j in 1:nrow(df)) {
        if(types[i]=="double")
          value <- new (J("java.lang.Double"), as.double(df[j,i]))
        else if(types[i]=="integer")
          if(classes[i]=="factor")
            value <- new(J("java.lang.String"), as.character(df[j,i]))
          else
            value <- new(J("java.lang.Long"), as.character(df[j,i]))
        else if(types[i]=="logical")
          value <- new (J("java.lang.Boolean"), as.logical(df[j,i]))
        else
          value <- new (J("java.lang.String"), as.character(df[j,i]))
        jlistcoldata$add(value)
      }
      jlistdata$add(jlistcoldata)
    }
    
    table <- new (J("omero.gateway.model.TableData"), .jcast(jlistheaders, new.class = "java/util/List"),
                  .jcast(jlistdata, new.class = "java/util/List"))
    
    server <- omero@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    fac <- gateway$getFacility(J("omero.gateway.facility.TablesFacility")$class)
    
    if (!is.na(ns))
      tabledata <- fac$addTable(ctx, omero@dataobject, name, as.character(ns), table)
    else
      tabledata <- fac$addTable(ctx, omero@dataobject, name, table)
    
    return(omero)
  }
)

#' Get the dataframes (name/id/annotationID) attached to an OME object
#'
#' @param omero The OME object
#' @return The names/ids of the attached dataframes
#' @export availableDataframes
#' @exportMethod availableDataframes
setMethod(
  f = "availableDataframes",
  signature = "OMERO",
  definition = function(omero)
  {
    server <- omero@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    fac <- gateway$getFacility(J("omero.gateway.facility.TablesFacility")$class)
    
    files <- fac$getAvailableTables(ctx, omero@dataobject)
    
    Name <- c()
    ID <- c()
    AnnotationID <- c()
    filelist <- as.list(files)
    for (file in filelist) {
      Name <- c(Name, file$getFileName())
      ID <- c(ID, file$getFileID())
      AnnotationID <- c(AnnotationID, file$getId())
    }
    
    result <- data.frame(Name, ID, AnnotationID, stringsAsFactors = FALSE)
    return(result)
  }
)

#' Load a dataframe attached to an OME object
#'
#' @param omero The OME object
#' @param id The id of the dataframe
#' @param condition Only load rows which match the given condition (in which
#' case rowFrom, rowTo and columns parameter will be ignored), for example
#' (ColumnXYZ=='abc') (i.e. rows with value abc in the column with name ColumnXYZ)
#' @param rowFrom Load data from row
#' @param rowTo Load data to row
#' @param columns Only specified columns
#' @return The dataframe
#' @export loadDataframe
#' @exportMethod loadDataframe
setMethod(
  f = "loadDataframe",
  signature = "OMERO",
  definition = function(omero, id, condition, rowFrom, rowTo, columns)
  {
    server <- omero@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    fac <- gateway$getFacility(J("omero.gateway.facility.TablesFacility")$class)

    if (!missing(condition)) {
        rows <- fac$query(ctx, .jlong(id), condition)
        jlist <- new (J("java.util.ArrayList"))
        for (row in rows) {
          jlist$add(new (J("java.lang.Long"), .jlong(row)))
        }
        tabledata <- fac$getTable(ctx, .jlong(id), jlist)
    }
    else {
      if(missing(rowFrom)) {
        rowFrom <- 1
      }
      
      if(missing(rowTo)) {
        info <- fac$getTableInfo(ctx, .jlong(id))
        rowTo <- info$getNumberOfRows()
      }
      
      if (missing(columns)) {
        tabledata <- fac$getTable(ctx, .jlong(id), .jlong(rowFrom-1), .jlong(rowTo-1), .jnull())
      }
      else 
      {
        columns <- as.integer(columns)
        columns <- sapply(columns, function(x) {x-1})
        columns <- as.integer(columns)
        tabledata <- fac$getTable(ctx, .jlong(id), .jlong(rowFrom-1), .jlong(rowTo-1), .jarray(columns))
      }
    }
    
    nCols <- tabledata$getColumns()$length
    if(nCols==0)
      return (data.frame())
    
    columns <- .jevalArray(tabledata$getColumns())
    dataarray <- .jevalArray(tabledata$getData())

    nRows <- length(.jevalArray(dataarray[[1]]))
    
    # construct an initial dataframe with nRows number of rows
    result <- data.frame(c(1:nRows))
    
    for(i in 1:nCols) {
      columnName <- columns[[i]]$getName()
      rowArray <- .jevalArray(dataarray[[i]], rawJNIRefSignature = "[Ljava/lang/Object")
      rowData <- c()
      for(j in 1:nRows) {
        jvalue <- rowArray[[j]]
        value <- jvalue$toString()
        if(.jinstanceof(jvalue, "java.lang.Double"))
          value <- as.numeric(jvalue$doubleValue())
        if(.jinstanceof(jvalue, "java.lang.Long"))
          value <- as.integer(jvalue$longValue())
        if(.jinstanceof(jvalue, "java.lang.Boolean"))
          value <- as.logical(jvalue$booleanValue())
        rowData <- c(rowData, value)
      }
      result[[columnName]] <- rowData
    }
    
    result[[1]] <- NULL
    
    return(result)
  }
)

#' Describe a dataframe attached to an OME object
#'
#' @param omero The OME object
#' @param id The id of the dataframe
#' @return NA
#' @export describeDataframe
#' @exportMethod describeDataframe
setMethod(
  f = "describeDataframe",
  signature = "OMERO",
  definition = function(omero, id)
  {
    server <- omero@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    fac <- gateway$getFacility(J("omero.gateway.facility.TablesFacility")$class)
    
    info <- fac$getTableInfo(ctx, .jlong(id))
    
    nRows <- info$getNumberOfRows()
    nCols <- info$getColumns()$length
    columns <- .jevalArray(info$getColumns())
    
    cat("Rows: ", nRows, "\n")
    cat("Columns: ", nCols, "\n")
    df <- data.frame(Name = character(), Description = character(), Type = character())
    for(i in 1:nCols) {
      columnName <- columns[[i]]$getName()
      columnDescription <- columns[[i]]$getDescription()
      type <- columns[[i]]$getType()$getName()
      if(type == "java.lang.Double")
        type = "numeric"
      if(type == "java.lang.Integer")
        type = "integer"
      if(type == "java.lang.Long")
        type ="integer"
      if(type == "java.lang.Boolean")
        type = "logical"
      if(type == "java.lang.String")
        type = "character"
      df <- rbind(df, data.frame(Name = columnName, Description = columnDescription, Type = type))
    }
    print(df)
  }
)

#' Attach a file to an OME object
#' 
#' @param omero The OME object
#' @param file The path to the file to attach
#' @return The file annotation
#' @export attachFile
#' @exportMethod attachFile
setMethod(f="attachFile",
          signature="OMERO",
          definition=function(omero, file)
          {
            server <- omero@server
            gateway <- getGateway(server)
            ctx <- getContext(server)
            
            dm <- gateway$getFacility(J("omero.gateway.facility.DataManagerFacility")$class)
            
            jf <- new(J("java.io.File"), as.character(file))
            
            future <- dm$attachFile(ctx, jf, .jnull(), .jnull(), .jnull(), omero@dataobject)
            anno <- future$get()
            
            return(OMERO(server=server, dataobject=anno))
          }
)

#' Get annotations attached to an OME object.
#' Type, Namespace, Name, Content, ID, FileID (in case of file annotations)
#' 
#' @param object The OME object
#' @param typeFilter Optional annotation type filter, e.g. FileAnnotation
#' @param nameFilter Optional name filter, e.g. file name of a FileAnnotation
#' @return The annotations
#' @export getAnnotations
#' @exportMethod getAnnotations
setMethod(f="getAnnotations",
          signature=(object="OMERO"),
          definition=function(object, typeFilter, nameFilter)
          {
            server <- object@server
            obj <- object@dataobject
            gateway <- getGateway(server)
            ctx <- getContext(server)
            fac <- gateway$getFacility(J("omero.gateway.facility.MetadataFacility")$class)
            
            jannos <- NULL
            
            if(missing(typeFilter)) {
              jannos <- fac$getAnnotations(ctx, obj)
            }
            else {
              className <- paste("omero.gateway.model", typeFilter, sep=".")
              clazz <- J("java.lang.Class")$forName(className)
              jlist <- new (J("java.util.ArrayList"))
              jlist$add(clazz)
              jannos <- fac$getAnnotations(ctx, obj, jlist, .jnull())
            }
            
            result <- data.frame(Type = character(), Namespace = character(), Name = character(), Content = character(), ID = numeric(), FileID = numeric())
            
            jannoslist <- as.list(jannos)
            for (anno in jannoslist) {
              javclass <- anno$getClass()
              annotype <- javclass$getName()
              annotype <- gsub("omero\\.gateway\\.model\\.", "", annotype)
              
              clazz = javclass$getCanonicalName()
              clazz <- gsub('\\.', '/', clazz)
              
              cast <- .jcast(anno, new.class = clazz)
                             
              annoname <- ''
              fid <- NA
              content <- NA
              if(annotype == 'FileAnnotationData') {
                annoname <- cast$getFileName()
                fid <-  cast$getFileID()
                content <- cast$getOriginalMimetype()
              }
              else if(annotype == 'TagAnnotationData') {
                annoname <- cast$getTagValue()
                content <- cast$getTagDescription()
              }
              else if(annotype == 'TextualAnnotationData') {
                content <- cast$getText()
              }
              
              omeid <- anno$getId()
              ns <- anno$getNameSpace()
              if(is.jnull(ns))
                ns <- NA
              
              if(missing(nameFilter) || annoname == nameFilter)
                result <- rbind(result, data.frame(Type = annotype, Namespace = ns, Name = annoname, Content = content, ID = as.numeric(omeid), FileID = as.numeric(fid)))
            }
            
            return(result)
          }
)

#' Delete a file attachend to an OME object
#'
#' @param omero The OME object
#' @param id The file annotation(!) id
#' @export deleteFile
#' @exportMethod deleteFile
setMethod(
  f = "deleteFile",
  signature = "OMERO",
  definition = function(omero, id)
  {
    server <- omero@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    browse <- gateway$getFacility(J("omero.gateway.facility.BrowseFacility")$class)
    annotation <- browse$findObject(ctx, 'FileAnnotationData', .jlong(id))
    delete(OMERO(server=server, dataobject=annotation))
  }
)




