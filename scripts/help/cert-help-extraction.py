#!/usr/bin/env python3
from argparse import ArgumentParser
import tempfile
import re
import urllib.request
from urllib.parse import quote_plus, urlparse
import hashlib
from pathlib import Path
import copy
from bs4.element import NavigableString, Tag
from bs4 import BeautifulSoup
import requests
import sys
import marko
from marko.md_renderer import MarkdownRenderer
import unicodedata

script_path = Path(__file__)
# Add the shared module to the path
sys.path.append(str(script_path.parent.parent / 'shared'))
from codeql import CodeQL, CodeQLError
from markdown_helpers import HeadingReplaceSpec, HeadingFormatUpdateSpec, update_help_file, HeadingDiffUpdateSpec, find_heading, iterate_headings, get_heading_text

CERT_WIKI = "https://wiki.sei.cmu.edu"
RULES_LIST_C = "/confluence/display/c/2+Rules"
RULES_LIST_CPP = "/confluence/display/cplusplus/2+Rules"

cache_path = script_path.parent / '.cache'
cache_path.mkdir(exist_ok=True)
repo_root = script_path.parent.parent.parent
rule_path = None


def soupify(url: str) -> BeautifulSoup:
    m = hashlib.sha1()
    m.update(url.encode('utf-8'))
    cache_key = m.hexdigest()
    cache_file = cache_path.joinpath(cache_key)
    if cache_file.exists():
        content = cache_file.read_text('utf-8')
    else:
        resp = requests.get(url)
        if resp.status_code != 200:
            return None
        content = unicodedata.normalize("NFKD", resp.text)
        cache_file.write_text(content,encoding='utf8')

    return BeautifulSoup(content, 'html.parser')


def get_rules():
    rules = []
    for soup in [soupify(f"{CERT_WIKI}{RULES_LIST_C}"), soupify(f"{CERT_WIKI}{RULES_LIST_CPP}")]:
        if soup == None:
            return None

        rule_listing_start = soup.find(
            "h1", string="Rule Listing")
        
        for link in rule_listing_start.next_element.next_element.find_all('a'):
            if '-C' in link.string:
                rule, title = map(str.strip, link.string.split('.', 1))
                rules.append({'id': rule, 'title': title, 'link': link['href'], 'lang':"c"})
            if '-CPP' in link.string:  
                rule, title = map(str.strip, link.string.split('.', 1))
                rules.append({'id': rule, 'title': title, 'link': link['href'], 'lang':"cpp"})  

    return rules


def between_siblings(root, node_text):
    nodes = []
    for sibling in list(root.next_siblings):
        if not isinstance(sibling, NavigableString) and sibling.name == node_text:
            return nodes
        nodes.append(sibling.extract())
    return nodes


def apply_post_order(node, fn):
    if isinstance(node, Tag):
        children = consume(node.children)
        for child in children:
            apply_post_order(child, fn)
    fn(node)


def not_in_p(lst):
    def aux(e):
        return not e in lst

    return aux


def strip_attributes(tag):
    if not tag.name in ELEMENTS.keys():
        tag.attrs = {}
    else:
        e = ELEMENTS[tag.name]
        allowed = e_allowed_attr(e)

        for attr in consume(tag.attrs.keys()):
            if not allowed(attr):
                del tag[attr]


def consume(iterator):
    return list(iterator)


def e(element, allowed_attr, allowed_children):
    return {'tag': element, 'allowed_attr': allowed_attr, allowed_children: allowed_children}


def e_tag(e):
    return e['tag']


def e_allowed_attr(e):
    return e['allowed_attr']


def none(e):
    return False


def any_block_element(e):
    return e_tag(e) in map(e_tag, BLOCK_ELEMENTS)


def any_block_node(node):
    return node.name in map(e_tag, BLOCK_ELEMENTS)


def any_inline_element(e):
    return e_tag(e) in map(e_tag, INLINE_ELEMENTS)


def any_of(*args):
    def aux(e):
        tag = e if isinstance(e, str) else e_tag(e)
        return any([c(tag) if callable(c) else tag == c for c in args])
    return aux


def text(e):
    return isinstance(e, NavigableString)


