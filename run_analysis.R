## Import libraries to assist data cleaning

library("plyr")
library("dplyr")

## Column Names in file features_list.txt

tableNames <- read.table("~/Documents/CourseraGetDataProject/UCI HAR Dataset/features.txt", header=FALSE, sep="\n")

## idenitfy mean and std columns as only those are to be kept

toBeSaved <- grepl(("mean|std"), tableNames$V1)

## Activity labels data frame, taken from activity_labels.txt

actLabels <- read.table("~/Documents/CourseraGetDataProject/UCI HAR Dataset/activity_labels.txt")
actLabels[,2] <- as.character(actLabels[,2])
colnames(actLabels) <- c("id", "activity")

## Dataset comes in multiple input files, covering data type (total acceleration, body acceleration, body gyroscope) in training and test data sets.

testDataSens <- read.table("~/Documents/CourseraGetDataProject/UCI HAR Dataset/test/X_test.txt", header=FALSE, sep = "")
testDataAct <- read.table("~/Documents/CourseraGetDataProject/UCI HAR Dataset/test/y_test.txt", header=FALSE)
testDataSubject <- read.table("~/Documents/CourseraGetDataProject/UCI HAR Dataset/test/subject_test.txt", header=FALSE)

trainDataSens <- read.table("~/Documents/CourseraGetDataProject/UCI HAR Dataset/train/X_train.txt", header=FALSE, sep = "")
trainDataAct <- read.table("~/Documents/CourseraGetDataProject/UCI HAR Dataset/train/y_train.txt", header=FALSE)
trainDataSubject <- read.table("~/Documents/CourseraGetDataProject/UCI HAR Dataset/train/subject_train.txt", header=FALSE)

## Combined test and training sets

combData <- rbind(testDataSens, trainDataSens)
combActKey <- rbind(testDataAct, trainDataAct)
combSubject <- rbind(testDataSubject, trainDataSubject)

## Extract on mean and std data into new data frame

datMeanStdOnly <- combData[,toBeSaved]

## Assign column names using features list from original data. This way tidy data and untidy data can be linked (and documentation is connectable between the two)

colnames(datMeanStdOnly) <- tableNames[toBeSaved,]
colnames(combActKey) <- "activity"
colnames(combSubject) <- "subject"

## Merge activity and test subject data and replace number tag with activity description

datMeanStdOnly <- cbind(datMeanStdOnly, combActKey)
datMeanStdOnly <- cbind(datMeanStdOnly, combSubject)
datMeanStdOnly$activity <- factor(datMeanStdOnly$activity, levels= actLabels[,1], labels=actLabels[,2])
datMeanStdOnly$subject <- as.factor(datMeanStdOnly$subject)

## Use ddply to split along variable activity and subject and mean all variables

meanDat <- ddply(datMeanStdOnly, .(activity, subject), function(x) colMeans(x[, 1:79]))
head(meanDat)

write.table(meanDat, "~/Documents/CourseraGetDataProject/averageTidyData.txt", row.name = FALSE)