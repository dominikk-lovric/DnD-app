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

BASE_URL = "http://dnd2024.wikidot.com"
CLASS_LIST_URL = f"{BASE_URL}/class:all"
HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; dnd2024-json-export/1.0)"}
REQUEST_DELAY = 0.3

ABILITY_ABBR = {
    "strength": "Str", "dexterity": "Dex", "constitution": "Con",
    "intelligence": "Int", "wisdom": "Wis", "charisma": "Cha",
}

LEVEL_HEADER_RE = re.compile(r"^\s*Level\s+(\d+)\s*:\s*(.+?)\s*$", re.IGNORECASE)

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

def computeAttacksPerLevel(features):
    result = {"1": 1}
    count = 1
    for feat in sorted(features, key=lambda f: f["level"]):
        if "extra attack" in feat["name"].strip().lower():
            count += 1
            result[str(feat["level"])] = count
    print(result)
    attacks=[]
    num=0
    keys=result.keys()
    keys=list(keys)
    for i in range(20):
        for key in keys:
            if int(key)==i+1:
                num+=1
        attacks.append(num)
    return attacks

def parseTable(table):
    rows = table.find_all("tr")
    if not rows:
        return "unknown", rows
    header_cells = rows[0].find_all(["th", "td"])
    header_texts = [clean_text(c) for c in header_cells]
    if header_texts and "level" in header_texts[0].strip().lower():
        return "progression", rows
    if len(header_texts) == 1 and header_texts[0].strip().lower() == "name":
        return "subclass", rows
    return "traits", rows

def parseTraits(rows):
    traits={}
    for row in rows[1:]:
        cells = row.find_all(["th", "td"])
        if len(cells) >= 2:
            key = clean_text(cells[0])
            value = clean_text(cells[1])
            traits[key] = value
    return traits

def parseProgression(rows):
    items=[]
    n=len(rows[0])
    firstRow= rows[0]
    a=0
    cells = firstRow.find_all(["th", "td"])
    for cell in cells:
        if "level" in clean_text(cell).lower() or "proficiency bonus" in clean_text(cell).lower() or "features" in clean_text(cell).lower():
            a+=1
        else:
            items.append(
                {
                    "name":clean_text(cell),
                    "value":[]
                }
            )
    for row in rows[1:]:
        cells = row.find_all(["th", "td"])
        for i, cell in enumerate(cells[a:]):
            celltext=clean_text(cell)
            if celltext=="-":
                items[i]["value"].append(0)
            else:
                try:
                    cellnum=int(celltext)
                    items[i]["value"].append(cellnum)
                except:
                    items[i]["value"].append(celltext)
    spells={}
    progression=[]
    for i in range(len(items)):
        if (len(items[i]["name"])==3 and items[i]["name"][0].isdigit())or items[i]["name"].lower()=="cantrips" or items[i]["name"].lower()=="prepared spells" or items[i]["name"].lower()=="spell slots" or items[i]["name"].lower()=="slot level" or items[i]["name"].lower()=="sorcery points":
            spells[items[i]["name"]]=items[i]["value"]
        else:
            progression.append(items[i])
    return progression, spells


def parseSubclass(rows, base_url):
    out = []
    for row in rows[1:]:
        link = row.find("a")
        if link and link.get("href"):
            name = clean_text(link)
            href = link["href"]
            if href.startswith("/"):
                href = base_url.rstrip("/") + href
            elif not href.startswith("http"):
                href = base_url.rstrip("/") + "/" + href
            out.append((name, href))
    return out

def is_page_tags_marker(el):
    a_tags = el.find_all("a") if el.name != "a" else [el]
    return any("page-tags" in (a.get("href") or "") for a in a_tags)

