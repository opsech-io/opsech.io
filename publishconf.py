#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

# This file is only used if you use `make publish` or
# explicitly specify it as your config file.

import os
import sys
sys.path.append(os.curdir)
from pelicanconf import *

SITEURL = 'https://opsech.io'
RELATIVE_URLS = False

FEED_ALL_ATOM = 'feeds/all.atom.xml'
FEED_ALL_RSS = 'feeds/all.rss.xml'
CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'
CATEGORY_FEED_RSS = 'feeds/%s.rss.xml'

DELETE_OUTPUT_DIRECTORY = True
DISQUS_SITENAME = "opsech"

PIWIK_URL = '//opsech-io.piwik.pro/'
PIWIK_SITE_ID = 1

# Below is for making sure that only "Status: published" articles go live.
DEFAULT_METADATA = {
	'Status':'draft',
	}
