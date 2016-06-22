#' OME remote object class
#' This is basically a wrapper around the Pojo's of the Java Gateway
#' with a reference to the server.
#' 
#' @slot server Reference to the server
#' @slot server The Java data object
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
    if(!.jinstanceof(object@dataobject, DataObject)) {
      return("OMERO object is not an instance of DataObject!")
    }
    return(TRUE)
  }
)

setGeneric(
  name = "attachDataframe",
  def = function(omero, df, name="R Dataframe")
  {
    standardGeneric("attachDataframe")
  }
)

setGeneric(
  name = "availableDataframes",
  def = function(omero)
  {
    standardGeneric("availableDataframes")
  }
)

setGeneric(
  name = "loadDataframe",
  def = function(omero, id, rowFrom=1, rowTo, columns)
  {
    standardGeneric("loadDataframe")
  }
)

#' Attaches a dataframe to an OME object
#'
#' @param omero The OME object
#' @param df The dataframe
#' @param name An optional name
#' @return The OME object
#' @examples
#' attachDataframe(omero, df)
setMethod(
  f = "attachDataframe",
  signature = "OMERO",
  definition = function(omero, df, name)
  {
   if(!is.data.frame(df)) {
     return(FALSE)
   } 
    headers <- names(df)
    types <- sapply(df, typeof) 
    classes <- sapply(df, class)
    
    jlistheaders <- new (ArrayList)
    for(i in 1:length(types)) {
      if(types[i]=="double")
        jlistheaders$add(new (TableDataColumn, headers[i], i, Double$class)) 
      else if(types[i]=="integer")
        if(classes[i]=="factor")
          jlistheaders$add(new (TableDataColumn, headers[i], i, String$class)) 
        else
          jlistheaders$add(new (TableDataColumn, headers[i], i, Long$class)) 
      else if(types[i]=="logical")
        jlistheaders$add(new (TableDataColumn, headers[i], i, Boolean$class))
      else
        jlistheaders$add(new (TableDataColumn, headers[i], i, String$class))
    }
    
    nCols <- length(headers)
    nRows <- nrow(df)
    
    # TODO: Bad performace using Java ArrayLists, replace with arrays 
    jlistdata <- new (ArrayList)
    for(i in 1:nCols) {
      jlistcoldata <- new (ArrayList)
      for(j in 1:nrow(df)) {
        if(types[i]=="double")
          value <- new (Double, as.double(df[j,i]))
        else if(types[i]=="integer")
          if(classes[i]=="factor")
            value <- new(String, as.character(df[j,i]))
          else
            value <- new(Long, as.character(df[j,i]))
        else if(types[i]=="logical")
          value <- new (Boolean, as.logical(df[j,i]))
        else
          value <- new (String, as.character(df[j,i]))
        jlistcoldata$add(value)
      }
      jlistdata$add(jlistcoldata)
    }
    
    table <- new (TableData, .jcast(jlistheaders, new.class = "java/util/List"),
                  .jcast(jlistdata, new.class = "java/util/List"))
    
    server <- omero@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    fac <- gateway$getFacility(TablesFacility$class)
    
    tabledata <- fac$addTable(ctx, omero@dataobject, name, table)
    
    return(omero)
  }
)

#' Get the dataframes (name/id) attached to an OME object
#'
#' @param omero The OME object
#' @return The names/ids of the attached dataframes
#' @examples
#' availableDataframes(omero)
setMethod(
  f = "availableDataframes",
  signature = "OMERO",
  definition = function(omero)
  {
    server <- omero@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    fac <- gateway$getFacility(TablesFacility$class)
    
    files <- fac$getAvailableTables(ctx, omero@dataobject)
    
    Name <- c()
    ID <- c()
    it <- files$iterator()
    while(it$hasNext()) {
      file <- .jrcall(it, method = "next")
      Name <- c(Name, file$getFileName())
      ID <- c(ID, file$getFileID())
    }
    
    result <- data.frame(Name, ID, stringsAsFactors = FALSE)
    return(result)
  }
)

#' Load a dataframe attached to an OME object
#'
#' @param omero The OME object
#' @param id The id of the dataframe
#' @return The dataframe
#' @examples
#' loadDataframe(omero, 1)
setMethod(
  f = "loadDataframe",
  signature = "OMERO",
  definition = function(omero, id, rowFrom, rowTo, columns)
  {
    server <- omero@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    fac <- gateway$getFacility(TablesFacility$class)
    
    if(missing(rowTo)) {
      info <- fac$getTableInfo(ctx, .jlong(id))
      rowTo <- info$getNumberOfRows() 
    }
    
    if(missing(columns)) {
      tabledata <- fac$getTable(ctx, .jlong(id), .jlong(rowFrom-1), .jlong(rowTo-1), .jnull())
    }
    else 
    {
      columns <- as.integer(columns)
      columns <- sapply(columns, function(x) {x-1})
      columns <- as.integer(columns)
      tabledata <- fac$getTable(ctx, .jlong(id), .jlong(rowFrom-1), .jlong(rowTo-1), .jarray(columns))
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
