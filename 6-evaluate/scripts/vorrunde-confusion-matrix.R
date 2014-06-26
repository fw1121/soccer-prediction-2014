source("scripts/prepare-soccer-data.R")
library(caret)

load(file="output/trained-random-forest-models.RData")

wm2014 <- subset(data, b_tournament_name=="WM" & b_tournament_year=="2014" & b_tournament_phase=="Endrunde")
wm2014_group <- subset(wm2014, b_tournament_group != "")

prediction_prob <- predict(
  test_results$em_and_wm_with_qualification.all.notdiff.randomForest$fitted, 
  newdata=wm2014_group,
  type="prob")
prediction_raw <- predict(
  test_results$em_and_wm_with_qualification.all.notdiff.randomForest$fitted, 
  newdata=wm2014_group,
  type="raw")

result <- cbind(
  wm2014_group[,c("b_team_home","b_team_away")], 
  prediction_prob[c("HOME_WIN","AWAY_WIN")],
  predicted_class=prediction_raw,
  actual_class=wm2014_group$r_game_outcome_before_penalties
)

print("Vorhersage für die Vorrunde")
print("===========================")
print(result);

result$predicted_class <- factor(result$predicted_class, levels=c("AWAY_WIN","DRAW","HOME_WIN"))
result$actual_class <- factor(result$actual_class, levels=c("AWAY_WIN","DRAW","HOME_WIN"))
notmissing <- !is.na(result$actual_class)

result_confusion <- confusionMatrix(
  data=result$predicted_class[notmissing], 
  reference=result$actual_class[notmissing])

print(result_confusion)