SECTION_ELEMENTS = [e('example', none, any_block_element),
                    e('fragment', none, any_block_element),
                    e('include', any_of('hr'), none),
                    e('overview', none, any_block_element),
                    e('recommendation', none, any_block_element),
                    e('references', none, any_of('li')),
                    e('section', any_of('title'), any_block_element),
                    e('semmleNotes', none, any_block_element)]
BLOCK_ELEMENTS = [e('blockquote', none, any_block_element),
                  e('img', any_of('src', 'alt', 'height', 'width'), none),
                  e('include', any_of('src'), none),
                  e('ol', none, any_of('li')),
                  e('p', none, any_inline_element),
                  e('pre', none, text),
                  e('sample', any_of('language'), text),
                  e('table', none, any_of('tbody')),
                  e('ul', none, any_of('li')),
                  e('warning', none, text)]
# ol and ul are covered in block elements
LIST_ELEMENTS = [e('li', none, any_of(any_block_element, any_inline_element))]
TABLE_ELEMENTS = [e('tbody', none, any_of('tr')),
                  e('tr', none, any_of('th', 'td')),
                  e('td', none, any_inline_element),
                  e('th', none, any_inline_element)]
INLINE_ELEMENTS = [e('a', any_of('href'), text),
                   e('b', none, any_inline_element),
                   e('code', none, any_inline_element),
                   e('em',  none, any_inline_element),
                   e('i', none, any_inline_element),
                   e('img', any_of('src', 'alt', 'height', 'width'), none),
                   e('strong', none, any_inline_element),
                   e('sub', none, any_inline_element),
                   e('sup', none, any_inline_element),
                   e('tt', none, any_inline_element)]

ELEMENTS = {e_tag(e): e for e in SECTION_ELEMENTS + BLOCK_ELEMENTS +
            LIST_ELEMENTS + TABLE_ELEMENTS + INLINE_ELEMENTS}

SUPPORTED_TAGS = list(ELEMENTS.keys()) + \
    ['body', 'h1', 'h2', 'h3', 'h4', 'h6', 'thead']


def is_code_table(tag):
    return tag.name == 'table' and \
        'wysiwyg-macro' in tag.attrs['class'] and \
        'data-macro-name' in tag.attrs and \
        tag.attrs['data-macro-name'] == 'code'


def is_navigation(node):
    if node.name == 'p':
        for a in node.find_all('a'):
            if a.img and 'button_arrow' in a.img['src']:
                return True
        return False
    else:
        return False


