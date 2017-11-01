from __future__ import division
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style('dark')
sns.set_palette('bright')


with open('/Users/jimmy//Documents/measles_data.csv', 'r') as f:
    rows = [row for row in f]
    data = [rows[i].split(',') for i in range(len(rows))]
    date = [data[i][0] for i in range(len(data))]
    cases = [data[i][1] for i in range(len(data))]
    cases = [cases[i].rstrip() for i in range(len(cases))]
    cases = [int(cases[i]) for i in range(len(cases))]   
    
percentinfect = [cases[i] / 50900000 * 100 for i in range(len(cases))]
propinfect = [cases[i] / 50900000 for i in range(len(cases))]

fig = plt.figure()
ax = plt.subplot(1,1,1)
plt.plot(date, percentinfect)
ax.set_xlabel('Date')
ax.set_ylabel('Percentage of the Population Infected')
ax.set_xticks(range(1950, 1961))
sns.despine()
plt.show()

 
    
