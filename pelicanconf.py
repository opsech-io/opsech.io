#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Mike'
SITENAME = u'#> opsech.io'
SITEURL = ''
SITESUBTITLE = "Random wanderings of a Linux traveller"

PATH = 'content'
PLUGIN_PATHS = ["../pelican-plugins"] 
PLUGINS = ["better_codeblock_line_numbering"]

TIMEZONE = 'America/New_York'

DEFAULT_LANG = u'en'

#THEME = 'pelican-blueidea'
# https://github.com/ingwinlu/pelican-twitchy
THEME = 'pelican-twitchy'
PYGMENTS_STYLE = "monokai"
BOOTSTRAP_THEME = "slate"
CUSTOM_CSS = "extra/codeblock_line_numbering.css"
SOCIAL = (('Bitbucket','https://bitbucket.org/xenithorb'), 
	('Github','https://github.com/xenithorb'))
EXPAND_LATEST_ON_INDEX = True
OPEN_GRAPH = True
DISPLAY_TAGS_ON_MENU = True
STATIC_PATHS = ['images', 'extra'] 
# End pelican-twitchy specific settings

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (('Pelican', 'http://getpelican.com/'),
         ('Python.org', 'http://python.org/'),
         ('Jinja2', 'http://jinja.pocoo.org/'),
         ('You can modify those links in your config file', '#'),)

# Social widget
#SOCIAL = (('You can add links in your config file', '#'),
#          ('Another social link', '#'),)

DEFAULT_PAGINATION = False

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True

# Typogrify
TYPOGRIFY = True

# For better_codeblock_line_numbering plugin
MD_EXTENSIONS = [
    'codehilite(css_class=highlight,linenums=False)',
    'extra'
    ]
