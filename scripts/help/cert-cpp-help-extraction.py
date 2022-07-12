import sys
import requests
from bs4 import BeautifulSoup
from bs4.element import NavigableString, Tag
import copy
from pathlib import Path
import hashlib
from urllib.parse import quote_plus

CERT_WIKI = "https://wiki.sei.cmu.edu"
RULES_LIST = "/confluence/display/cplusplus/2+Rules"

script_path = Path(__file__)
cache_path = script_path.parent.joinpath('.cache')
cache_path.mkdir(exist_ok=True)
repo_root = script_path.parent.parent.parent


def soupify(url: str) -> BeautifulSoup:
    m = hashlib.sha1()
    m.update(url.encode('UTF-8'))
    cache_key = m.hexdigest()
    cache_file = cache_path.joinpath(cache_key)
    if cache_file.exists():
        with cache_file.open() as f:
            content = f.read()
    else:
        resp = requests.get(url)

        if resp.status_code != 200:
            return None

        content = resp.text
        with cache_file.open('w') as f:
            f.write(content)

    return BeautifulSoup(content, 'html.parser')


def get_rules():
    soup = soupify(f"{CERT_WIKI}{RULES_LIST}")
    if soup == None:
        return None

    rule_listing_start = soup.find(
        "h1", string="Rule Listing")
    rules = []
    for link in rule_listing_start.next_element.next_element.find_all('a'):
        if '-CPP' in link.string:
            rule, title = map(str.strip, link.string.split('.', 1))
            rules.append({'id': rule, 'title': title, 'link': link['href']})

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
                    e('hr', none, none),
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

SUPPORTED_TAGS = list(ELEMENTS.keys()) + ['body', 'h1', 'h2', 'h3', 'h4']


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


def transform_html(soup):
    """Remove unsupported tags and attributes starting at node"""
    def helper(node):
        if isinstance(node, Tag):
            if node.name in SUPPORTED_TAGS:
                # Turn relative URLs into absolute URLS
                if node.name == "a" and 'href' in node.attrs and node['href'].startswith("/confluence"):
                    node['href'] = f"{CERT_WIKI}{node['href']}"
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
                    if node.previous_sibling.name == 'hr':
                        node.previous_sibling.decompose()
                    node.decompose()
                # Unwrap <p> tags containing a list
                # Remove empty <p> tags or tags containing a No-Break Space Unicode character representing a `&nbsp;`.
                if node.name == "p" and (len(node.contents) == 0 or node.string == "\u00a0"):
                    node.decompose()

                # Remove non breaking spaces in headers
                if node.name in ['h2', 'h3', 'h4']:
                    if len(node.contents) == 2 and node.contents[1].string == "\u00a0":
                        node.string = node.contents[0]
                # Smooth headers
                if node.name in ['h1', 'h2', 'h3', 'h4']:
                    for child in node.contents:
                        if not isNavigableString(child):
                            child.unwrap()
                    node.smooth()
                # Upgrade header levels :/
                if node.name == 'h3' and node.string in ['Automated Detection', 'Related Vulnerabilities']:
                    # print('Inconsistent header')
                    node.name = 'h2'
                # Wrap tr tags that are a direct child of a table without a tbody into a mandatory tbody
                if node.name == 'table' and not node.tbody:
                    tbody = soup.new_tag('tbody')
                    for tr in node.find_all('tr', Recursive=False):
                        tbody.append(tr.extract())
                    node.append(tbody)
                # Insert tr tags that are a direct child of a table with a tbody because are a result of an unwrapped thead
                if node.name == 'table' and node.tbody and node.tr:
                    node.tbody.insert(0, node.tr.extract())
                # Remove p tags from td and th tags
                if node.name in ['th', 'td'] and node.p:
                    node.p.unwrap()
                # Remove hidden details macro's
                if node.name == 'table' and 'data-macro-name' in node.attrs and node['data-macro-name'] == 'details' and 'data-macro-parameters' in node.attrs and node['data-macro-parameters'] == 'hidden=true':
                    node.decompose()
                if node.name == 'img' and 'data-macro-name' in node.attrs and node['data-macro-name'] == 'anchor':
                    node.decompose()
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
                # Replace <td><ul>...</ul></td> with <td> - ..., ... </td> because QLHelp doesn't support nested lists.
                if node.name == 'td' and node.ul:
                    list_contents = ", ".join(
                        map(lambda n: n.string[0].lower() + n.string[1:], node.ul.find_all('li'))).capitalize()
                    if not list_contents.endswith('.'):
                        list_contents += '.'
                    node.ul.replace_with(list_contents)
                # Replace <ul><li><ul><li>...</li>...</ul>...</ul> with the contents of the embedded list because QLHelp doesn't support nested lists.
                if node.name == 'ul' and node.find_parent('li'):
                    for child in node.find_all('li', recursive=False):
                        child.unwrap()
                    node.unwrap()
                strip_attributes(node)
            else:
                node.unwrap()
    apply_post_order(soup.body, helper)


def inject_versions(soup_with, soup_without):
    def get_versions():
        # Some help files use h3 instead of :/
        h = soup_with.find(['h2', 'h3'], string="Automated Detection")
        # Some help files use h2, but with additional content :/
        if not h:
            for h2 in soup_with.find_all(['h2', 'h3']):
                text = h2.contents[0]
                if text.string == "Automated Detection":
                    h = h2
                    break
        if not h:
            raise "Unable to find required 'Automated Detection' header"
        table = h.next_sibling.table
        versions = []
        for tr in table.tbody.find_all('tr', Recursive=False):
            # Skip header row, if any
            if tr.th:
                continue

            first_column = tr.td
            version_column = first_column.next_sibling

            if version_column.div and version_column.div.p:
                version = version_column.div.p.string
            elif version_column.div:
                version = version_column.div.string
            elif (version_column.p and version_column.p.br) or version_column.br:
                # No version information
                version = ""
            elif len(version_column.find_all(True)) > 0:
                print(version_column)
                raise "Unexpected version column"
            else:
                version = version_column.string
            versions.append(version)
        return versions

    def set_versions(versions):
        h = soup_without.find('h2', string="Automated Detection")
        if not h:
            print("Failed to find header 'Automated Detection'")
        table = h.find_next('table')

        i = 0
        for tr in table.tbody.find_all('tr', Recursive=False):
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


def isNavigableString(t):
    return isinstance(t, NavigableString)


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
    transform_html(soup)
    inject_versions(rule_view, soup)
    qhelp_doc = convert2qhelp(soup)

    return qhelp_doc.prettify()


rules = get_rules()
if rules == None:
    print("Failed to retrieve list of rules", file=sys.stdout)
    sys.exit(1)

for rule in rules:
    print(f"ID: {rule['id']} url: {CERT_WIKI}{rule['link']}")
    help = get_help(rule)
    rule_path = repo_root.joinpath('cpp', 'cert', 'src', 'rules', rule['id'])
    if rule_path.exists():
        for help_rule_file in rule_path.glob('*-standard.qhelp'):
            print(f"Writing {help_rule_file}")
            with help_rule_file.open('w') as f:
                f.write(help)
