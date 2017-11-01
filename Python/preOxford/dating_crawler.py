from HTMLParser import HTMLParser  
import urllib2  
import urlparse as parse
import urllib
from BeautifulSoup import *

class LinkParser(HTMLParser):

   
    def handle_starttag(self, tag, attrs):
        
        if tag == 'a':
            for (key, value) in attrs:
                if key == 'href':
                    newUrl = parse.urljoin(self.baseUrl, value)
                    # add it to colection of links:
                    self.links = self.links + [newUrl]

   
    def getLinks(self, url):
        self.links = []

        self.baseUrl = url

        response = urllib.urlopen(url)
        
        html = response.read()
        soup = BeautifulSoup(html)
        tags = soup('a')
       
    
        try:
        
            hrefs = [tag.get('href', None) for tag in tags]
            htmlBytes = response.read()
            
            
            htmlString = htmlBytes.decode("utf-8")
            self.feed(htmlString)
            return htmlString, self.links
        except:
            print 'not valid cunt'


def spider(url, word, maxPages):  
    pagesToVisit = [url]
    numberVisited = 0
    foundWord = False

    while numberVisited < maxPages and pagesToVisit != [] and not foundWord:
        numberVisited = numberVisited +1
      
        url = pagesToVisit[0]
        pagesToVisit = pagesToVisit[1:]
        #try:
        print(numberVisited, "Visiting:", url)
        parser = LinkParser()
        data, links = parser.getLinks(url)
        if data.find(word)>-1:
            foundWord = True
            
            pagesToVisit = pagesToVisit + links
            print(" **Success!**")
        #except:
        #    print(" **Failed!**")
    if foundWord:
        print("The word", word, "was found at", url)
    else:
        print("Word never found")
        
spider('http://www.whosdatedwho.com/', 'a', 2000)