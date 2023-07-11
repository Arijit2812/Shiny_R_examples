# Shiny_R_examples
For the given dataset, we will start with assigning roles to the variables and EDA, then declare and implement a strategy for missing data and outliers followed by modeling.

CODE - ID role

POLITICS - Predictor role

POPULATION - Predictor role

AGE25_PROPTN - Predictor role

AGE_MEDIAN - Predictor role

AGE50_PROPTN - Predictor role

POP_DENSITY - Predictor role

GDP - Predictor role

INFANT_MORT - Predictor role

DOCS - Predictor role

VAX_RATE - Predictor role

HEALTHCARE_BASIS - Predictor role

HEALTHCARE_COST - Predictor role

DEATH_RATE - Outcome role

OBS_TYPE - test/train split (split role)

An initial scan of the raw data reveals missingness in all predictor role except HEALTHCARE_BASIS. Missing data is represented as NA, -99 (as AGE25_PROPTN, AGE50_PROPTN, DOCS, VAX_RATE can’t be negative), -- (missing value for POLITICS)
Also, it is important to note that all HEALTHCARE_COST against FREE HEALTH_CARE BASIS
has missing value. Missing value for HEALTHCARE_COST against FREE HEALTH_CARE
BASIS can be manually assigned to 0 as zero healthcare cost is a representation of free health
care.
The value of ‘16’ (outlier) for VAX_RATE also seems an interesting one as 6 observations has
this exact value. It may be a manual entry error or maybe not. Opinion of a domain expert would
be helpful to understand this datapoint. Keeping it as it is for now.
The missing value for POLITICS is likely due to unavailability of the data point or unclarity of the
type of politics. So created a new level as ‘NONE’ rather than clubbing this with ‘OTHER’.

For EDA - Summary table, DT::Datatable, GGally::ggpairs plot, Corrgram correlation chart,
Boxplot for variables, Rising value chart, Missing data plots

HEALTHCARE_COST has bimodal distribution.

GDP and VAX_RATE shows a left skewed distribution.

POPULATION shows a right skewed distribution.

