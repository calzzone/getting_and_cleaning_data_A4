# Getting and Cleaning Data - Assignement 4
## Description of the run_analysis.R file

The run_analysis.R file will produce a text file named "summary_df.txt" if the data file named "getdata_projectfiles_UCI HAR Dataset.zip" is prezent in the working directory. The file has the functionality to also download it if you uncomment line 10.
This script requires the "tidiverse" package.

## Getting the data
After unzipping, the sript changes the working directory to the folder "UCI HAR Dataset", which is created by the unzip process.
Next, it imports all of the necessary files: 
* "test/subject_test.txt" and "train/subject_train.txt" into `test_subjects` and `train_subjects` numeric vectors. These are the ID of the subjects
* "activity_labels.txt" into the `activity_labels` character vector, containing the names of the 6 recorded activities: "walking", walking upstairs", "walking downstairs", sitting", "standing", "laying"
* "features.txt" into `features` character vector, containing 561 feature names provided by the data set
* "test/X_test.txt" and "train/X_train.txt" into `X_test` and `X_train` data frames (tbl_df), which contain the features
* "test/y_test.txt" and "train/y_train.txt" into `y_test` and `y_train` factor vectors with the activity labels as levels
* I also imported but later commented the row signals because they were not relevant to the assignment.

## Merging the training and the test sets to create one data set
So far, I have 2 sets of data, one for the test and one for the train data. I have to merge them to one data set.

I joined the subjects ( subjects <- c(test_subjects, train_subjects) %>% as.factor() ), the features ( X_data <- rbind(X_test, X_train) ) and the activities ( y_data <- c(y_test, y_train) %>% factor(labels = activity_labels) ). Next, i joined all of them into one data frame (tbl_df): xy_data <- cbind(subjects, activity = y_data, X_data) .

## Extract only the measurements on the mean and standard deviation for each measurement
I used the regex "(mean\\()|(std\\()" on the features vector in order to select all the features with "mean(" or "std(". There were also some features with "meanFreq(" but, as far as I understand the documentation, these are to be excluded. If not, remove the "\\(" parts from the regex and add the appropiate level label at line 152.
At the end of this setion I have a new data frame named `mean_and_std` with the necessary columns.

## Making the data nicer
I have already applied the activity labels. The features labels are good enough in my opinion, but I can make them sound like English. This section trasforma the names of the features vector to acheive this. I created a character vector named `better_labels` which I applied to the `mean_and_std` data frame.

## Average of each variable for each activity and each subject
I created a new data frame with summary statistics (mean) of all columns of the data (except the grouping variables) and I exported it to a txt file in the working directory.
