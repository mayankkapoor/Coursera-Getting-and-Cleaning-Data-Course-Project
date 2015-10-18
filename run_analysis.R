# (c) Mayank Kapoor 2015
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Make sure data.table and reshape2 are installed.
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Set working directory
setwd("/Users/mayankkapoor/Dropbox/2015-09-09 Coursera Data Science/03 Get and Clean Data/")

# Extract activity labels
activity_labels <- read.table("./data/uci/UCI HAR Dataset/activity_labels.txt")[, 2]

# Extract features
features <- read.table("./data/uci/UCI HAR Dataset/features.txt")[, 2]

# Create a true/false vector for features that are either std or mean
extract_features <- grepl("mean|std", features)

# Load X_test and y_test data
X_test <- read.table("data/uci/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("data/uci/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("data/uci/UCI HAR Dataset/test/subject_test.txt")
names(X_test) <- features

# Extract only mean and std from measurements
X_test <- X_test[, extract_features]

# Load labels
y_test[, 2] = activity_labels[y_test[, 1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data on columns
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load X_train and y_train data
X_train <- read.table("data/uci/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("data/uci/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("data/uci/UCI HAR Dataset/train/subject_train.txt")
names(X_train) = features

# Extract only mean and std from measurements
X_train = X_train[, extract_features]

# Load labels
y_train[, 2] = activity_labels[y_train[, 1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Column bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "data/uci/tidy_data.txt", row.names = FALSE)

# References: https://github.com/deduce/Getting-and-Cleaning-Data-Project

