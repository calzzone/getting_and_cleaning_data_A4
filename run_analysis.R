




# set-up
library(tidyverse)
#setwd("/home/calzzone/Desktop/coursera/test")

#download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "getdata_projectfiles_UCI HAR Dataset.zip")
unzip("getdata_projectfiles_UCI HAR Dataset.zip")
#list.dirs()
setwd("UCI HAR Dataset")
#getwd()
#list.files()





# get data

## get subjecs IDs
test_subjects  <- read_lines( "test/subject_test.txt")  %>% as.numeric() # 2947 total, 9 unique
train_subjects <- read_lines("train/subject_train.txt") %>% as.numeric() # 7352 total, 21 unique
#table(test_subjects)  # subjects 2   4   9  10  12  13  18  20  24
#table(train_subjects) # subjects 1   3   5   6   7   8  11  14  15  16  17  19  21  22  23  25  26  27  28  29  30

## get activity labels
activity_labels <- 
  read_lines("activity_labels.txt") %>% 
  str_split(" ") %>% # separate line number
  sapply(function(x) x[2]) %>% # remove line number
  tolower() %>%
  str_replace_all(pattern = "_", " ") 
# [1 to 6] "walking", walking upstairs", "walking downstairs", sitting", "standing", "laying" 


## get features names
features <- read_lines("features.txt") %>% str_split(" ") %>% sapply(function(x) x[2]);
# [1 to 561] "tbodyacc-mean()-x", "tbodyacc-mean()-y", "tbodyacc-mean()-z"

# some features are repeated: 
#f1 <- data.frame(n=1:561, features)
#f2 <- data.frame(table(features))
#merge(f1, f2, "features") %>% arrange(desc(`Freq`), features, n)


## get X data: features extracted from the raw data
X_test  <- read_table( "test/X_test.txt",  col_names = features, col_types = paste0(rep("d", 561), collapse = "")) 
X_train <- read_table("train/X_train.txt", col_names = features, col_types = paste0(rep("d", 561), collapse = ""))
# some names are not unique. those names are marked with _1 and _2; these are the "-bandsEnergy()" variables
#str(X_test)
#str(X_train)

## get Y data: seems like activity labels
y_test  <- read_lines( "test/y_test.txt")  %>% factor(labels = activity_labels) # 2947 total, 1 to 6
y_train <- read_lines("train/y_train.txt") %>% factor(labels = activity_labels) # 7352 total, 1 to 6
#table(y_test)  # subjects 2   4   9  10  12  13  18  20  24
#table(y_train) # subjects 1   3   5   6   7   8  11  14  15  16  17  19  21  22  23  25  26  27  28  29  30
#y_test[y_test==activity_labels[1]]


## get the signals: not necessary for the assignemnt
# make a list from the 9 files of 2947 rows and 128 columns
#test_path <- "test/Inertial Signals/"
#test_files <- list.files(test_path)
#test_data <- lapply(paste0(test_path, test_files), read_table, col_names=F, col_types = paste0(rep("d", 128), collapse = ""))
#names(test_data) <- str_remove(test_files, "_test.txt")
#str(test_data)

#train_path <- "train/Inertial Signals/"
#train_files <- list.files(train_path)
#train_data <- lapply(paste0(train_path, train_files), read_table, col_names=F, col_types = paste0(rep("d", 128), collapse = ""))
#names(train_data) <- str_remove(train_files, "_train.txt")
#str(train_data)

# at this point rowMeans(test_data$body_acc_x_test.txt) is the same as X_test$`tBodyAcc-mean()-X`






# Merges the training and the test sets to create one data set.

## subjects
subjects <- c(test_subjects, train_subjects) %>% as.factor()

## X data: features extracted from the raw data
X_data <- rbind(X_test, X_train)
#str(X_data)

## Y data: activities
y_data <- c(y_test, y_train) %>% factor(labels = activity_labels)
#str(y_data)

# merging all composite data into one data set complete with subject id and activity label
xy_data <- cbind(subjects, activity = y_data, X_data)
#str(xy_data)

## sigal data (not necesary for the assignment)
# signal_data <- test_data
# for (var in names(signal_data)) {
#   #print(var)
#   signal_data[[var]] <- rbind(test_data[[var]], train_data[[var]]) # merge test and train signal data  
#   signal_data[[var]] <- cbind(subjects, activity = y_data, signal_data[[var]]) # add activity and subject ID
# }
# str(signal_data[[var]])







# Extracts only the measurements on the mean and standard deviation for each measurement.

cols_with_mean_or_std <- grep("(mean\\()|(std\\()", features) # use "\\(" to avoid selecting columns with "meanFreq()" in their name
#features[cols_with_mean_or_std]

mean_and_std <- xy_data %>% 
  select(subjects, activity, features[cols_with_mean_or_std])  
#str(mean_and_std)







# Uses descriptive activity names to name the activities in the data set

# Already done.





# Appropriately labels the data set with descriptive variable names.

# The names are already descriptive enough. However, better labels can be created by transforming the current names.

df <-features[cols_with_mean_or_std] %>% str_split("-", simplify = T) %>% data.frame() %>%
  mutate(
    X1 = as.character(X1) %>%
      str_replace_all("Gyro", " gyration")%>%
      str_replace_all("Acc", " acceleration")%>%
      str_replace_all("tBody", "time-domain body") %>%
      str_replace_all("fBody", "frequency-domain body")%>%
      str_replace_all("tGravity", "time-domain gravity")%>%
      str_replace_all("Jerk", " (Jerk)") %>%
      str_replace_all("Mag", " magnitude") %>% 
      str_remove_all("Body"),
    fun = factor(as.character(X2), labels = c("Mean of:", "SD of:")) %>% as.character(),
    axis = factor(as.character(X3), labels = c("", "on X axis", "on Y axis", "on Z axis")) %>% as.character(),
    label = paste(fun, X1, axis, sep=" ")
  )

better_labels <- c("Subject ID", "Activity", df$label)
names(mean_and_std) <- better_labels






# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

summary_df <- mean_and_std %>% 
  group_by(Activity, `Subject ID`) %>%
  summarise_all(mean)

#summary_df


write.table(summary_df, "../summary_df.txt", row.name=FALSE)

