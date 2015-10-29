#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Mike'
SITENAME = u'#> opsech.io'
SITEURL = ''
SITESUBTITLE = "Random wanderings of a Linux traveller"

PATH = 'content'
PLUGIN_PATHS = ["../pelican-plugins"] 
PLUGINS = ["better_codeblock_line_numbering","better_figures_and_images"]
CHECK_MODIFIED_METHOD = "mtime"
TIMEZONE = 'America/New_York'
DEFAULT_LANG = u'en'

ARTICLE_URL = 'posts/{date:%Y}/{date:%b}/{date:%d}/{slug}.html'
ARTICLE_SAVE_AS = 'posts/{date:%Y}/{date:%b}/{date:%d}/{slug}.html'
PAGE_URL = 'pages/{slug}.html'
PAGE_SAVE_AS = 'pages/{slug}.html'
NEWEST_FIRST_ARCHIVES = True
FIGURE_NUMBERS = True
RESPONSIVE_IMAGES = True
#THEME = 'pelican-blueidea'
# https://github.com/ingwinlu/pelican-twitchy
THEME = 'pelican-twitchy'
PYGMENTS_STYLE = "monokai"
BOOTSTRAP_THEME = "slate"
SHARE = True
CUSTOM_CSS = "extra/custom.css"
SOCIAL = (('Bitbucket','https://bitbucket.org/xenithorb'), 
	('Github','https://github.com/xenithorb'))
EXPAND_LATEST_ON_INDEX = True
DISQUS_LOAD_LATER = True
DISPLAY_TAGS_ON_MENU = False
DISPLAY_RECENT_POSTS_ON_MENU = True
STATIC_PATHS = ['images', 'extra'] 
# End pelican-twitchy specific settings

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

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