def getInfoFromSite(content, url):
    traits={}
    features:list=[]
    archetypeLinks=[]
    progression=[]
    spells={}
    feature: Optional[dict] = None


    relevantTags = ["h1", "h2", "h3", "h4", "h5", "h6", "p", "ul", "ol", "table"]

    elements = [el for el in content.find_all(relevantTags, recursive=True)
                if el.find_parent("table") is None]
    n=len(elements)

    i=0
    while i<n:
        el=elements[i]

        if el.name=="table":
            type, tableRows= parseTable(el)
            if type=="traits":
                traits.update(parseTraits(tableRows))
            elif type=="progression":
                p,spells=parseProgression(tableRows)
                progression=progression+p
                progression=[f for f in progression if f]
            elif type=="subclass":
                archetypeLinks=parseSubclass(tableRows, BASE_URL)
            i+=1
            continue

        if el.name == "p" and is_page_tags_marker(el):
            break

        if el.name.startswith("h") and len(el.name)==2:
            text=clean_text(el)
            m=LEVEL_HEADER_RE.match(text)
            if el.name=="h3" and m:
                feature={"name":m.group(2),"level":int(m.group(1)), "description":[]}
                features.append(feature)
                i+=1
                continue
            nextTable = (i + 1 < n and elements[i + 1].name == "table")
            if feature is not None and text and not nextTable:
                feature["description"].append(text)
            i+=1
            continue

        if el.name in ("ul", "ol"):
            if feature is not None:
                for li in el.find_all("li", recursive=False):
                    txt = clean_text(li)
                    if txt:
                        feature["description"].append(txt)
            i += 1
            continue

        if el.name == "p":
            txt = clean_text(el)
            if feature is not None and txt:
                feature["description"].append(txt)
            i += 1
            continue

        i += 1

    for f in features:
        f["description"]=" ".join(f["description"])

    return traits, features, progression, spells, archetypeLinks

def splitOrList(text: str) -> list[str]:
    text = text.rstrip(".").strip()
    parts = re.split(r",\s*or\s+|,\s*|\s+or\s+", text)
    return [p.strip() for p in parts if p.strip()]

def parseSkillChoice(text):
    m = re.search(r"Choose\s+(\d+)\s*:\s*(.+)", text, re.IGNORECASE)
    if not m:
        return None, splitOrList(text)
    return int(m.group(1)), splitOrList(m.group(2))

def parseWeaponProficiencies(text):
    text=text.strip()
    if text.lower() == "none":
        return []
    text = re.sub(r"\s+weapons?\s*$", "", text, flags=re.IGNORECASE)
    parts = re.split(r",\s*and\s+|,\s*|\s+and\s*", text)
    return [p.strip() for p in parts if p.strip()]

def parseArmorProficiencies(text: str) -> list[str]:
    text = text.strip()
    if text.lower() == "none":
        return []
    out = []
    for kw in ("Light", "Medium", "Heavy"):
        if re.search(rf"\b{kw}\b", text, re.IGNORECASE):
            out.append(kw)
    if re.search(r"\bShields?\b", text, re.IGNORECASE):
        out.append("Shields")
    return out

def parseStartingItems(text):
    items = re.findall(r'\([AB]\)\s*(.*?)(?=;\s*or\s*\([AB]\)|$)', text)
    for i in range(len(items)):
        items[i]=items[i].split(",")
        for j in range(len(items[i])):
            items[i][j]=items[i][j].strip()
    return items

def getCasterLevel(progression):
    casterLevel=0
    for item in progression:
        if "1st" in item:
            casterLevel=0.5
        if "6th" in item:
            casterLevel=1
    return casterLevel

def detectSpellcastingAbility(features):
    for feat in features:
        m = re.search(
            r"\b(Intelligence|Wisdom|Charisma)\b\s+is your spellcasting ability",
            feat["description"],
        )
        if m:
            return ABILITY_ABBR[m.group(1).lower()]
    return "Int"


def parseHitDie(text):
    m = re.search(r"[Dd](\d+)", text)
    return f"d{m.group(1)}" if m else text


def parseSavingThrows(text):
    parts = re.split(r",\s*and\s+|,\s*|\s+and\s+", text.strip())
    out = []
    for p in parts:
        key = p.strip().lower()
        if key in ABILITY_ABBR:
            out.append(ABILITY_ABBR[key])
    return out


def parseSubclassPage(sub_url, name_hint):
    soup = fetchSoup(sub_url)
    content = getPageContent(soup)


    if content is None:
        raise ValueError(
            f"Could not find page content for {sub_url}"
        )

    traits, features, progression, spells, subclass_links = (
        getInfoFromSite(content, BASE_URL)
    )

    attacks=computeAttacksPerLevel(features)

    name = name_hint or getPageTitle(soup)
    return {
        "name": name,
        "traits": traits,
        **({"spells": spells if "1st" in spells else {}}),
        "progression": progression,
        **({"attacksPerLevel": attacks if len(attacks) > 1 else {}}),
        "features": [
            {
                "name": f["name"],
                "level": f["level"],
                "description": f["description"],
            }
            for f in features
        ],
    }




