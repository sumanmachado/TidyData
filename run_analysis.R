## Setting the working directory
setwd ("R/project")

## Installing required packages
install.packages ("gdata")
install.packages ("plyr")
install.packages ("data.table")
library (gdata)
library (plyr)
library (data.table)

## Reading in the x test and train data
x_test_data <- read.table ("x_test.txt", fill=FALSE, strip.white=TRUE)
x_train_data <- read.table ("x_train.txt", fill=FALSE, strip.white=TRUE)

## Reading in the y test and train data
y_test_data <- read.table ("y_test.txt", fill=FALSE, strip.white=TRUE)
y_train_data <- read.table ("y_train.txt", fill=FALSE, strip.white=TRUE)

## Reading in the subject test and train data
subject_test_data <- read.table ("subject_test.txt", fill=FALSE, strip.white=TRUE)
subject_train_data <- read.table ("subject_train.txt", fill=FALSE, strip.white=TRUE)

## Reading in the features and activity labeles
features <- read.table ("features.txt", fill=FALSE, strip.white=TRUE)
activity_labels <- read.table ("activity_labels.txt",fill=FALSE, strip.white=TRUE)

## Merging all sets of files
x_total <- rbind (x_test_data, x_train_data)
y_total <- rbind (y_test_data, y_train_data)
subject_total <- rbind (subject_test_data, subject_train_data)

## Assigning column names
colnames (x_total) <- features[,2]
colnames (y_total) <- c("activity_code")
colnames (activity_labels) <- c("activity_code", "activity_label")
colnames (subject_total) <- c("subject")

## Selecting only columns with std and mean from x data
x_selected <- x_total [grep ('(std|mean)\\(\\)$', names(x_total), value=TRUE) ]

## Merging with y and subject files
y_total <- merge (x = y_total, y=activity_labels, by="activity_code")
y_total <- y_total [,"activity_label"]
total_data <- cbind (subject_total, y_total [,"activity_label"], x_selected)
total_data <- rename (total_data, c("y_total"="activity"))

## Making the column names more descriptive
names (total_data) <- gsub ('BodyBody','Body', names(total_data))
names (total_data) <- gsub ('tBody','timeBody', names(total_data))
names (total_data) <- gsub ('fBody','freqBody', names(total_data))
names (total_data) <- gsub ('tGravity','timeGravity', names(total_data))
names (total_data) <- gsub ('\\(\\)','', names(total_data))

## Grouping by subject and activity to find averages per variable
Molten <- melt (total_data, id.vars = c("subject", "activity"))
data_mean <- cast (subject + variable ~ activity, data = Molten, fun = mean)
 
## Writing out result to a file
write.table (data_mean, "tidy_data_mean.txt", row.name=FALSE)
