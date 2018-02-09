# I uploaded the data set used for this model in the respository

install.packages("RTools")
install.packages("rJava")
install.packages("XLConnectJars")
install.packages("XLConnect")
library(XLConnect)

#  Assume data files and r-script are on your desktop
setwd("pabloleal/...")
wb = loadWorkbook("Team Rosters.xlsx", create=FALSE)
players = readWorksheet(wb,sheet = "Players", startRow = 1, endRow = 264, startCol = 1, endCol = 19)
head(players)
tail(players)

#  When you view the data you can see that the second worksheet has numbers between 0 and 1 in each column.  That is
#  because the data has been SCALED.  SCALING is an important process to use.

#  A good thing to do when DEVELOPING code is to save the original data so you can always go back and refresh the data
#  in case you want to fix problems
bball = players

#  Put the data into a data frame and remove the player's names as they are not relevant for predictive work
bball_norm <- as.data.frame(bball[2:19])
head(bball_norm)

#  Set Random Number Seed for classification model
set.seed(1234)

#  Establish 67% of training data to train model and 33% to test the model against known values.  Randomly sample row
#  values from the original data and establish an index of "1" or "2" to represent "training" or "test" data sets.
ind <- sample(2, nrow(bball), replace=TRUE, prob=c(0.67,0.33))
head(ind)

#  Use row index to set training data
bball.training <-bball_norm[ind==1, 1:18]
head(bball.training)

#  Use row index to set test data
bball.test <- bball_norm[ind==2, 1:18]
head(bball.test)

#  Use the PARAMETER row associated with the "training data" that will be used to predict the same
#  PARAMETER for the "test data"
bball.trainlabels <- bball[ind==1, 19]
head(bball.trainlabels)
bball.testlabels <- bball[ind==2, 19]
head(bball.testlabels)

#  Run the K-NN function.  Typically this code is run until the model is acceptable.  We found that k=5 is a good
#  model so we will go with it.
bball_pred <- knn(train = bball.training, test = bball.test, cl = bball.trainlabels, k=5)

# Display results compared to true values
bball.testlabels
bball_pred

#  Now bring in the real data
draftroster = readWorksheet(wb,sheet = "Draft Roster", startRow = 1, endRow = 60, startCol = 1, endCol = 19)

bball2 = draftroster
bball2.training <-bball_norm[ind==1, 1:17]
head(bball2.training)

#  Put the data into a data frame and remove the player's names as they are not relevant for predictive work
bball2_norm <- as.data.frame(bball2[2:18])
head(bball2_norm)

#  One way to apply the kNN model to the new data with unknown LABELS is to create the model again with the
#  training data and then apply it to the new data.
draftee_predicted = knn(train = bball2.training, test = bball2_norm, cl = bball.trainlabels, k=5)
draftee_predicted

bball2$Team_Value = draftee_predicted
createSheet(wb,"Draftees - kNN")
writeWorksheet(wb,bball2, sheet = "Draftees - kNN",header = FALSE)
saveWorkbook(wb)
