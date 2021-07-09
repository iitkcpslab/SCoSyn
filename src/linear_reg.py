import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
dataset = pd.read_csv('dataset.csv')
x = dataset.iloc[:, :-1].values
y = dataset.iloc[:,-1].values
#from sklearn.model_selection import train_test_split
#x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 1/3)

from sklearn.linear_model import LinearRegression
lr = LinearRegression()

lr.fit(x, y)
print(x[20])
x_test = [x[20]]
y_pred = lr.predict(x_test)
print(y_pred)

print(x[:,0])
print(y)
plt.scatter(x[:,0], y, color="red")
plt.show()
plt.scatter(x[:,1], y, color="blue")
plt.show()
plt.scatter(x[:,2], y, color="green")
plt.show()
