
# coding: utf-8

# In[30]:

import BeautifulSoup as bs
import re
import urllib

html = urllib.urlopen('http://python-data.dr-chuck.net/comments_281701.html').read()
soup = bs.BeautifulSoup(html)

tags = soup('span')

numbs = []

for tag in tags:
    numbs.append(tag.contents[0])

ints = [int(i) for i in numbs]

print sum(ints)
#re.findall('0-9+', tags[0])



# In[ ]:



