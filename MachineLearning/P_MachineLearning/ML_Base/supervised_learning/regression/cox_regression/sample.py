import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sb

from lifelines.plotting import plot_lifetimes      # Lifeline package for the Survival Analysis
from lifelines import KaplanMeierFitter


## Example Data 
durations = [5,6,6,2.5,4,4]
event_observed = [1, 0, 0, 1, 1, 1]

# create a dataframe
df = pd.read_csv("../../../_data/Telco-Customer-Churn.csv")

# Have a first look at the data
# print(df.head())
# print(df.info())


# Convert TotalCharges to numeric
df["TotalCharges"] = pd.to_numeric(df["TotalCharges"], errors="coerce")

# Replace yes and no in the churn column to 1 and 0
df["Churn"] = df["Churn"].apply(lambda x: 1 if x == "Yes" else 0)

# after converting the column TotalCharges to numeric
# print(df.info()) # Column TotalCharges is having missing values

# impute a list of Categories and their distribution in all the categorical distributions
df.TotalCharges.fillna(value=df["TotalCharges"].median(), inplace=True)

# Create a list of categorical Columns
cat_cols = [i for i in df.columns if df[i].dtype==object]
cat_cols.remove("customerID") # customerID has been removed because it is unique for all rows

# # lets have a look at the categories and their distribution
# for i in cat_cols:
#     print("Column Name: ", i)
#     print(df[i].value_counts())
#     print("-----------------------")


durations = df['tenure'] ## Time to event data of censored and event data
event_observed = df['Churn']  ## It has the churned (1) and censored is (0)

## create a kmf object as km
km = KaplanMeierFitter() ## instantiate the class to create an object

## Fit the data into the model
km.fit(durations, event_observed,label='Kaplan Meier Estimate')

## Create an estimate
km.plot()
plt.show()



