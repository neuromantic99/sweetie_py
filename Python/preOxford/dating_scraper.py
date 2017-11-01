
# coding: utf-8

# In[ ]:

from html.parser import HTMLParser  
from urllib.request import urlopen  
from urllib import parse
import random
from bs4 import BeautifulSoup as bs
import re
from string import digits

class LinkParser(HTMLParser):

    def handle_starttag(self, tag, attrs):
           if tag == 'a':
            for (key, value) in attrs:
                if key == 'href':
                    
                    newUrl = parse.urljoin(self.baseUrl, value)
 
                    self.links = self.links + [newUrl]

    def getLinks(self, url):
        self.links = []
  
        self.baseUrl = url

        response = urlopen(url)

        #if response.getheader('Content-Type')=='text/html':
        htmlBytes = response.read()

        htmlString = htmlBytes.decode("utf-8")
        self.feed(htmlString)
        return htmlString, self.links[4:16]
        #else:
            #return "",[]
            #print('fuck')
            
def randname():
   
    ''' returns a single random name from the us census'''
   
    fhand = urlopen('http://deron.meranda.us/data/census-derived-all-first.txt')
    table =  [line.strip() for line in fhand]
    tsplit = [t.split() for t in table]
    namebyte = [tsplit[i][0] for i in range(len(tsplit))]
    names = [i.decode('UTF-8') for i in namebyte]

    return random.choice(names)

def randword():
    
    ''' returns a random word from a list of 1524 of the most common nouns in the english language '''
    
    fhand = urlopen('http://www.talkenglish.com/vocabulary/top-1500-nouns.aspx').read()
    stringform = fhand.decode("utf-8")
    soup = bs(stringform, 'html.parser')
    tables = soup.find_all('tr')
    wordtags = tables[4:-1]
    words = [word.get_text() for word in wordtags]
    words = [w.strip() for w in words]
    words = [re.sub('\(.+\)', '', wo) for wo in words]
    # removes part of string in parentheses
    
    words = [w.translate({ord(k): None for k in digits}) for w in words]
    # removes numbers from each string
    
    return random.choice(words)
    
    

def searchaddress():
    
    ''' takes a random word and formats into URL, returns url1 for first search page 
        and url2 for second search page '''                     
    
    base = 'http://www.whosdatedwho.com/search?q='
    base2 = '&page=2'
    word = randname()
    url = base + word
    url2 = base + word + base2
    return url, url2

def celebinfo(url):
    
    ''' returns a dictionary  containing information about the celebrity'''
    
    rawdata = urlopen(url).read()
    rawdata = rawdata.decode("utf-8")
    soup = bs(rawdata, 'html.parser')
    try:
        tables = soup.find_all('table')
        data = tables[1].find_all('td')

        keys = data[::2]
        keys = [k.get_text() for k in keys]
        keys = [k.strip() for k in keys]

        vals = data[1::2]
        vals = [v.get_text() for v in vals]
        vals = [v.strip() for v in vals]

        dictm = {k: v for k, v in zip(keys, vals)}
        
        return dictm
    
    except:
        return 'empty'

    #name = dictm.get('First Name')
    #print(list(dictm.keys()))
    
def childage(url):
    
    ''' returns a list of the ages of each of the children '''
    rawdata = urlopen(url).read()
    rawdata = rawdata.decode("utf-8")

    soup = bs(rawdata, 'html.parser')

    tables = soup.find_all('table')

    data = tables[3].find_all('td')
    
    data = [d.get_text() for d in data]
    data = [d.strip() for d in data]
    
    agestr = [x for x in data if "years" in x ]
    
    ages = []
    
    for i in range(len(agestr)):
        ages.append([int(s) for s in agestr[i].split() if s.isdigit()])
        
    ages = [ages[i][0] for i in range(len(ages))]
    
    return ages
        

    

def spider(): 
    maxPages = 120
    numberVisited = 0
    foundWord = False
    

    while numberVisited < maxPages and not foundWord: 
    #and pagesToVisit != []:
        numberVisited = numberVisited +1
        
        url1, url2 = searchaddress()
        
        pagesToVisit = [url1]
        
        

        url = pagesToVisit[0]
        pagesToVisit = pagesToVisit[1:]
        

        print(numberVisited, "Visiting:", url)
        parser = LinkParser()
        data, links = parser.getLinks(url)

        infos = [celebinfo(link) for link in links]
        
        
        for link in links:
            
            try:
        
                childag = childage(link)
                print(childag)

                for c in childag:
                    if c > 5:
                        print ('checkout')
                        foundWord = True

                    else:
                        print('young')
                    
            except:
                print('no kids')

     
        
#         for info in infos:

#             #try:

#                 firstname = info.get('First Name')

               

#                 #foundWord = True

#                 pagesToVisit = pagesToVisit + links
                

#             #except:
#                 print('Page lacking information')
                    

    
        


        
spider()











# In[ ]:




# In[71]:

from urllib.request import urlopen  
from bs4 import BeautifulSoup as bs

def childage(url):
    
    ''' returns a list of the ages of each of the children '''
    rawdata = urlopen(url).read()
    rawdata = rawdata.decode("utf-8")

    soup = bs(rawdata, 'html.parser')

    tables = soup.find_all('table')

    data = tables[3].find_all('td')
    
    data = [d.get_text() for d in data]
    data = [d.strip() for d in data]
    
    agestr = [x for x in data if "years" in x ]
    
    ages = []
    
    for i in range(len(agestr)):
        ages.append([int(s) for s in agestr[i].split() if s.isdigit()])
        
    ages = [ages[i][0] for i in range(len(ages))]
    
    return ages
    
    
       
        
    

    
    
    
    

    #name = dictm.get('Age')

 
    
childage('http://www.whosdatedwho.com/dating/madeleine-astor')





# In[ ]:



