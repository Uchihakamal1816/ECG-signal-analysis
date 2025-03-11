#recommendation:by random forest classification (super vised learning)
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.signal import find_peaks
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report


filename = "ecg_rr_intervals.csv"  # dataset (we require more data)
data = pd.read_csv(filename)

#the above data is aldready preprocessed and we got rrintervals (see matlab codes to know how to get rr intervals qrs complex models)
time_rr = data['RR_intervals'].values


feat = {
    "mean": np.mean(time_rr),
    "std": np.std(time_rr),
    "min": np.min(time_rr),
    "max": np.max(time_rr),
    "median": np.median(time_rr),
    "range": np.max(time_rr) - np.min(time_rr)
}
feature_df = pd.DataFrame([features])

# Labeling 1 as unhealthy and 0 as normal
labels = data['Label']

# distributing data into training and testing 
X_train, X_test, y_train, y_test = train_test_split(feature_df, labels, test_size=0.2, random_state=42)


model = RandomForestClassifier(n_estimators=100, random_state=42)#applying random forest classifier
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
print("Accuracy:", accuracy_score(y_test, y_pred))
print(classification_report(y_test, y_pred))
real_time = [0.85, 0.92, 0.89, 1.05, 0.80]  # for new data to make it real time learning
real_feat = pd.DataFrame([{  
    "mean_rr": np.mean(real_time),
    "std_rr": np.std(real_time),
    "min_rr": np.min(real_time),
    "max_rr": np.max(real_time),
    "median_rr": np.median(real_time),
    "rr_range": np.max(real_time) - np.min(real_time)
}])

#same as labeling models
prediction= model.predict(real_feat)
print("Heart Issue Detected" if prediction[0] == 1 else "Heart is Normal")

''' 
by the above method we can analyze the rr intervals and tell whether the patient is facing any problem in rela time and our model can even say whether
our patient will be facing any kind fo problem in future or not by predicting it with an accuracy'''
