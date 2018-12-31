#!/usr/bin/python
#
# add-bookmarks.py - add urls to google-chrome bookmarks file
#
import sys
import json

def create_entry(urlid, url):
    template = {
        "date_added": "13167107510166544",
        "meta_info": {
            "last_visited_desktop": "13167107510166741"
        },
        "name": "",
        "type": "url",
    }

    template["url"] = url
    template["id"] = str(urlid)
    return template


if len(sys.argv) < 3:
    print "usage: " + sys.argv[0] + " bookmarkfile urlfile"
    exit()

# read bookmarks file as json
with open(sys.argv[1]) as bookmarkfile:
    bookmarks = json.load(bookmarkfile)

# read new urls as list
with open(sys.argv[2]) as urlfile:
    urllist = urlfile.readlines()

urllist = [x.strip() for x in urllist]

startid = 0
list = ['bookmark_bar', 'other', 'synced']
existingurl = []

# find max id and populate existingurl list
for item in list:
    if int(bookmarks["roots"][item]["id"]) > startid:
        startid = int(bookmarks["roots"][item]["id"])

    for child in bookmarks["roots"][item]["children"]:
        existingurl.append(child["url"])
        if int(child["id"]) > startid:
            startid = int(child["id"])

# add new urls to bookmark_bar and ignore existing urls
for url in urllist:
    if not url in existingurl and url.startswith("http"):
        startid = int(startid) + 1
        newbookmark = create_entry(startid, url)
        bookmarks["roots"]["bookmark_bar"]["children"].append(newbookmark)

# write new json to bookmarks file
with open(sys.argv[1], 'w') as bookmarkfile:
    json.dump(bookmarks, bookmarkfile, indent=4)
