Title: Searching through $PATH commands with compgen
Category: quick-tips
Tags: bash, tips
Slug: list-path-with-compgen
Summary: Learn how to list your bash $PATH with compgen
Date: Mon Nov  2 10:31:27 EST 2015
Status: published

Ever wondered how to get a list of what your bash tab-completion will output?

I tend to find this most useful when I have a brain failure and can't remember what I'm looking for. Searching
through your tab-completion with regex can be useful:

```bash
# get a raw list of tab-complete commands and search through them yourself
compgen -c | egrep "<some_regex>"

# Analogous to `compgen -c | grep "^<word>"`
# List commands that begin with <word>
compgen -c <word>

# List bash built-ins
compgen -b

# List all environment functions
compgen -A function

# Bonus! List functions and their source code:
typeset -f [<function_name>]
```
