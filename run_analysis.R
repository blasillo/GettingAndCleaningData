library(reshape2)
library(plyr)


### downloading data files

destination <- ".\\data\\UCI HAR Dataset"

if (!file.exists(".\\data")) {
  dir.create(".\\data")
}

if (!file.exists(destination)) {  
  url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  filename <- "dataset.zip"
  download.file(url, destfile=paste(".\\data",filename, sep="\\"), method="curl")
  unzip(paste(".\\data",filename, sep="\\"), exdir=".\\data")
}


## merging training and test -->  data set.


# loading training / test measurements

train <- cbind(subject=read.table(paste(destination, "train", "subject_train.txt", sep="\\"), col.names="SubjectID"),
                     y=read.table(paste(destination, "train", "y_train.txt", sep="\\"), col.names="ActivityID"),
                     x=read.table(paste(destination, "train", "X_train.txt", sep="\\")))

test <- cbind(subject=read.table(paste(destination, "test", "subject_test.txt", sep="\\"), col.names="SubjectID"),
                    y=read.table(paste(destination, "test", "y_test.txt", sep="\\"), col.names="ActivityID"),
                    x=read.table(paste(destination, "test", "x_test.txt", sep="\\")))



# loading features
features <- read.table(paste(destination,"features.txt",sep="\\"), 
                       col.names=c('id', 'name'),
                       header=FALSE, 
                       stringsAsFactors = FALSE)


# loading activity features
activity <- read.table(paste(destination, "activity_labels.txt", sep="/"), 
                       col.names=c('ActivityID', 'Activity'))


# merge & columns filtering

data <- rbind(train,test)[, c(1,2,2 + features[grep("mean|std", features$name),][,1])]


# applying column names
names(data) <- c("Subject", "ActivityID", features$name[grep("mean|std", features$name)])       


# applying activity names
data <- merge(data, activity, by.x="ActivityID", by.y="ActivityID")
data <- data[,!(names(data) %in% c("ActivityID"))]


# data set with the average of each variable for each activity and each subject
data.mean <-  ddply(melt(data, id.vars=c("Subject", "Activity")),
                    .(Subject, Activity), 
                    summarise, 
                    Mean=mean(value))


# saving data sets

##write.csv(data.mean, file = paste(destination,"UCI_HAR.mean.txt",sep="\\"),row.names = FALSE)
##write.csv(data, file = paste(destination,"UCI_HAR.data.txt",sep="\\")     ,row.names = FALSE)
 
write.table(data.mean, 
            file.path(destination, "UCI_HAR.mean.txt"), 
            quote = FALSE, 
            sep = "\t", 
            row.names = FALSE)

write.table(data, 
            file.path(destination, "UCI_HAR.data.txt"), 
            quote = FALSE, 
            sep = "\t", 
            row.names = FALSE) 










