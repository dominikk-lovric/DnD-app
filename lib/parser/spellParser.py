from __future__ import annotations

import argparse
import json
import re
import sys
import time
from encodings import utf_8
from operator import truediv
from textwrap import indent
from typing import Optional

import requests
from bs4 import BeautifulSoup, Tag

BASE_URL = "http://dnd2024.wikidot.com/"


def clean_text(el) -> str:
    text = el.get_text(" ", strip=True)
    text = re.sub(r"\s+([,.;:!?])", r"\1", text)
    text = re.sub(r"\s{2,}", " ", text)
    return text.strip()


def printTabs(outputFile, n):
    print("\t" * n, end="", file=outputFile)


def chkComma(outputFile, i, n):
    if i != n:
        print(', ', end="", file=outputFile)


def printDict(outputFile, item, m, name: Optional[str] = None):
    keys = list(item.keys())
    i = 0
    n = len(keys) - 1
    printTabs(outputFile, m)
    if name is not None:
        print('"' + name + '": ', end="", file=outputFile)
    print("{", file=outputFile)
    for key in keys:
        if isinstance(item[key], dict):
            printDict(outputFile, item[key], m + 1, key)
        elif isinstance(item[key], list):
            printList(outputFile, item[key], m + 1, key)
        elif isinstance(item[key], (int, float)):
            printTabs(outputFile, m + 1)
            print('"' + key + '": ', item[key], end="", file=outputFile)
        else:
            printTabs(outputFile, m + 1)
            print('"' + key + '": ' + '"' + str(item[key]) + '"', end="", file=outputFile)
        print("," if i != n else "", file=outputFile)
        i += 1
    printTabs(outputFile, m)
    print("}", end="", file=outputFile)


def printList(outputFile, item, n, name: Optional[str] = None):
    endEnter = False
    if name is not None:
        printTabs(outputFile, n)
        print('"' + name + '": ', end="", file=outputFile)
    print("[", end="", file=outputFile)
    for i in range(len(item)):
        if isinstance(item[i], dict):
            endEnter = True
            if i == 0:
                print("", file=outputFile)
            printDict(outputFile, item[i], n + 1)
            chkComma(outputFile, i, len(item) - 1)
            print("", file=outputFile)
        elif isinstance(item[i], list):
            printList(outputFile, item[i], n + 1)
            chkComma(outputFile, i, len(item) - 1)
        elif isinstance(item[i], (int, float)):
            print(item[i], end="", file=outputFile)
            chkComma(outputFile, i, len(item) - 1)
        else:
            print('"' + str(item[i]) + '"', end="", file=outputFile)
            chkComma(outputFile, i, len(item) - 1)
    if endEnter:
        printTabs(outputFile, n)
    print("]", end="", file=outputFile)


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

def parseRow(row,level):
    cells=row.find_all(["td", "th"])
    values = [clean_text(c) for c in cells]
    link=cells[0].find("a").get("href")
    name=values[0]
    school=values[1]
    spellList=[c.strip() for c in values[2].split(",")]
    castingTime=["Ritual" if el=="R" else el for el in [el.strip() for el in values[3].split("or")]]
    range=values[4]
    components=[el.strip() for el in values[5].split(",")]
    usesMaterials=False
    needsMaterials=False
    if components[-1]=="M(C)":
        components[-1]="M"
        needsMaterials=True
    elif components[-1]=="M(C*)":
        components[-1]="M"
        needsMaterials=True
        usesMaterials=True
    durationValue=values[6].split(",")
    duration=[]
    concentration=False
    for d in durationValue:
        if d.strip()=="C":
            concentration=True
        elif d.strip()[0].isalpha() and d[0].strip().isupper():
            duration.append(d.strip()[0].upper()+d.strip()[1:])
        else:
            duration.append(d.strip())
    if level==0:
        levelWord="cantrip"
    elif level==1:
        levelWord="1st"
    elif level==2:
        levelWord="2nd"
    elif level==3:
        levelWord="3rd"
    else:
        levelWord=str(level)+"th"
    dict={
        "name": name,
        "Basics":{
            "Level":levelWord,
            "School":school,
            "Spell List":spellList,
            "Casting Time":castingTime,
            "Range":range,
            "Components":components,
            "Duration":duration,
            "Concentration":concentration
        },
        "level":level,
        "json":"assets/json/spells/"+slugify(name)+".json",
        "Icon":{
            "base":"none"
           }
    }
    return link, dict, needsMaterials, usesMaterials

def getSpellDict(link, dict,needsMaterials, usesMaterials):
    soup = fetchSoup(BASE_URL + link)
    name=dict["name"]
    school=dict["Basics"]["School"]
    spellList=dict["Basics"]["Spell List"]
    castingTime=dict["Basics"]["Casting Time"]
    range=dict["Basics"]["Range"]
    components=dict["Basics"]["Components"]
    duration=dict["Basics"]["Duration"]
    concentration=dict["Basics"]["Concentration"]
    content = getPageContent(soup)
    content=[clean_text(el) for el in content.find_all("p")]
    source=re.findall(r'^Source:\s*(.*?)$', content[0])[0]
    level=re.findall(r'\d+', content[1])
    if(len(level)>0):
        level=int(level[0])
    else:
        level=0
    materials=""
    start=2
    if(components[-1]=="M"):
        print(content)
        materials=re.findall(r'.*?Components:\s*.*?M\s*\((.*?)\)', content[1])
        if(materials==[]):
            materials=re.findall(r'.*?Components:\s*.*?M\s*\((.*?)\)', content[2])[0]
            start=3
        else:
            materials=materials[0]
    description=""
    for el in content[3:]:
        description+=el+"\\n"
    finalDict={
        "name":name,
        "level":level,
        "school":school,
        "spellList":spellList,
        "castingTime":castingTime,
        "range":range,
        "components":components,
        "materials":materials,
        "duration":duration,
        "concentration":concentration,
        "description":description,
    }
    if needsMaterials:
        finalDict["needsMaterials"]=needsMaterials
    if usesMaterials:
        finalDict["usesMaterials"]=usesMaterials
    return finalDict



def parseTable(table):


    i=0
    level=0
    mainDict={}
    for row in table:
        if clean_text(row)!="Name School Spell lists Casting Time Range Components Duration":
            link, dict, needsMaterials, usesMaterials=parseRow(row, level-1)
            mainDict["s"+str(i)]=dict
            i+=1
            print("- assets/json/spells/"+slugify(dict["name"])+".json")
        else:
            level+=1
    with open("../dnd_app/assets/json/spells.json", "w", encoding="utf_8") as f:
        json.dump(mainDict, f, indent=2, ensure_ascii=False)
        i+=1



def main():
    soup=fetchSoup(BASE_URL+"spell:all")
    content= getPageContent(soup)
    table=content.find_all("tr")
    parseTable(table)


if __name__ == "__main__":
    main()