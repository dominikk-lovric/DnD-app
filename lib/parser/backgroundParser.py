from __future__ import annotations

import argparse
import json
import re
import sys
import time
from pyexpat import features
from typing import Optional

import requests
from bs4 import BeautifulSoup, Tag

BASE_URL = "http://dnd2024.wikidot.com/"

def clean_text(el):
    return el.get_text(" ", strip=True)


def printTabs(outputFile, n):
    print("\t"*n,end="", file=outputFile)

def chkComma(outputFile, i, n):
    if i != n:
        print(', ', end="", file=outputFile)

def printDict(outputFile, item, m, name:Optional[str]=None):
    keys=item.keys()
    keys=list(keys)
    i=0
    n=len(keys)-1
    printTabs(outputFile, m)
    if name is not None:
        print('"'+name+'": ', end="", file=outputFile)
    print("{", file=outputFile)
    for key in keys:
        if isinstance(item[key], dict):
            printDict(outputFile, item[key],m+1, key)
        elif isinstance(item[key], list):
            printList(outputFile, item[key],m+1,key)
        elif isinstance(item[key], int) or isinstance(item[key], float):
            printTabs(outputFile, m + 1)
            print('"'+key+'": ',item[key], end="", file=outputFile)
        else:
            printTabs(outputFile, m + 1)
            print('"'+key+'": '+'"'+item[key]+'"',end="", file=outputFile)
        if(i!=n):
            print(",", file=outputFile)
        else:
            print("", file=outputFile)
        i+=1
    printTabs(outputFile, m)
    print("}",end="", file=outputFile)

def printList(outputFile, item, n, name:Optional[str]=None):
    endEnter=False
    if name is not None:
        printTabs(outputFile, n)
        print('"'+name+'": ', end="", file=outputFile)
    print("[", end="", file=outputFile)
    for i in  range(len(item)):
        if isinstance(item[i], dict):
            endEnter=True
            if i==0:
                print("", file=outputFile)
            printDict(outputFile, item[i],n+1)
            chkComma(outputFile, i, len(item)-1)
            print("", file=outputFile)
        elif isinstance(item[i], list):
            printList(outputFile, item[i],n+1)
            chkComma(outputFile, i, len(item)-1)
        elif isinstance(item[i], int) or isinstance(item[i], float):
            print(item[i],end="", file=outputFile)
            chkComma(outputFile, i, len(item)-1)
        else:
            print('"'+item[i]+'"',end="", file=outputFile)
            chkComma(outputFile, i, len(item)-1)
    if endEnter:
        printTabs(outputFile, n)
    print("]",end="", file=outputFile)

def fetchSoup(url):
    page = requests.get(url)
    page.raise_for_status()
    soup = BeautifulSoup(page.content, 'html.parser')
    return soup

def getPageTitle(soup):
    title = soup.find(id="page-title")
    if title is None:
        return ""
    return title.get_text(strip=True)

def getPageContent(soup: BeautifulSoup) -> Tag:
    pageContent=soup.find(id="page-content")
    if pageContent is None:
        return ""
    return pageContent

def slugify(name):
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")

def is_page_tags_marker(el):
    a_tags = el.find_all("a") if el.name != "a" else [el]
    return any("page-tags" in (a.get("href") or "") for a in a_tags)

def splitOrList(text: str) -> list[str]:
    text = text.rstrip(".").strip()
    parts = re.split(r",\s*or\s+|,\s*|\s+or\s+", text)
    return [p.strip() for p in parts if p.strip()]

def parseStartingItems(text):
    items = re.findall(r'\([AB]\)\s*(.*?)(?=;\s*or\s*\([AB]\)|$)', text)
    for i in range(len(items)):
        items[i]=items[i].split(",")
        for j in range(len(items[i])):
            items[i][j]=items[i][j].strip()
    return items

