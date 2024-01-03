import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.pipeline import Pipeline
from sklearn import metrics
from sklearn.linear_model import LogisticRegression, LinearRegression
from mord import LogisticIT, LogisticAT

def prepare(df, listnum, listcat):
    df_ready = df[listnum] 
    for c in listcat:
        df_ready = pd. concat([df_ready, pd.get_dummies(df[c], drop_first=True, prefix=c)], axis=1)
    
    return df_ready

def oraculo(X, y, model, params={}):
    (X_train, X_test, y_train, y_test) = train_test_split(
        X, 
        y, 
        test_size=0.2, 
        stratify=y, 
        random_state=3001
    )

    pipeline = Pipeline([("column", StandardScaler()), ("model", model)])
    print("Estimador: ", model)
    grid = GridSearchCV(
        pipeline, 
        params, 
        scoring="neg_mean_absolute_error",
        n_jobs=-1,
        cv=3
    )

    grid.fit(X_train, y_train)
    pred = grid.best_estimator_.predict(X_test)

    print(
        "Mean Absolute Error: %1.4f" % (metrics.mean_absolute_error(y_test, pred))
    )
    print(
        "Accuracy: %1.4f\n" % (metrics.accuracy_score(y_test, np.round(pred).astype(int)))
    )
    print(
        metrics.classification_report(
            y_test,
            np.round(pred).astype(int)
        )
    )
    print("\nDone!\n\n")




df = pd.read_csv("../../../_data/car_evaluation.csv", sep=";")
df.head()

listnum = ["evaluation"]
listcat = ["buying", "maint", "doors", "persons", "lug_boot", "safety"]

df_final = prepare(df, listnum, listcat)


models = [LinearRegression(), LogisticRegression(), LogisticIT(), LogisticAT()]
params = [
    {}, 
    {"model__max_iter":[100], "model__C":[1,0]},
    {"model__max_iter":[100], "model__alpha":[1,0]},
    {"model__max_iter":[100], "model__alpha":[1,0]},
]

for m, p in zip(models, params):
    oraculo(
        df_final.drop("evaluation", axis=1),
        df_final["evaluation"],
        m,
        p
    )

