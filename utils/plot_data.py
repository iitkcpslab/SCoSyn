import numpy as np 
import pandas as pd 
from sklearn.metrics import confusion_matrix 
#from sklearn.cross_validation import train_test_split 
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier 
from sklearn.metrics import accuracy_score 
from sklearn.metrics import classification_report 
import numpy as np
import matplotlib.pyplot as plt

filename = "dataset.csv"

#Data set Preprocess data
dataframe = pd.read_csv(filename, dtype = 'category')
# Seperating the data into dependent and independent variables
X = dataframe.iloc[:,0:-1]
y = dataframe.iloc[:,-1]
print(X)
print(y)

plt.scatter(X[:,0], y, color="red")
plt.show()
#plt.scatter(X, y)
#plt.show()
