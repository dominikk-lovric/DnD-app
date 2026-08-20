from __future__ import annotations

import argparse
import json
import re
import sys
import time
from textwrap import indent
from typing import Optional

import requests
from bs4 import BeautifulSoup, Tag

BASE_URL = "http://dnd2024.wikidot.com/"


def clean_text(el) -> str:
    """get_text with a separator, plus cleanup of the 'space before punctuation'
    artifact that get_text(separator=' ') introduces when tags sit next to
    commas/periods (e.g. 'Cleric , Druid' -> 'Cleric, Druid')."""
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


def fetchSoup(session: requests.Session, url: str) -> BeautifulSoup:
    page = session.get(url, timeout=15)
    page.raise_for_status()
    return BeautifulSoup(page.content, "html.parser")


def getPageTitle(soup):
    title = soup.find(id="page-title")
    if title is None:
        return ""
    return title.get_text(strip=True)


def getPageContent(soup: BeautifulSoup) -> Optional[Tag]:
    pageContent = soup.find(id="page-content")
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
        items[i] = items[i].split(",")
        for j in range(len(items[i])):
            items[i][j] = items[i][j].strip()
    return items


def getShort(abilities):
    mapping = {
        "Strength": "Str", "Dexterity": "Dex", "Constitution": "Con",
        "Intelligence": "Int", "Wisdom": "Wis", "Charisma": "Cha",
    }
    return [mapping[a] for a in abilities if a in mapping]


def unSlug(s: str) -> str:
    words = s.split("-")
    return " ".join(w[0].upper() + w[1:] if w else w for w in words)


TYPE_MAP = {
    "Origin Feats": "Origin Feat",
    "General Feats": "General Feat",
    "Fighting Style Feats": "Fighting Style Feat",
    "Epic Boon Feats": "Epic Boon Feat",
    "Dragonmark Feats": "Dragonmark Feat",
}


def makeFeatTypeDict(content):
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


