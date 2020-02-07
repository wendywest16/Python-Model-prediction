Udemy course: Python+SQL+Tableau: Integration Python, SQL and Tableau.

BUSINESS PROBLEM: explore whether a person presenting certain characteristics is expected to be away from work at some point in time or not.

Model: Logistic regression

#Data pre-processing: Absenteeism_data.xlsx in MySQL Python Tableau_data preprocessing.ipynb

Dependent variable: 
- Hours absent from work: median = 3 hours, therefore >3hours and <3hours are the target variables

Independent variables:
- Reason for absence
- Month
- Day of the week
- Transportation expense
- Distance to work
- Age
- Daily work load
- BMI
- Children
- Pets
- Education

#Model creation:  Absenteeism_preprocessed.xlsx in MySQL Python Tableau_model selection.ipynb

Standardise input variables:
For a data set to be comparable with other datasets/new data, make sure the data has the same content and format as others (e.g. comparing percentage values instead of actual values). It gives each data point and the dataset greater meaning.
Do not standardise variables that have dummy values.

Overfitting versus Underfitting a model:
When a model is overfitted, it can predict the result of the current data well, but has poor predictability for new data. Solution: hide a small part of the database from the algorithm . Train the model based on most of the data, and test the data on the small part. 

Accuracy score: 
The score indicates the percentage of the observations that the model had learnt to classify correctly.

Intercept and coefficients of the model
The closer the coefficient is to 0, the smaller the weight of that coefficient. (NB. Relevant when all variables are of the same scale, i.e. standardised.)
When the odds ratio (exponential of the coefficient) is close to 1, that coefficient is not important.
The ‘Reason’ variables seem to have a lot of influence on absenteeism.

Decide which variables are important to use in the model: remove variables which have close to no contribution to the model using Backward elimination


#Model testing
The goal is to not adjust the model any further.
The result indicates how often (% accuracy) the model will predict the level of absenteeism correctly. If the test result was 10-20% less than the trained model, then the model is overfitted and will fail in real life.  

Probability estimates indicate, per record, the probability of resulting in “0 (<3 hours)” or “1 (>3 hours)”. If probability is <0.5, then “0 (<3 hours)” result, if >0.5 then a “1 (>3 hours)”.

#Save the model 
The model and the scaler (used to standardise all new data with the same method) saved using ‘pickle’

#Load the model to run on new data - Absenteeism_new_data.xlsx in Absenteeism_test_model.ipynb

#Plotting in Tableau Public:

https://public.tableau.com/profile/wendy8335#!/vizhome/Absenteeismofemployees/Dashboard2

1.	The average probability of excessive absenteeism (>3 hours) in staff across all age classes
2.	The probability of excessive absenteeism (>3 hours) per reason grouping
3.	The probability of excessive absenteeism (>3 hours) over the range of transport expenses and by the number of children per person 