def transform_html(rule, soup):
    """Remove unsupported tags and attributes starting at node"""
    def helper(node):
        if isinstance(node, Tag):
            if node.name in SUPPORTED_TAGS:
                # Fix a broken url present in many CERT-C pages
                if node.name == 'a' and 'href' in node.attrs and node['href'] == "http://BB. Definitions#vulnerability":
                    node['href'] = "https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability"
                # Turn relative URLs into absolute URLS
                elif node.name == 'a' and 'href' in node.attrs and node['href'].startswith("/confluence"):
                    node['href'] = f"{CERT_WIKI}{node['href']}"
                # Turn anchor references into absolute URLS
                elif node.name == 'a' and 'href' in node.attrs and node['href'].startswith('#'):
                    node['href'] = f"{CERT_WIKI}{rule['link']}{node['href']}"
                # Percent encode exclude characters in fragments according to https://datatracker.ietf.org/doc/html/rfc2396#section-2.4.3
                if node.name == 'a' and 'href' in node.attrs:
                    href = node['href']
                    if '#' in href:
                        uri, fragment = href.split('#', 1)
                        # print(f"before: {fragment}", file=sys.stderr)
                        fragment = quote_plus(fragment)
                        # excluded_chars = [chr(c) for c in range(
                        #     0, 21)] + ['\7f'] + ['<', '>', '#', '%', '"', '{', '}', '|', '\\', '^', '[', ']', '`']
                        # for c in excluded_chars:
                        #     fragment = fragment.replace(
                        #         c, "%%02x".format(ord(c)))
                        # print(f"after: {fragment}", file=sys.stderr)
                        node['href'] = f"{uri}#{fragment}"
                # Replace code macro's with a sample tag.
                # The code tag is required to ensure the text is not escaped when converted to Markdown.
                if is_code_table(node):
                    # This used to be a pre tag in the original source, but we have replaced pre tags with code tags in td tags.
                    code = node.find('code').extract()

                    sample = soup.new_tag('sample')
                    sample['language'] = 'cpp'
                    sample.string = code.string

                    node.replace_with(sample)
                # Remove the navigation, we can only use the src attribute of the child because all other
                # attributes have been stripped
                if is_navigation(node):
                    node.decompose()
                # Unwrap <p> tags containing a list
                # Remove empty <p> tags or tags containing a No-Break Space Unicode character representing a `&nbsp;`.
                if node.name == "p" and (len(node.contents) == 0 or node.string == "\u00a0"):
                    node.decompose()

                # Smooth headers
                if node.name in ['h1', 'h2', 'h3', 'h4']:
                    for child in node.contents:
                        if not text(child):
                            child.unwrap()
                    node.smooth()
                # Upgrade header levels :/
                if node.name == 'h3' and node.string in ['Automated Detection', 'Related Vulnerabilities']:
                    # print('Inconsistent header')
                    node.name = 'h2'
                # All <tr> should be in a table inside a single <tbody>
                if node.name == 'table':
                    for b in node.find_all('thead', Recursive=False):
                        b.unwrap()
                    for b in node.find_all('tbody', Recursive=False):
                        b.unwrap()

                    tbody = soup.new_tag('tbody')
                    for tr in node.find_all('tr', Recursive=False):
                        tbody.append(tr)
                    node.append(tbody)
                # Remove p tags from td and th tags
                if node.name in ['th', 'td'] and node.p:
                    node.p.unwrap()
                # Remove hidden details macro's
                if node.name == 'table' and 'data-macro-name' in node.attrs and node['data-macro-name'] == 'details' and 'data-macro-parameters' in node.attrs and node['data-macro-parameters'] == 'hidden=true':
                    node.decompose()
                if node.name == 'img' and 'data-macro-name' in node.attrs and node['data-macro-name'] == 'anchor':
                    node.decompose()                
                # Retrieve Images
                if node.name == 'img' and 'src' in node.attrs and node['src'].startswith("/confluence") and not node['src'].startswith("/confluence/plugins/"):
                    url = CERT_WIKI+node['src']
                    filename = urlparse(url).path.split("/")[-1]
                    # exclude button arrows images
                    if not 'button_arrow' in filename:
                        full_name = repo_root.joinpath(rule_path, filename)
                        urllib.request.urlretrieve(url, full_name)
                        node['src'] = filename
                # Replace check.svg and error.svg images with unicode characters
                if node.name == 'img':
                    if node['src'].endswith("check.svg"):
                        node.replace_with('\u2713')
                    elif node['src'].endswith("error.svg"):
                        node.replace_with('\u274C')
                # Unwrap <code>, because <a> can only contain text in QHelp
                if node.name == 'code' and node.find_parent('a'):
                    node.unwrap()
                # Swap <a> containing <sup>, because <a> can only contain text in QHelp
                if node.name == 'a' and node.sup:
                    sup = node.sup.extract()
                    node.wrap(sup)
                # Swap <a> containing <strong>, because <a> can only contain text in QHelp
                if node.name == 'a' and node.strong:
                    strong = node.strong.extract()
                    node.wrap(strong)
                 # Swap <a> containing <em>, because <a> can only contain text in QHelp
                if node.name == 'a' and node.em:
                    em = node.em.extract()
                    node.wrap(em)
                # <h3>...</h3> -> <p><strong>...</strong></p>
                if node.name in ['h3', 'h4']:
                    node.name = 'strong'
                    node.wrap(soup.new_tag('p'))
                # <td>...<p>...</p></td> -> <td>......</td>
                if node.name == 'td':
                    for p in node.find_all('p'):
                        p.unwrap()
                # Add required 'alt' attribute to <img>
                if node.name == 'img' and not node.alt:
                    node['alt'] = ""
                # Remove <strong><br/></strong>, by removing <strong></strong> since <br> are unsupported elements that are unwrapped before we encounter the <strong>
                if node.name == 'strong' and len(node.contents) == 0:
                    node.decompose()
                # Replace <td><pre>...</pre></td> with <td><code>...</code></td> because in QLHelp <pre> is a block element while <td> only allows inline content elements.
                if node.name == 'td' and node.pre:
                    node.pre.name = 'code'
                # Replace <td><sample>...</sample></td> with <td><code>...</code></td> because in QLHelp <sample> is a block element while <td> only allows inline content elements.
                if node.name == 'td' and node.sample:
                    node.sample.attrs = {}
                    node.sample.name = 'code'
                # Replace <td><ul>...</ul></td> with <td> - ..., ... </td> because QLHelp doesn't support nested lists.
                if node.name == 'td' and node.ul:
                    list_contents = ", ".join(
                        map(lambda n: n.string.lower() + n.string[1:] if n.string else '', node.ul.find_all('li'))).capitalize()
                    if not list_contents.endswith('.'):
                        list_contents += '.'
                    node.ul.replace_with(list_contents)
                # Replace <ul><li><ul><li>...</li>...</ul>...</ul> with the contents of the embedded list because QLHelp doesn't support nested lists.
                if node.name == 'ul' and node.find_parent('li'):
                    for child in node.find_all('li', recursive=False):
                        child.unwrap()
                    node.unwrap()
                # Replace <ul><li><p>...</p></li></ul> with the contents of the paragraph because QLHelp doesn't support paragraphs inside lists.
                if node.name == 'p' and node.find_parent('li'):
                    node.unwrap()
                strip_attributes(node)
                if node.name == 'h6':
                    node.name = 'p'
            else:
                node.unwrap()
    apply_post_order(soup.body, helper)