def getShort(abilities):
    new=[]
    for ability in abilities:
        if ability=="Strength":
            new.append("Str")
        if ability=="Dexterity":
            new.append("Dex")
        if ability=="Constitution":
            new.append("Con")
        if ability=="Intelligence":
            new.append("Int")
        if ability=="Wisdom":
            new.append("Wis")
        if ability=="Charisma":
            new.append("Cha")
    return new

def unSlug(str):
    words = str.split("-")
    print(words)
    str=""
    for i in range(len(words)):
        if(i!=0):
            str=str+" "
        str=str+(words[i][0].upper()+words[i][1:])
    return str

def main():
    soup=fetchSoup("http://dnd2024.wikidot.com/background:all")
    content=getPageContent(soup)
    relevant=["a"]
    linkList=[]
    elements= [el for el in content.find_all(relevant, recursive=True)]
    for el in elements:
        link=el.get("href")
        if(link.startswith("/background:")):
            list=re.findall(r'^/background:(.*)$', link)
            linkList.append(list[0])
    print(linkList)
    allBackgrounds={}

    for item in linkList:
        print("- assets/json/backgrounds/"+slugify(str(item))+".json")
        '''
    for i in range(len(linkList)):
        link = BASE_URL + "background:" + linkList[i]
        print(link)
        soup = fetchSoup(link)
        content = getPageContent(soup)
        text = content.get_text("\n", strip=True)
        print(text)
        textList = text.split("\n")
        sourceList = re.search(r'^Source:\s*(.*)$', textList[0])
        source = sourceList.group(1)
        type = ""
        if( source.startswith("Player's Handbook") or source.startswith("D&D Beyond Drops - May 2026")):
            description = textList[1]
            abilities = [x.strip() for x in textList[3].split(",")]
            feat = textList[5]
            if feat.startswith("Magic Initiate"):
                find = re.search(r'Magic\s*Initiate\s*\((.*)\)', feat)
                feat = "Magic Initiate"
                type=  find.group(1)
            skills = textList[7].split(" and ")
            k=0
            if(textList[9].startswith("Choose one kind of")):
                k=1
            tools = textList[9+k]
            equipment = parseStartingItems(textList[11+k])
        else:
            abilities = [x.strip() for x in textList[2].split(",")]
            feat = textList[4]
            h=0
            type=""
            if feat.startswith("Magic Initiate"):
                find = re.search(r'\((.*)\)', textList[5])
                h=1
                feat  = "Magic Initiate"
                type= find.group(1)
            skills = textList[6+h].split(" and ")
            if (textList[8+h].startswith("Choose one kind of")):
                tools=textList[8+h].strip("Choose one kind of ")
            else:
                tools = textList[8+h]
            equipment = parseStartingItems(textList[10+h])
            description=textList[10 + k+h]

        name=unSlug(str(linkList[i]))
        print(name)
        print(source)
        print(description)
        print(abilities)
        print(feat)
        print(skills)
        print(tools)
        print(equipment)
        print("BG: "+linkList[i].lower()+" done, "+str(i)+"/"+str(len(linkList)))
        print()
        print()
        print()
        allBackgrounds["bg"+str(i)]={
            "name":name,
            "Basics":{
                "source": source,
                "abilities": getShort(abilities),
                "feat": feat
            },
            "Icon":{
                "base":"none"
            },
            "json":"assets/json/backgrounds/"+slugify(str(linkList[i]))+".json"
        }
        tj={
            "name":name,
            "catId":"background",
            "description":description,
            "abilities":getShort(abilities),
            "feat":[
                {
                    "name": feat,
                    "path": "assets/json/feats/" + slugify(str(feat))
                }
            ],
            "skills":skills,
            "tools":tools,
            "equipment":equipment
        }
        if(type!=""):
            tj["feat"][0]["type"]=type

       # with open("../dnd_app/assets/json/backgrounds/"+str(linkList[i])+".json", "w") as outputFile:
        #    printDict(outputFile, tj, 0)
'''

if __name__ == "__main__":
    main()