featDict = {'alert': 'Origin Feat', 'crafter': 'Origin Feat', 'healer': 'Origin Feat', 'lucky': 'Origin Feat', 'magic-initiate': 'Origin Feat', 'musician': 'Origin Feat', 'savage-attacker': 'Origin Feat', 'sharp-eye': 'Origin Feat', 'skilled': 'Origin Feat', 'survivor': 'Origin Feat', 'tavern-brawler': 'Origin Feat', 'tough': 'Origin Feat', 'cult-of-the-dragon-initiate': 'Origin Feat', 'emerald-enclave-fledgling': 'Origin Feat', 'harper-agent': 'Origin Feat', 'lords-alliance-agent': 'Origin Feat', 'purple-dragon-rook': 'Origin Feat', 'spellfire-spark': 'Origin Feat', 'tyro-of-the-gauntlet': 'Origin Feat', 'zhentarim-ruffian': 'Origin Feat', 'child-of-the-sun': 'Origin Feat', 'shadowmoor-hexer': 'Origin Feat', 'tireless-reveler': 'Origin Feat', 'vampire-hunter': 'Origin Feat', 'vampire-s-plaything': 'Origin Feat', 'ability-score-improvement': 'General Feat', 'actor': 'General Feat', 'athlete': 'General Feat', 'charger': 'General Feat', 'chef': 'General Feat', 'crossbow-expert': 'General Feat', 'crusher': 'General Feat', 'defensive-duelist': 'General Feat', 'dual-wielder': 'General Feat', 'durable': 'General Feat', 'elemental-adept': 'General Feat', 'fey-touched': 'General Feat', 'grappler': 'General Feat', 'great-weapon-master': 'General Feat', 'heavily-armored': 'General Feat', 'heavy-armor-master': 'General Feat', 'inspiring-leader': 'General Feat', 'keen-mind': 'General Feat', 'lightly-armored': 'General Feat', 'mage-slayer': 'General Feat', 'martial-weapon-training': 'General Feat', 'medium-armor-master': 'General Feat', 'moderately-armored': 'General Feat', 'mounted-combatant': 'General Feat', 'observant': 'General Feat', 'piercer': 'General Feat', 'poisoner': 'General Feat', 'polearm-master': 'General Feat', 'resilient': 'General Feat', 'ritual-caster': 'General Feat', 'sentinel': 'General Feat', 'shadow-touched': 'General Feat', 'sharpshooter': 'General Feat', 'shield-master': 'General Feat', 'shifting-combatant': 'General Feat', 'skill-expert': 'General Feat', 'skulker': 'General Feat', 'slasher': 'General Feat', 'speedy': 'General Feat', 'spell-sniper': 'General Feat', 'tactical-combatant': 'General Feat', 'telekinetic': 'General Feat', 'telepathic': 'General Feat', 'war-caster': 'General Feat', 'weapon-master': 'General Feat', 'cold-caster': 'General Feat', 'dragonscarred': 'General Feat', 'enclave-magic': 'General Feat', 'fairy-trickster': 'General Feat', 'genie-magic': 'General Feat', 'harper-teamwork': 'General Feat', 'lordly-resolve': 'General Feat', 'mythal-touched': 'General Feat', 'order-s-resilience': 'General Feat', 'purple-dragon-commandant': 'General Feat', 'spellfire-adept': 'General Feat', 'street-justice': 'General Feat', 'zhentarim-tactics': 'General Feat', 'bloodlust': 'General Feat', 'bomber': 'General Feat', 'cloying-mists': 'General Feat', 'delicious-pain': 'General Feat', 'light-bringer': 'General Feat', 'love-bites': 'General Feat', 'putrefy': 'General Feat', 'rebuke': 'General Feat', 'treacherous-allure': 'General Feat', 'vampire-touched': 'General Feat', 'archery': 'Fighting Style Feat', 'blind-fighting': 'Fighting Style Feat', 'defense': 'Fighting Style Feat', 'dueling': 'Fighting Style Feat', 'great-weapon-fighting': 'Fighting Style Feat', 'interception': 'Fighting Style Feat', 'pack-fighting': 'Fighting Style Feat', 'prone-fighting': 'Fighting Style Feat', 'protection': 'Fighting Style Feat', 'thrown-weapon-fighting': 'Fighting Style Feat', 'two-weapon-fighting': 'Fighting Style Feat', 'unarmed-fighting': 'Fighting Style Feat', 'boon-of-combat-prowess': 'Epic Boon Feat', 'boon-of-dimensional-travel': 'Epic Boon Feat', 'boon-of-energy-resistance': 'Epic Boon Feat', 'boon-of-fate': 'Epic Boon Feat', 'boon-of-fortitude': 'Epic Boon Feat', 'boon-of-irresistible-offense': 'Epic Boon Feat', 'boon-of-recovery': 'Epic Boon Feat', 'boon-of-skill': 'Epic Boon Feat', 'boon-of-speed': 'Epic Boon Feat', 'boon-of-spell-recall': 'Epic Boon Feat', 'boon-of-the-night-spirit': 'Epic Boon Feat', 'boon-of-truesight': 'Epic Boon Feat', 'boon-of-siberys': 'Epic Boon Feat', 'boon-of-bloodshed': 'Epic Boon Feat', 'boon-of-bountiful-health': 'Epic Boon Feat', 'boon-of-communication': 'Epic Boon Feat', 'boon-of-desperate-resilience': 'Epic Boon Feat', 'boon-of-exquisite-radiance': 'Epic Boon Feat', 'boon-of-fluid-forms': 'Epic Boon Feat', 'boon-of-fortune-s-favor': 'Epic Boon Feat', 'boon-of-poison-mastery': 'Epic Boon Feat', 'boon-of-revelry': 'Epic Boon Feat', 'boon-of-terror': 'Epic Boon Feat', 'boon-of-the-bright-sun': 'Epic Boon Feat', 'boon-of-the-furious-storm': 'Epic Boon Feat', 'boon-of-the-soul-drinker': 'Epic Boon Feat', 'boon-of-blazing-dawn': 'Epic Boon Feat', 'boon-of-looming-shadows': 'Epic Boon Feat', 'boon-of-misty-escape': 'Epic Boon Feat', 'aberrant-dragonmark': 'Dragonmark Feat', 'mark-of-detection': 'Dragonmark Feat', 'mark-of-finding': 'Dragonmark Feat', 'mark-of-handling': 'Dragonmark Feat', 'mark-of-healing': 'Dragonmark Feat', 'mark-of-hospitality': 'Dragonmark Feat', 'mark-of-making': 'Dragonmark Feat', 'mark-of-passage': 'Dragonmark Feat', 'mark-of-scribing': 'Dragonmark Feat', 'mark-of-sentinel': 'Dragonmark Feat', 'mark-of-shadow': 'Dragonmark Feat', 'mark-of-storm': 'Dragonmark Feat', 'mark-of-warding': 'Dragonmark Feat', 'greater-aberrant-mark': 'Dragonmark Feat', 'greater-mark-of-detection': 'Dragonmark Feat', 'greater-mark-of-finding': 'Dragonmark Feat', 'greater-mark-of-handling': 'Dragonmark Feat', 'greater-mark-of-healing': 'Dragonmark Feat', 'greater-mark-of-hospitality': 'Dragonmark Feat', 'greater-mark-of-making': 'Dragonmark Feat', 'greater-mark-of-passage': 'Dragonmark Feat', 'greater-mark-of-scribing': 'Dragonmark Feat', 'greater-mark-of-sentinel': 'Dragonmark Feat', 'greater-mark-of-shadow': 'Dragonmark Feat', 'greater-mark-of-storm': 'Dragonmark Feat', 'greater-mark-of-warding': 'Dragonmark Feat', 'potent-dragonmark': 'Dragonmark Feat', 'fey-pact': 'Planar Pact Feat', 'infernal-pact': 'Planar Pact Feat', 'fey-sentinel': 'Planar Pact Feat', 'fey-tormentor': 'Planar Pact Feat', 'infernal-bulwark': 'Planar Pact Feat', 'infernal-dragoon': 'Planar Pact Feat', 'aberrant-anatomy': 'Dark Gift Feat', 'echoing-soul': 'Dark Gift Feat', 'gathered-whispers': 'Dark Gift Feat', 'living-shadow': 'Dark Gift Feat', 'mist-walker': 'Dark Gift Feat', 'second-skin': 'Dark Gift Feat', 'symbiotic-being': 'Dark Gift Feat', 'touch-of-death': 'Dark Gift Feat', 'watchers': 'Dark Gift Feat'}