def inject_versions(soup_with, soup_without):
    def find_automated_detection_table(soup):
        # Some help files use h2 and some use h3
        h = soup.find(text=re.compile("Automated Detection"))
        return h.find_next('table')

    def get_versions():
        table = find_automated_detection_table(soup_with)
        versions = []
        trs = []
        if table.thead:
            trs.extend(table.thead.find_all('tr', Recursive=False))
        if table.tbody:
            trs.extend(table.tbody.find_all('tr', Recursive=False))
        for tr in trs:
            # Skip header row, if any
            if tr.th:
                continue

            first_column = tr.td
            version_column = first_column.next_sibling

            if version_column.div and version_column.div.div and version_column.div.div.p:
                version = version_column.div.div.p.string
            elif version_column.div and version_column.div.p:
                version = version_column.div.p.string
            elif version_column.div:
                version = version_column.div.string
            elif version_column.p:
                version = version_column.p.string
            elif version_column.a:
                version = version_column.a.string
            else:
                version = version_column.string
            # replace None with the empty string
            versions.append(version or '')
        return versions

    def set_versions(versions):
        table = find_automated_detection_table(soup_without)
        i = 0
        trs = []
        if table.thead:
            trs.extend(table.thead.find_all('tr', Recursive=False))
        if table.tbody:
            trs.extend(table.tbody.find_all('tr', Recursive=False))
        for tr in trs:
            # Skip header row, if any
            if tr.th:
                continue
            version_column = tr.td.next_sibling
            version_column.clear()
            version_column.string = versions[i]
            i += 1

    versions = get_versions()
    set_versions(versions)


def convert2qhelp(soup):
    qhelp_doc = BeautifulSoup(
        '<!DOCTYPE qhelp SYSTEM "qhelp.dtd"><qhelp></qhelp>', 'html.parser')
    qhelp_doc.qhelp.append(copy.copy(soup.body))
    qhelp_doc.qhelp.body.unwrap()

    # Move first elements into a description section
    section = qhelp_doc.new_tag('section')
    section['title'] = "Description"
    first_child = list(qhelp_doc.qhelp.children)[0]
    remaining_children = between_siblings(first_child, 'h2')

    section.append(first_child)
    section.extend(remaining_children)
    qhelp_doc.qhelp.insert(0, section)

    # Replace all the headers with a section
    for h2 in qhelp_doc.qhelp.find_all('h2'):
        section = soup.new_tag('section')
        if not h2.string:
            print(h2)
            raise "Empty h2"
        section['title'] = h2.string

        section.extend(between_siblings(h2, 'h2'))
        h2.replace_with(section)

    return qhelp_doc


def is_not(pred):
    def aux(*args, **kwargs):
        return not pred(*args, **kwargs)
    return aux


