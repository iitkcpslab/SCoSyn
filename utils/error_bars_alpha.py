import numpy as np
import matplotlib.pyplot as plt
# include if using a Jupyter notebook
#%matplotlib inline

# Data
a02 = np.array([1])
a05 = np.array([1])
a07 = np.array([2])
a1 = np.array([2])

#a02 = np.array([4])
#a05 = np.array([2])
#a07 = np.array([7])
#a1 = np.array([11])

# Calculate the average
a02_mean = np.mean(a02)
a05_mean = np.mean(a05)
a07_mean = np.mean(a07)
a1_mean = np.mean(a1)

# Calculate the standard deviation
a02_std = np.std(a02)
a05_std = np.std(a05)
a07_std = np.std(a07)
a1_std = np.std(a1)

# Define labels, positions, bar heights and error bar heights
labels = ['0.20', '0.50', '0.70', '0.90']
x_pos = np.arange(len(labels))
p1m = [a02_mean, a05_mean, a07_mean, a1_mean]
error = [a02_std, a05_std, a07_std, a1_std]

width = 0.35       # the width of the bars: can also be len(x) sequence

fig, ax = plt.subplots()
rects1 = ax.bar(x_pos - width/2, p1m, width, label=r'$\phi_s$', yerr=error)


# Data for spec4
a02 = np.array([3])
a05 = np.array([3])
a07 = np.array([4])
a1 = np.array([10])

# Data for spec4
#a02 = np.array([18])
#a05 = np.array([17])
#a07 = np.array([17])
#a1 = np.array([29])

# Calculate the average
a02_mean = np.mean(a02)
a05_mean = np.mean(a05)
a07_mean = np.mean(a07)
a1_mean = np.mean(a1)

# Calculate the standard deviation
a02_std = np.std(a02)
a05_std = np.std(a05)
a07_std = np.std(a07)
a1_std = np.std(a1)

# Define labels, positions, bar heights and error bar heights
labels = ['0.20', '0.50', '0.70', '0.90']
x_pos = np.arange(len(labels))
p1m =  [a02_mean, a05_mean, a07_mean, a1_mean]
error = [a02_std, a05_std, a07_std, a1_std]
width = 0.35       # the width of the bars: can also be len(x) sequence

rects2 = ax.bar(x_pos + width/2, p1m, width, label=r'$\phi_c$', yerr=error)


# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel('# Iterations)',fontsize=20)
ax.set_xlabel(r'$\eta$',fontsize=20)
#ax.get_children()[1].set_color('black') 
ax.set_xticks(x_pos)
for tick in ax.xaxis.get_major_ticks():
                tick.label.set_fontsize(20)
for tick in ax.yaxis.get_major_ticks():
                tick.label.set_fontsize(20)
ax.set_xticklabels(labels)
ax.legend(prop={'size': 20})

fig.tight_layout()
#plt.ylim([0,100])
plt.savefig('alpha.png')
plt.show()
'''
# Build the plot
fig, ax = plt.subplots()
ax.bar(x_pos, CTEs,
       yerr=error,
       align='center',
       alpha=0.5,
       ecolor='black',
       color=colors,
       capsize=10)
ax.set_ylabel('# Iterations)')
ax.set_xticks(x_pos)
ax.set_xticklabels(labels)
#ax.set_title(r'$\lambda$')
ax.set_xlabel(r'$\alpha(\delta)$')
ax.yaxis.grid(True)


# Save the figure and show
plt.tight_layout()
plt.savefig('alpha.png')
plt.show()
'''
