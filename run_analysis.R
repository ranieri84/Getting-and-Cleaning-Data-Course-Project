library(data.table)
library(dplyr)
path <- getwd()

#read subjects
SubjTrain <- data.table(read.table(file.path(
    path,'UCI HAR Dataset', 'train', 'subject_train.txt')))
SubjTest <- data.table(read.table(file.path(
    path, 'UCI HAR Dataset', 'test', 'subject_test.txt')))

# read data
dfTrain_X <- data.table(read.table(file.path(
    path,'UCI HAR Dataset', 'train', 'X_train.txt')))
dfTrain_Y <- data.table(read.table(file.path(
    path,'UCI HAR Dataset', 'train', 'y_train.txt')))
dfTest_X <- data.table(read.table(file.path(
    path, 'UCI HAR Dataset', 'test', 'X_test.txt')))
dfTest_Y <- data.table(read.table(file.path(
    path, 'UCI HAR Dataset', 'test', 'y_test.txt')))

# merge files
dfMerge_X<-rbind(dfTrain_X,dfTest_X)
dfMerge_Y<-rbind(dfTrain_Y,dfTest_Y)
subjMerge<-rbind(SubjTrain,SubjTest)

# Attribute meaningful  variable names
colvarnames <- data.table(read.table(file.path(
    path, 'UCI HAR Dataset','features.txt')))[,2]
names(dfMerge_X)<-unlist(colvarnames)
names(dfMerge_X)<-gsub("^t", "time", names(dfMerge_X))
names(dfMerge_X)<-gsub("^f", "frequency", names(dfMerge_X))

# Select only columns with mean and Std 
dfFinal=dfMerge_X
newcolun<-grep("mean|std",colvarnames$V2)
dfFinal<-dfFinal[,..newcolun] 

# Add Subject and Activity columns
dfFinal[,(c("Subject","Activity"))]<-c(subjMerge,dfMerge_Y)

# Attribute descriptive activity names
dfFinal$Activity<-factor(dfFinal$Activity,levels = c(1,2,3,4,5,6),
                         labels = c("WALKING","WALKING_UPSTAIRS",
                                    "WALKING_DOWNSTAIRS","SITTING",
                                    "STANDING","LAYING"))

# Creat Convert subjects to a factor structure
dfFinal$Subject<-factor(dfFinal$Subject)

# Create new DF with mean grouped by Activity and Subject
suppressWarnings(cleandata <- aggregate(dfFinal, by = list(dfFinal$Subject, dfFinal$Activity), FUN = mean,drop = TRUE))
colnames(cleandata)[1] <- "Subject"
names(cleandata)[2] <- "Activity"

#remove last 2 unused columns
cleandata<-cleandata[1:81]

#write tidydata
write.table(cleandata,file = "tidydata.txt", row.names = FALSE)