![eda1](https://github.com/Arijit2812/Shiny_R_examples/assets/65775311/07bb12e7-6b3b-4ca4-b5c4-261bc53fdb32)
POP_DENSITY and HEALTHCARE_COST, when plotted together show three distinct sets of
points. When coloured by HEALTHCARE_BASIS, all sets of points have three different colour.
This implies, PRIVATE HEALTH_CARE BASIS has significantly higher HEALTHCARE_COST
than INSURANCE HEALTH_CARE BASIS. FREE HEALTH_CARE BASIS is implied to have no
cost.

Whenever, we have missing value for POLITICS we have corresponding rows missing for
AGE25_PROPTN and INFANT_MORT

![eda2](https://github.com/Arijit2812/Shiny_R_examples/assets/65775311/d6951c38-bc49-4608-ab16-6fab53879164)
VAX_RATE and POPULATION are negatively correlated. AGE25_PROPTN and
INFANT_MORT are strongly negatively correlated.
AGE25_PROPTN and AGE_MEDIAN are positively correlated.
Given the variables are grouped in the correlation chart we can see that variables
DEATH_RATE, DOCS and INFANT_MORT form a set. So does AGE25_PROPTN,
AGE50_PROPTN and AGE_MEDIAN.

![eda3](https://github.com/Arijit2812/Shiny_R_examples/assets/65775311/22e89224-e548-44c4-95be-52539affc1f3)
POPULATION shows high outliers only.
VAX_RATE shows low outliers only.
AGE50_PROPTN, HEALTHCARE_COST show both high and low outliers.
VAX_RATE, GDP and HEALTHCARE_COST don’t lose their outliers even when the IQR
multiplier = 5 i.e they are serious outliers. Opinion of a domain expert will help to understand this
better.

HEALTHCARE_COST shows a discontinuity in which the values jump from 6000 to 14000 with
no values in between.
AGE_MEDIAN falls short of the end of the chart due to its missing values.

![eda4](https://github.com/Arijit2812/Shiny_R_examples/assets/65775311/49d0e4ef-2f0e-4db6-84aa-815378ed6d78)
CODE, HEALTHCARE_BASIS have no missing values.
AGE_MEDIAN has high missingness (>50%)
POPULATION, AGE25_PROPTN, AGE50_PROPTN have relatively less missingness.
When POP_DENSITY > 500 there is an average of 4 missing variables per observation. Also,
for POP_DENSITY < 5 and POP_DENSITY_SHADOW = 1 there is an average of 3.8 missing
variables per observation.

Proportion Missing- large(>50%) for one variable(AGE_MEDIAN) and small (around 20%) for
the rest which has missing values

Informative missingness - create shadow variable and refer missingness pattern chart
Missing type - Probably MCAR and MAR. Opinion of domain expert required to suspect MNAR
Expect in future - Yes
Tolerant method - No (glmnet)

Proceeding with statistical imputation seems like a better approach than partial delete (as MAR
is suspected). Manual imputation doesn’t seem reasonable (except for HEALTHCARE_COST
against FREE HEALTH_CARE BASIS and POLITICS) as the missing values are not of “Not
Applicable” style and sensible value for in-filling can only be provided by a domain expert.
Coming to the imputation, KNN or tree based imputation seems like the most viable option here.
Median imputation may be slightly ineffective as HEALTHCARE_COST is bimodal. We have the
option to select among various imputation methods along with partial delete. We also have the
option to select variable and observation missingness threshold.

Next we convert categorical variables to numbers using dummy encoding such that the model is
able to understand and extract valuable information. We also remove zero variance predictors
and predictors that are linear combinations of other predictors as they have less predictive
power.

We use the training data to train the model. We will try out a few missingness thresholds to check
how our model is performing and explore in detail for one value of the missingness threshold
(similar concept can be extended to other missingness threshold)

For the 50% variable and observation missingness threshold (based on judgment), we remove
the missing variables first followed by observations (as this will ensure minimum data loss) and
then impute missing values. After training the model we compute the test-RMSE statistic.
KNN RMSE for test data is 2.81
Median RMSE for test data is 2.68
Tree based RMSE for test data is 2.53 (takes a lot of time to train the model)
Tree based imputation gives the lowest RMSE for test data

When we decrease the missingness threshold to 30% for both variable and observation
missingness, we see a decrease in the test RMSE statistic for tree based imputation (test RMSE
value remained similar for KNN and Median imputation )
KNN RMSE for test data is 2.81
Median RMSE for test data is 2.68
Tree based RMSE for test data is 2.43
Here also, Tree based imputation gives the lowest RMSE for test data.

Decreasing the missingness threshold even further to 10% for both variable and observation
missingness we can observe an increase in RMSE statistic
KNN RMSE for test data is 4.86
Median RMSE for test data is 4.86
Tree based RMSE for test data is 4.86

So, we can observe that the missingness threshold at 30% results in the lowest test RMSE
statistic compared to 10% and 50% missingness. This implies that by setting the variable and
observation missingness threshold at 30% we can expect a relatively good model. Also, Tree
based imputation is performing better than KNN imputation.

Residual boxplot shows the following outliers (considering 50% missingness and can be
extended to other missingness % values)

Observation number (CODE) of Test outlier
20,320,295,344,250 (IQR 2) -KNN
250, 344 (IQR 2) - Median
389,250,344 (IQR 2) - Tree

Possible outliers 20, 320,250,344,389
20 - values for 5 predictors missing
320- values for 4 predictors missing, one outlier (VAX_RATE)
250- values for 4 predictors missing
344- values for 3 predictors missing
389- values for 5 predictors missing

Observation number (CODE) of Train outlier
255,291,308,93,397,201 (IQR 2) - KNN
97,405,201,397 (IQR 2) - Median
56,97,29,72,397,201,405 (IQR 2) - Tree

Possible outliers 72, 397,97,405,201
72 - values for 7 predictors missing
397- values for 7 predictors missing, one outlier (GDP)
97- values for 3 predictors missing, one outlier (VAX_RATE)
405- values for 3 predictors missing
201- values for 4 predictors missing

Uni-variable outlier may be able to explain 320, 97
Large proportion of missing values may be able to explain 20, 389, 72, 397,250,201. Perhaps
imputation is not performing well could be an explanation.
Erroneous or missing value place holder may be able to explain 344,405

Opinion of a domain expert would be required to evaluate this further.

For tree based imputation, in our model, α=1 and λ=0.06175543 are selected at 50% missing
threshold.
This gives the lowest RMSE and highest Rsquared
RMSE was used to select the optimal model using the smallest value.
The final values used for the model were alpha = 0.1 and lambda = 0.06175543.
RMSE statistic for test data is 2.53 which can be used to evaluate the model's theoretical
performance. As the RMSE statistic for train data is 2.83, it suggests that there is a slight
underfitting of the data.

Similarly, for KNN based imputation, in our model, α=1 and λ=0.0645761 are selected at 50%
missing threshold.
This gives the lowest RMSE and highest Rsquared.
RMSE was used to select the optimal model using the smallest value.
The final values used for the model were alpha = 1 and lambda = 0.0645761.
RMSE statistic for test data is 2.81 which can be used to evaluate the model's theoretical
performance. As the RMSE statistic for train data is 2.74, it suggests that there is a slight
overfitting of the data.

Lasso regression was selected in both the methods.
