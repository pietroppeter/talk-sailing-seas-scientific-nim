#!/usr/bin/env python3
"""Bundle one built page of docs/ with the local files it loads, to publish it as a claude.ai artifact.

    python3 scripts/bundle-page.py docs/slides_island1.html /mnt/user-data/outputs/island1

copies the page as <outdir>/index.html and every file it loads from docs/ (scripts, stylesheets,
images, fonts and what the stylesheets load through url() or @import) at the same path relative
to docs/, and rewrites the page's links so they work from the root of the artifact. It prints the
`files` list for the publish_files tool. Links to other pages (deep dives, the deck) are left as
they are: they do not resolve inside the artifact. Pages shown in an iframe come along, with what they
load, at their own place in docs/.
"""
import json, os, re, shutil, sys

page, outdir = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])
docs = os.path.dirname(page)  # the docs/ folder the page is in
while os.path.basename(docs) != "docs" and os.path.dirname(docs) != docs:
    docs = os.path.dirname(docs)
tag_re = re.compile(r'<(?:script|link|img|source|iframe)\b[^>]*?(?:src|href)=["\']([^"\'#?]+)')
css_re = re.compile(r'(?:url\(\s*["\']?|@import\s+["\'])([^"\')#?]+)')
skip = lambda u: u.startswith(("http:", "https:", "data:", "//", "mailto:"))

files, todo, pages = {}, [], []


def add(target):
    """keep `target` (a file in docs/) and queue what it loads; returns its path relative to docs/"""
    rel = os.path.relpath(target, docs)
    root, ext = os.path.splitext(target)
    if ext in (".ttf", ".eot") or (ext == ".woff" and os.path.isfile(root + ".woff2")):
        return rel  # browsers take the woff2 (or woff) of a font: leave the older formats out
    if rel not in files:
        files[rel] = target
        if ext == ".css":
            todo.append(target)
        elif ext == ".html":  # a page shown inside this one (an iframe): it keeps its place in docs/
            pages.append(target)
    return rel


def scan(html, base, embed_pages):
    """the local files an html page loads, added; returns {url as written: path relative to docs/}"""
    found = {}
    for url in set(tag_re.findall(html)):
        target = os.path.normpath(os.path.join(base, url))
        if skip(url) or not os.path.isfile(target):
            continue
        if target.endswith(".html") and not embed_pages:
            continue
        found[url] = add(target)
    for url in set(css_re.findall(html)):  # url() in <style> blocks and style attributes
        target = os.path.normpath(os.path.join(base, url.strip()))
        if not skip(url) and os.path.isfile(target):
            found["(" + url] = "(" + add(target)
    for local in set(re.findall(r"katex:\s*\{\s*local:\s*'([^']+)'", html)):  # reveal.js math plugin
        for f in ["dist/katex.min.js", "dist/katex.min.css", "dist/contrib/auto-render.min.js",
                  "dist/contrib/mhchem.min.js"]:
            target = os.path.normpath(os.path.join(base, local, f))
            if os.path.isfile(target):
                add(target)
    return found


html = open(page, encoding="utf-8").read()
# the page itself: links to other pages stay as they are, pages shown in an iframe come along
iframe_urls = set(re.findall(r'<iframe\b[^>]*?src=["\']([^"\'#?]+)', html))
for url, rel in scan(html, os.path.dirname(page), embed_pages=False).items():
    if url.startswith("("):
        html = html.replace(url, rel)
    else:
        html = re.sub(r'(["\'])' + re.escape(url) + r'(["\'])', r"\g<1>" + rel + r"\g<2>", html)
for url in iframe_urls:
    target = os.path.normpath(os.path.join(os.path.dirname(page), url))
    if not skip(url) and os.path.isfile(target):
        rel = add(target)
        html = re.sub(r'(src=["\'])' + re.escape(url) + r'(["\'])', r"\g<1>" + rel + r"\g<2>", html)
while todo or pages:
    while todo:  # what stylesheets load: fonts, images, other stylesheets
        css = todo.pop()
        for url in css_re.findall(open(css, encoding="utf-8", errors="replace").read()):
            target = os.path.normpath(os.path.join(os.path.dirname(css), url.strip()))
            if not skip(url) and os.path.isfile(target):
                add(target)
    while pages:  # pages in iframes, at their own place: their links already work from there
        inner = pages.pop()
        scan(open(inner, encoding="utf-8").read(), os.path.dirname(inner), embed_pages=True)

shutil.rmtree(outdir, ignore_errors=True)
os.makedirs(outdir)
open(os.path.join(outdir, "index.html"), "w", encoding="utf-8").write(html)
listing = [{"as": "index.html", "path": os.path.join(outdir, "index.html")}]
for rel, src in sorted(files.items()):
    dst = os.path.join(outdir, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy(src, dst)
    listing.append({"as": rel, "path": dst})
print(json.dumps(listing))
