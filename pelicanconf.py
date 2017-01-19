#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Mike'
SITENAME = u'#> opsech.io'
SITEURL = u''
# SITEURL = u'https://opsech.io'
SITESUBTITLE = u'Random wanderings of a Linux traveller'

PATH = 'content'
PLUGIN_PATHS = ["plugins/pelican-plugins"]
STATIC_PATHS = ['images', 'extra', 'favs']
IGNORE_FILES = ['*.swp', '*.kate-swp']
PLUGINS = ["better_codeblock_line_numbering"]
CHECK_MODIFIED_METHOD = "mtime"
TIMEZONE = 'America/New_York'
DEFAULT_LANG = u'en'

ARTICLE_URL = 'posts/{date:%Y}/{date:%b}/{date:%d}/{slug}.html'
ARTICLE_SAVE_AS = 'posts/{date:%Y}/{date:%b}/{date:%d}/{slug}.html'
PAGE_URL = 'pages/{slug}.html'
PAGE_SAVE_AS = 'pages/{slug}.html'
NEWEST_FIRST_ARCHIVES = True
# FIGURE_NUMBERS = True
RESPONSIVE_IMAGES = True

# https://github.com/ingwinlu/pelican-twitchy
THEME = 'themes/pelican-twitchy'
PYGMENTS_STYLE = "monokai"
BOOTSTRAP_THEME = "slate"
SHARE = True
CUSTOM_CSS = "extra/custom.css"
SOCIAL = (
    ('Bitbucket', 'https://bitbucket.org/xenithorb'),
    ('Github', 	  'https://github.com/xenithorb'),
    ('Gitlab',    'https://gitlab.com/xenithorb'),
    ('Email', 'mailto:mike=at=opsech.io'),
)
EXPAND_LATEST_ON_INDEX = True
DISQUS_LOAD_LATER = True
DISPLAY_TAGS_ON_MENU = True
DISPLAY_RECENT_POSTS_ON_MENU = True
CC_LICENSE = "CC-BY-NC-SA"
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

MARKDOWN = {
    'extension_configs': {
        'markdown.extensions.codehilite': {
            'css_class': 'highlight',
            'linenums': False
        }
    }
}
