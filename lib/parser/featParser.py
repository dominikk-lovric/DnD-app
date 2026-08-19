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
    # print(words)
    str=""
    for i in range(len(words)):
        if(i!=0):
            str=str+" "
        str=str+(words[i][0].upper()+words[i][1:])
    return str


TYPE_MAP = {
    "Origin Feats": "Origin Feat",
    "General Feats": "General Feat",
    "Fighting Style Feats": "Fighting Style Feat",
    "Epic Boon Feats": "Epic Boon Feat",
    "Dragonmark Feats": "Dragonmark Feat",
}


def make_feat_type_dict(content: Tag) -> dict[str, str]:
    feat_types = {}
    current_type = None

    for element in content.find_all(["h1", "h2", "a"]):

        if element.name in ("h1", "h2"):
            heading = element.get_text(" ", strip=True)

            if heading in TYPE_MAP:
                current_type = TYPE_MAP[heading]

        elif element.name == "a":
            href = element.get("href", "")

            if href.startswith("/feat:") and current_type:
                slug = href.removeprefix("/feat:")
                feat_types[slug] = current_type

    return feat_types


featDict={'alert': 'Origin Feat', 'crafter': 'Origin Feat', 'healer': 'Origin Feat', 'lucky': 'Origin Feat', 'magic-initiate': 'Origin Feat', 'musician': 'Origin Feat', 'savage-attacker': 'Origin Feat', 'sharp-eye': 'Origin Feat', 'skilled': 'Origin Feat', 'survivor': 'Origin Feat', 'tavern-brawler': 'Origin Feat', 'tough': 'Origin Feat', 'cult-of-the-dragon-initiate': 'Origin Feat', 'emerald-enclave-fledgling': 'Origin Feat', 'harper-agent': 'Origin Feat', 'lords-alliance-agent': 'Origin Feat', 'purple-dragon-rook': 'Origin Feat', 'spellfire-spark': 'Origin Feat', 'tyro-of-the-gauntlet': 'Origin Feat', 'zhentarim-ruffian': 'Origin Feat', 'child-of-the-sun': 'Origin Feat', 'shadowmoor-hexer': 'Origin Feat', 'tireless-reveler': 'Origin Feat', 'vampire-hunter': 'Origin Feat', 'vampire-s-plaything': 'Origin Feat', 'ability-score-improvement': 'General Feat', 'actor': 'General Feat', 'athlete': 'General Feat', 'charger': 'General Feat', 'chef': 'General Feat', 'crossbow-expert': 'General Feat', 'crusher': 'General Feat', 'defensive-duelist': 'General Feat', 'dual-wielder': 'General Feat', 'durable': 'General Feat', 'elemental-adept': 'General Feat', 'fey-touched': 'General Feat', 'grappler': 'General Feat', 'great-weapon-master': 'General Feat', 'heavily-armored': 'General Feat', 'heavy-armor-master': 'General Feat', 'inspiring-leader': 'General Feat', 'keen-mind': 'General Feat', 'lightly-armored': 'General Feat', 'mage-slayer': 'General Feat', 'martial-weapon-training': 'General Feat', 'medium-armor-master': 'General Feat', 'moderately-armored': 'General Feat', 'mounted-combatant': 'General Feat', 'observant': 'General Feat', 'piercer': 'General Feat', 'poisoner': 'General Feat', 'polearm-master': 'General Feat', 'resilient': 'General Feat', 'ritual-caster': 'General Feat', 'sentinel': 'General Feat', 'shadow-touched': 'General Feat', 'sharpshooter': 'General Feat', 'shield-master': 'General Feat', 'shifting-combatant': 'General Feat', 'skill-expert': 'General Feat', 'skulker': 'General Feat', 'slasher': 'General Feat', 'speedy': 'General Feat', 'spell-sniper': 'General Feat', 'tactical-combatant': 'General Feat', 'telekinetic': 'General Feat', 'telepathic': 'General Feat', 'war-caster': 'General Feat', 'weapon-master': 'General Feat', 'cold-caster': 'General Feat', 'dragonscarred': 'General Feat', 'enclave-magic': 'General Feat', 'fairy-trickster': 'General Feat', 'genie-magic': 'General Feat', 'harper-teamwork': 'General Feat', 'lordly-resolve': 'General Feat', 'mythal-touched': 'General Feat', 'order-s-resilience': 'General Feat', 'purple-dragon-commandant': 'General Feat', 'spellfire-adept': 'General Feat', 'street-justice': 'General Feat', 'zhentarim-tactics': 'General Feat', 'bloodlust': 'General Feat', 'bomber': 'General Feat', 'cloying-mists': 'General Feat', 'delicious-pain': 'General Feat', 'light-bringer': 'General Feat', 'love-bites': 'General Feat', 'putrefy': 'General Feat', 'rebuke': 'General Feat', 'treacherous-allure': 'General Feat', 'vampire-touched': 'General Feat', 'archery': 'Fighting Style Feat', 'blind-fighting': 'Fighting Style Feat', 'defense': 'Fighting Style Feat', 'dueling': 'Fighting Style Feat', 'great-weapon-fighting': 'Fighting Style Feat', 'interception': 'Fighting Style Feat', 'pack-fighting': 'Fighting Style Feat', 'prone-fighting': 'Fighting Style Feat', 'protection': 'Fighting Style Feat', 'thrown-weapon-fighting': 'Fighting Style Feat', 'two-weapon-fighting': 'Fighting Style Feat', 'unarmed-fighting': 'Fighting Style Feat', 'boon-of-combat-prowess': 'Epic Boon Feat', 'boon-of-dimensional-travel': 'Epic Boon Feat', 'boon-of-energy-resistance': 'Epic Boon Feat', 'boon-of-fate': 'Epic Boon Feat', 'boon-of-fortitude': 'Epic Boon Feat', 'boon-of-irresistible-offense': 'Epic Boon Feat', 'boon-of-recovery': 'Epic Boon Feat', 'boon-of-skill': 'Epic Boon Feat', 'boon-of-speed': 'Epic Boon Feat', 'boon-of-spell-recall': 'Epic Boon Feat', 'boon-of-the-night-spirit': 'Epic Boon Feat', 'boon-of-truesight': 'Epic Boon Feat', 'boon-of-siberys': 'Epic Boon Feat', 'boon-of-bloodshed': 'Epic Boon Feat', 'boon-of-bountiful-health': 'Epic Boon Feat', 'boon-of-communication': 'Epic Boon Feat', 'boon-of-desperate-resilience': 'Epic Boon Feat', 'boon-of-exquisite-radiance': 'Epic Boon Feat', 'boon-of-fluid-forms': 'Epic Boon Feat', 'boon-of-fortune-s-favor': 'Epic Boon Feat', 'boon-of-poison-mastery': 'Epic Boon Feat', 'boon-of-revelry': 'Epic Boon Feat', 'boon-of-terror': 'Epic Boon Feat', 'boon-of-the-bright-sun': 'Epic Boon Feat', 'boon-of-the-furious-storm': 'Epic Boon Feat', 'boon-of-the-soul-drinker': 'Epic Boon Feat', 'boon-of-blazing-dawn': 'Epic Boon Feat', 'boon-of-looming-shadows': 'Epic Boon Feat', 'boon-of-misty-escape': 'Epic Boon Feat', 'aberrant-dragonmark': 'Dragonmark Feat', 'mark-of-detection': 'Dragonmark Feat', 'mark-of-finding': 'Dragonmark Feat', 'mark-of-handling': 'Dragonmark Feat', 'mark-of-healing': 'Dragonmark Feat', 'mark-of-hospitality': 'Dragonmark Feat', 'mark-of-making': 'Dragonmark Feat', 'mark-of-passage': 'Dragonmark Feat', 'mark-of-scribing': 'Dragonmark Feat', 'mark-of-sentinel': 'Dragonmark Feat', 'mark-of-shadow': 'Dragonmark Feat', 'mark-of-storm': 'Dragonmark Feat', 'mark-of-warding': 'Dragonmark Feat', 'greater-aberrant-mark': 'Dragonmark Feat', 'greater-mark-of-detection': 'Dragonmark Feat', 'greater-mark-of-finding': 'Dragonmark Feat', 'greater-mark-of-handling': 'Dragonmark Feat', 'greater-mark-of-healing': 'Dragonmark Feat', 'greater-mark-of-hospitality': 'Dragonmark Feat', 'greater-mark-of-making': 'Dragonmark Feat', 'greater-mark-of-passage': 'Dragonmark Feat', 'greater-mark-of-scribing': 'Dragonmark Feat', 'greater-mark-of-sentinel': 'Dragonmark Feat', 'greater-mark-of-shadow': 'Dragonmark Feat', 'greater-mark-of-storm': 'Dragonmark Feat', 'greater-mark-of-warding': 'Dragonmark Feat', 'potent-dragonmark': 'Dragonmark Feat', 'fey-pact': 'Dragonmark Feat', 'infernal-pact': 'Dragonmark Feat', 'fey-sentinel': 'Dragonmark Feat', 'fey-tormentor': 'Dragonmark Feat', 'infernal-bulwark': 'Dragonmark Feat', 'infernal-dragoon': 'Dragonmark Feat', 'aberrant-anatomy': 'Dragonmark Feat', 'echoing-soul': 'Dragonmark Feat', 'gathered-whispers': 'Dragonmark Feat', 'living-shadow': 'Dragonmark Feat', 'mist-walker': 'Dragonmark Feat', 'second-skin': 'Dragonmark Feat', 'symbiotic-being': 'Dragonmark Feat', 'touch-of-death': 'Dragonmark Feat', 'watchers': 'Dragonmark Feat'}


def main():
    soup = fetchSoup("http://dnd2024.wikidot.com/feat:all")
    content = getPageContent(soup)
    relevant = ["a"]
    linkList = []
    elements = [el for el in content.find_all(relevant, recursive=True)]
    for el in elements:
        link = el.get("href")
        if (link.startswith("/feat:")):
            list = re.findall(r'^/feat:(.*)$', link)
            linkList.append(list[0])
    print(linkList)
    for i in range(3):
        if(i==0):
            link = linkList[13]
        if(i==1):
            link=linkList[1]
        if(i==2):
            link=linkList[80]
        soup = fetchSoup("http://dnd2024.wikidot.com/feat:"+link)
        content = getPageContent(soup)
        print("/////////////////////////////////////////////////////////////////////////////////////////////////")
        print(link)
        print(featDict[link])
        print("/////////////////////////////////////////////////////////////////////////////////////////////////")
        print(content)

if __name__ == "__main__":
    main()