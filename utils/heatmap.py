import numpy as np
import seaborn as sns
import matplotlib.pylab as plt
import sys

N = sys.argv[1]
data = np.random.rand(N)
ax = sns.heatmap(data, linewidth=0.5)
plt.show()
