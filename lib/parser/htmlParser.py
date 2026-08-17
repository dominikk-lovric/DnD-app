from html.parser import HTMLParser
import re
import requests


class MyHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.inside_page_content = False
        self.depth = 0
        self.content = []
        self.data_list = []



    def handle_starttag(self, tag, attrs):
        attributes = dict(attrs)

        if tag == "div" and attributes.get("id") == "page-content":
            self.inside_page_content = True
            self.depth = 1
            print("Found page-content")
            return

        if self.inside_page_content and tag == "div":
            self.depth += 1


    def handle_data(self, data):
        if not self.inside_page_content:
            return

        data = data.strip()

        if not data:
            return


        # Start a new feature
        if data.lower().startswith("level"):
            self.data_list.append([])

        # Add data to the current feature
        if self.data_list:
            self.data_list[-1].append(data)


    def handle_endtag(self, tag):
        if self.inside_page_content and tag == "div":
            self.depth -= 1

            if self.depth == 0:
                self.inside_page_content = False



def printDict(dict):
    keys=dict.keys()
    keys=list(keys)
    for key in keys:
        if isinstance(dict[key], int):
            print('\t"'+key+'"'+":",dict[key],end="")
        else:
            print('\t"'+key+'"'+": "+'"'+dict[key]+'"',end="")
        if(key!=keys[len(keys)-1]):
            print(",")
        else:
            print("")

def printList(list):
    for i in  range(len(list)):
        print("{", end="")
        printDict(list[i])
        print("}", end="")
        if(i!=len(list)-1):
            print(",")
        else:
            print("")

def getFeatures(list):
    dataList=list
    features = []
    print("\n" * 3)
    data = []
    for item in dataList:
        name = item[0].split(":")[1].strip()
        matches = re.findall(r'-?\d*\.?\d+', item[0])
        res = [float(x) if '.' in x else int(x) for x in matches]
        level = res[0]
        str = ""
        for i in range(len(item)):
            if (i != 0):
                str = str + item[i]
        data.append(dict(name=name, level=level, description=str))
    printList(data)
    print("\n" * 3)



url = "http://dnd2024.wikidot.com/barbarian:path-of-the-zealot"

response = requests.get(url)

html = response.text

parser=MyHTMLParser()

print(html)

parser.feed(html)

print(parser.data_list)
getFeatures(parser.data_list)