def get_help(rule):
    # print(rule)
    rule_view = soupify(f"{CERT_WIKI}{rule['link']}")
    if rule_view == None:
        return None

    source_view_link = rule_view.find(id='action-view-source-link')['href']

    soup = soupify(f"{CERT_WIKI}{source_view_link}")
    if soup == None:
        return None

    soup.head.decompose()
    transform_html(rule, soup)
    inject_versions(rule_view, soup)
    qhelp_doc = convert2qhelp(soup)

    # preserve whitespace when printing
    qhelp_doc.preserve_whitespace_tags.update(
        ['sample', 'code', 'strong', 'p', 'li'])
    return qhelp_doc.prettify()

# Parse args
help_statement = """
A tool for generating CERT query help files.
All help files will be generated if no rule names are provided as argument.
"""
parser = ArgumentParser(description=help_statement)
parser.add_argument(
    "arg_rule_name", nargs="*", help="the name of the rule to generate help files for")
args = parser.parse_args()

# Get rules
rules = get_rules()
if rules == None:
    print("Failed to retrieve list of rules", file=sys.stdout)
    sys.exit(1)

for rule in rules:
    if args.arg_rule_name and rule['id'].lower() not in (string.lower() for string in args.arg_rule_name):
        continue
    rule_path = repo_root / rule['lang'] / 'cert' / 'src' / 'rules' / rule['id']
    # only consider implemented rules
    if rule_path.exists():
        codeql = CodeQL()
        md = marko.Markdown(renderer=MarkdownRenderer)
        for query_path in rule_path.glob('*.ql'):
            print(f"ID: {rule['id']} - Converting contents at {CERT_WIKI}{rule['link']} into Markdown help file for {query_path.stem}")
            help_path = query_path.with_suffix('.md')

            # If it hasn't been generated, skip it.
            if not help_path.exists():
                print(f"ID: {rule['id']} - Skipping updating help file for {query_path}, because it doesn't exist!")
                continue

            temp_qhelp_path = query_path.with_suffix('.qhelp')
            temp_qhelp_path.write_text(get_help(rule),encoding='utf8')

            temp_help_path = help_path.with_suffix('.md.tmp')
            try:
                codeql.generate_query_help(temp_qhelp_path, temp_help_path)
            except CodeQLError as err:
                print(f"{err.reason}: {err.stderr}")
            temp_qhelp_path.unlink()

            parsed_temp_help = md.parse(temp_help_path.read_text('utf-8'))
            # Remove the first header that is added by the QHelp to Markdown conversion
            del parsed_temp_help.children[0]
            temp_help_path.write_text(md.render(parsed_temp_help),encoding='utf8')

            parsed_help = md.parse(help_path.read_text('utf-8'))
            if find_heading(parsed_help, 'CERT'):
                # Check if it contains the CERT heading that needs to be replaced
                print(f"ID: {rule['id']} - Found heading 'CERT' whose content will be replaced")
                update_help_file(parsed_help, [HeadingReplaceSpec('CERT', parsed_temp_help.children), HeadingFormatUpdateSpec()])
            else:
                # Otherwise update the content of every existing second level heading, note that this doesn't add headings!
                second_level_headings = {get_heading_text(heading) for heading in iterate_headings(parsed_temp_help) if heading.level == 2}
                # Check if there are any headings we don't have in our current help file. If that is the case we need to manually update that first.
                existing_second_level_headings = {get_heading_text(heading) for heading in iterate_headings(parsed_help) if heading.level == 2}
                if not second_level_headings.issubset(existing_second_level_headings):
                    print(f"ID: {rule['id']} - The original help is missing the header(s) '{', '.join(second_level_headings.difference(existing_second_level_headings))}'. Proceed with manually adding these in the expected location (See {temp_help_path}).")
                    sys.exit(1)
                print(f"ID: {rule['id']} - Didn't find heading 'CERT', going to update the headings '{', '.join(second_level_headings)}'.")
                update_help_file(parsed_help, [HeadingDiffUpdateSpec(heading, parsed_temp_help) for heading in second_level_headings] + [HeadingFormatUpdateSpec()])

            temp_help_path.unlink()
            help_path.write_text(md.render(parsed_help), encoding='utf8')
