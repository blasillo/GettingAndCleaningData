---
title: "Getting and Cleaning Data"
author: "Blas Torregrosa"
date: "July 2014"
---

# CookBook "Getting and Cleaning Data Course Project"


The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis.  

One of the most exciting areas in all of data science right now is wearable computing. Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
 
 http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
 
 Here are the data for the project: 
 
 https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
 
 You should create one R script called run_analysis.R that does the following. 
 
 1. Merges the training and the test sets to create one data set.
 2. Extracts only the measurements on the mean and standard deviation for each measurement.
 3. Uses descriptive activity names to name the activities in the data set.
 4. Appropriately labels the data set with descriptive activity names.
 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 


## Goals

 1. each variable should be in one column
 2. each observation of that variable should be in a diferent row
 3. include ids to link tables together



## Preliminaries

Getting data from tehn source file and decompress into files. I suppose that `.` is my working directory and there is a directory called `data` that contains data files. 

```{r}
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

```

## Merges data sets to create one data set

First, loading the data set in R variables.

```{r} 
# loading training / test measurements

train <- cbind(subject=read.table(paste(destination, "train", "subject_train.txt", sep="\\"), 
                                  col.names="SubjectID"),
                     y=read.table(paste(destination, "train", "y_train.txt", sep="\\"), 
                                  col.names="ActivityID"),
                     x=read.table(paste(destination, "train", "X_train.txt", sep="\\")))

test <- cbind(subject=read.table(paste(destination, "test", "subject_test.txt", sep="\\"),
                                 col.names="SubjectID"),
                    y=read.table(paste(destination, "test", "y_test.txt", sep="\\"), 
                                 col.names="ActivityID"),
                    x=read.table(paste(destination, "test", "x_test.txt", sep="\\")))



# loading features
features <- read.table(paste(destination,"features.txt",sep="\\"), 
                       col.names=c('id', 'name'),
                       header=FALSE, 
                       stringsAsFactors = FALSE)


# loading activity features
activity <- read.table(paste(destination, "activity_labels.txt", sep="/"), 
                       col.names=c('ActivityID', 'Activity'))

```

## Extracts only the measurements on the mean and standard deviation for each measurement.

Second, I merge data sets and subsetting columns witch names containing only the words "mean" or "std". faetures data set contains variables names and I selected only variables constraint for the mean and standard deviation. This new data set has 79 variables from test and train data sets and 2 id variables (SubjectID and ActivityID).

```{r}
data <- rbind(train,test)[, c(1,2,2 + features[grep("mean|std", features$name),][,1])]

```

## Uses descriptive activity names to name the activities in the data set

I merge data with a name list of activities, then removing the ActivityID column from the tidy data set. A new column called "Activity" is now add to the data set.

```{r}
# applying activity names
data <- merge(data, activity, by.x="ActivityID", by.y="ActivityID")
data <- data[,!(names(data) %in% c("ActivityID"))]
```



## Appropriately labels the data set with descriptive variable names

I create a list of variable names and replacing the old name list with the new one.

```{r}
# applying column names
names(data) <- c("Subject", "ActivityID", features$name[grep("mean|std", features$name)])       

```

## Create a tidy data set

I create a data set with the average of each variable for each activity and each subject.

```{r}
# data set with the average of each variable for each activity and each subject
data.mean <-  ddply(melt(data, id.vars=c("Subject", "Activity")),
                    .(Subject, Activity), 
                    summarise, 
                    Mean=mean(value))
```

## Save to file

Finally, I save data set objects to a tab-delimited text file called `UCI_HAR.mean.txt` and `UCI_HAR.data.txt`.




