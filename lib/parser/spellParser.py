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

def parseTable(table):
    rows=table.find_all("tr")


def main():
    soup=fetchSoup(BASE_URL+"spell:all")
    content= getPageContent(soup)
    elements=[]
    for el in content:
        elements.append(el)
    table=elements[9]

    strRows=str(table).split("</tr>")


if __name__ == "__main__":
    main()