#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'xenith'
SITENAME = u'OpSech.io'
SITEURL = ''

PATH = 'content'
PLUGIN_PATHS = ["../pelican-plugins"] 
PLUGINS = ["better_code_samples","better_codeblock_line_numbering"]

TIMEZONE = 'America/New_York'

DEFAULT_LANG = u'en'

#THEME = 'pelican-blueidea'
THEME = 'pelican-twitchy'

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
SOCIAL = (('You can add links in your config file', '#'),
          ('Another social link', '#'),)

DEFAULT_PAGINATION = False

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True

# Typogrify
TYPOGRIFY = True


PYGMENTS_STYLE = "monokai"
BOOTSTRAP_THEME = "slate"