# ---------------------------------------------------------------------------
# Core parsing
# ---------------------------------------------------------------------------

def parseTable(table):
    """Turn a <table> into a dict.

    2-column tables become {first_col: second_col}.
    Wider tables become {first_col: {other_header: other_value, ...}}.
    Falls back to {first_col: [other values...]} if header/row widths
    don't line up.
    """
    rows = table.find_all("tr")
    if len(rows) < 2:
        return {}

    headers = [clean_text(c) for c in rows[0].find_all(["th", "td"])]

    result: dict = {}
    for row in rows[1:]:
        cells = row.find_all(["td", "th"])
        if not cells:
            continue
        values = [clean_text(c) for c in cells]
        key, rest = values[0], values[1:]
        if not rest:
            continue
        if len(rest) == 1:
            result[key] = rest[0]
        elif len(headers) - 1 == len(rest):
            result[key] = dict(zip(headers[1:], rest))
        else:
            result[key] = rest
    return result


def parseParagraphFeature(p):
    """<p><strong>Name</strong>. desc...</p> -> {"name": "Name", "description": "desc..."}
    Returns None if the paragraph doesn't start with a <strong> (i.e. it's
    flavor text, not a named feature)."""
    contents = [c for c in p.contents if not (isinstance(c, str) and c.strip() == "")]
    if not contents or not (isinstance(contents[0], Tag) and contents[0].name == "strong"):
        return None

    strong = contents[0]
    raw_name = clean_text(strong)
    name = raw_name.rstrip(".").strip()

    full_text = clean_text(p)
    description = full_text[len(raw_name):]
    description = description.lstrip(". ").strip()

    return {"name": name, "description": description}


def parseFeatContent(content, slug):
    feat = {
        "name": unSlug(slug),
        "catId":"feat",
        "type": featDict.get(slug, ""),
        "source": "",
        "description": "",
        "features": [],
    }

    feature_by_name: dict[str, dict] = {}
    desc_parts: list[str] = []
    pending_heading: Optional[str] = None
    first = True

    children = [c for c in content.children if isinstance(c, Tag)]

    for child in children:
        if first:
            first = False
            if child.name == "p":
                text = clean_text(child)
                m = re.match(r"^Source:\s*(.*)$", text)
                if m:
                    feat["source"] = m.group(1)
                    continue

        if child.name == "p":
            feature = parseParagraphFeature(child)
            if feature:
                feat["features"].append(feature)
                feature_by_name[feature["name"].lower()] = feature
                pending_heading = None
            else:
                text = clean_text(child)
                if text:
                    desc_parts.append(text)

        elif child.name in ("h1", "h2", "h3", "h4", "h5", "h6"):
            pending_heading = clean_text(child)

        elif child.name == "table":
            table_data = parseTable(child)
            target = feature_by_name.get((pending_heading or "").lower())
            if target is None and feat["features"]:
                target = feat["features"][-1]
            if target is not None:
                target["table"] = table_data
            pending_heading = None

        else:
            text = clean_text(child)
            if text:
                desc_parts.append(text)

    feat["description"] = " ".join(desc_parts).strip()
    return feat


