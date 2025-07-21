import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
import joblib

all_data = pd.read_csv("resale-flat-prices-based-on-registration-date-from-jan-2017-onwards.csv")

hdb4 = all_data.loc[(all_data.flat_type == "4 ROOM") & (all_data.month.str.contains('2019')), 
                    ['town', 'storey_range', 'floor_area_sqm', 'resale_price']]

storey_columns = hdb4.storey_range.str.split(pat=" TO ", expand=True)
storey_columns.columns = ['storey_min', 'storey_max']

hdb4['storey'] = storey_columns.apply(lambda x: (int(x[0])+int(x[1]))/2, axis=1)

hdb4['ppsqm'] = hdb4.resale_price/hdb4.floor_area_sqm

lm1 = LinearRegression()
ct1 = ColumnTransformer([('categories', OneHotEncoder(dtype='int'), ['town'])], remainder='passthrough')

X = hdb4.loc[:, ['town', 'storey']]
ct1.fit(X)

X_new = ct1.transform(X)
lm1.fit(X_new, hdb4.ppsqm)

joblib.dump((lm1, ct1, hdb4), 'lm_api.pkl', compress=3)