def parseClassPage(name, url, id, fetchSubclasses=True):
    soup=fetchSoup(url)
    content=getPageContent(soup)
    slug=slugify(name)
    traits, features, progression, spells, archetypeLinks = getInfoFromSite(content, BASE_URL)

    proficiencies = []
    if "Skill Proficiencies" in traits:
        options, skills = parseSkillChoice(traits["Skill Proficiencies"])
        entry = {"name": "Skill", "proficiencies": skills}
        if options is not None:
            entry = {"name": "Skill", "options": options, "proficiencies": skills}
        proficiencies.append(entry)
    if "Armor Training" in traits:
        proficiencies.append({"name": "Armor", "proficiencies": parseArmorProficiencies(traits["Armor Training"])})
    if "Weapon Proficiencies" in traits:
        proficiencies.append({"name": "Weapon", "proficiencies": parseWeaponProficiencies(traits["Weapon Proficiencies"])})
    if "Tool Proficiencies" in traits:
        proficiencies.append({"name": "Tool", "proficiencies": splitOrList(traits["Tool Proficiencies"])})

    startingItems=[]
    if "Starting Equipment" in traits:
        startingItems = parseStartingItems(traits["Starting Equipment"])

    k=0
    for f in features:
        j=0;
        for p in progression:
            if f["name"].strip().lower() in p["name"].strip().lower():
                features[k]["value"]=p["value"]
                progression.pop(j)
                break
            j+=1
        k+=1

    class_json = {
        "id": f"c{id}",
        "catId": "class",
        "name": name,
        "icon": {"base": f"assets/icons/base/classes/{slug}.jpg"},
        "hitDie": parseHitDie(traits.get("Hit Point Die", "")),
        "savingThrows": parseSavingThrows(traits.get("Saving Throw Proficiencies", "")),
        "casterLevel": getCasterLevel(progression),
        "spellcastingAbility": detectSpellcastingAbility(features),
        "spells":spells,
        "attacksPerLevel": computeAttacksPerLevel(features),
        "proficiencies": proficiencies,
        "startingEquipment": startingItems,
        "progression" : progression,
        "features": [
            {
                "name": f["name"],
                "level": f["level"],
                "description": f["description"],
                **({"value": f["value"]} if "value" in f else {}),
            }
            for f in features
        ],
        "archetypes": [],
    }

    if fetchSubclasses:
        seen_urls = set()
        for sub_name, sub_url in archetypeLinks:
            if sub_url in seen_urls:
                continue
            seen_urls.add(sub_url)
            time.sleep(REQUEST_DELAY)
            try:
                class_json["archetypes"].append(parseSubclassPage(sub_url, name_hint=sub_name))
            except Exception as exc:  # noqa: BLE001
                print(f"  ! failed to parse subclass {sub_name} ({sub_url}): {exc}", file=sys.stderr)

    return class_json

def discover_core_classes() -> list[tuple[str, str]]:
    soup = fetchSoup(CLASS_LIST_URL)
    pc = getPageContent(soup)
    out = []
    for a in pc.find_all("a"):
        href = a.get("href") or ""
        if href.rstrip("/").endswith(":main"):
            name = clean_text(a)
            url = href if href.startswith("http") else BASE_URL + href
            out.append((name, url))
    return out

def findUrl(classes, inputCLass):
    for Class, (name, url) in enumerate(classes, start=1):
        if name.strip().lower()==inputCLass.strip().lower():
            return url

def main():
    classes=discover_core_classes()

    i=1
    for inputClass in ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard"]:

        classUrl=findUrl(classes, inputClass)
        classJson= parseClassPage(inputClass, classUrl, i)


        with open("../assets/json/classes/"+inputClass.lower()+".json", "w") as outputFile:
            printDict(outputFile, classJson,0)

        print("DONE: "+inputClass.lower())
        i+=1

if __name__ == "__main__":
    main()