def getFeatSlugs(session):
    soup = fetchSoup(session, BASE_URL + "feat:all")
    content = getPageContent(soup)
    if content is None:
        return []
    slugs = []
    for a in content.find_all("a"):
        href = a.get("href", "")
        if href.startswith("/feat:"):
            slugs.append(href.removeprefix("/feat:"))
    return slugs


def main():

    session = requests.Session()
    session.headers.update({"User-Agent": "dnd-feat-parser/1.0 (+personal project)"})

    slugs = getFeatSlugs(session)

    origin={
        "options":[]
    }
    general={
        "options":[]
    }
    fightingStyle={
        "options":[]
    }
    epicBoon={
        "options":[]
    }
    dragonmark={
        "options":[]
    }
    planarPact={
        "options":[]
    }
    darkGift={
        "options":[]
    }

    featsJson={}

    feats = []
    i=0
    for slug in slugs:
        try:
            soup = fetchSoup(session, BASE_URL + "feat:" + slug)
        except requests.RequestException as e:
            print(f"skip {slug}: request failed ({e})", file=sys.stderr)
            continue

        content = getPageContent(soup)
        if content is None:
            print(f"skip {slug}: no #page-content found", file=sys.stderr)
            continue

        feat = parseFeatContent(content, slug)
        feats.append(feat)
        print("- assets/json/feats/"+slug+".json")

        if(feat["type"].startswith("Origin")):
            origin["options"].append("assets/json/feats/"+slug+".json")
        elif(feat["type"].startswith("General")):
            general["options"].append("assets/json/feats/"+slug+".json")
        elif (feat["type"].startswith("Fighting")):
            fightingStyle["options"].append("assets/json/feats/"+slug+".json")
        elif (feat["type"].startswith("Epic")):
            epicBoon["options"].append("assets/json/feats/"+slug+".json")
        elif (feat["type"].startswith("Dragonmark")):
            dragonmark["options"].append("assets/json/feats/"+slug+".json")
        elif (feat["type"].startswith("Planar")):
            planarPact["options"].append("assets/json/feats/"+slug+".json")
        elif (feat["type"].startswith("Dark")):
            darkGift["options"].append("assets/json/feats/"+slug+".json")

        with open("../dnd_app/assets/json/feats/"+slug+".json", "w", encoding="utf-8") as f:
            json.dump(feat, f, indent=2, ensure_ascii=False)

        featsJson["f"+str(i)]={
            "name":feat["name"],
            "Basics":{
                "source":feat["source"],
                "type":feat["type"],
            },
            "Icon":{
                "base":"none"
            },
            "json":"assets/json/feats/"+slug+".json"
        }

        i+=1

    with open("../dnd_app/assets/json/feats/origin.json", "w", encoding="utf-8") as f:
        json.dump(origin,f,indent=2, ensure_ascii=False)
    with open("../dnd_app/assets/json/feats/general.json", "w", encoding="utf-8") as f:
        json.dump(general,f,indent=2, ensure_ascii=False)
    with open("../dnd_app/assets/json/feats/fightingStyle.json", "w", encoding="utf-8") as f:
        json.dump(fightingStyle,f,indent=2, ensure_ascii=False)
    with open("../dnd_app/assets/json/feats/epicBoon.json", "w", encoding="utf-8") as f:
        json.dump(epicBoon,f,indent=2, ensure_ascii=False)
    with open("../dnd_app/assets/json/feats/dragonmark.json", "w", encoding="utf-8") as f:
        json.dump(dragonmark,f,indent=2, ensure_ascii=False)
    with open("../dnd_app/assets/json/feats/planarPact.json", "w", encoding="utf-8") as f:
        json.dump(planarPact,f,indent=2, ensure_ascii=False)
    with open("../dnd_app/assets/json/feats/darkGift.json", "w", encoding="utf-8") as f:
        json.dump(darkGift,f,indent=2, ensure_ascii=False)


    print("- assets/json/feats/origin.json")
    print("- assets/json/feats/general.json")
    print("- assets/json/feats/fightingStyle.json")
    print("- assets/json/feats/epicBoon.json")
    print("- assets/json/feats/dragonmark.json")
    print("- assets/json/feats/planarPact.json")
    print("- assets/json/feats/darkGift.json")


    with open("../dnd_app/assets/json/feats.json", "w", encoding="utf-8") as f:
        json.dump(featsJson,f,indent=2, ensure_ascii=False)

    print("- assets/json/feats.json")

if __name__ == "__main__":
    main()