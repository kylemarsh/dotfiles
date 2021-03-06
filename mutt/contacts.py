#!/usr/bin/env python

import sys
import subprocess

import AddressBook as AB

# get a reference to the address book
book = AB.ABAddressBook.sharedAddressBook()

# create search parameters - prefix match on first or last name or email
firstname_search = AB.ABPersonCreateSearchElement(
    AB.kABLastNameProperty, None, None, sys.argv[1],
    AB.kABPrefixMatchCaseInsensitive
)
lastname_search = AB.ABPersonCreateSearchElement(
    AB.kABFirstNameProperty, None, None, sys.argv[1],
    AB.kABPrefixMatchCaseInsensitive
)
email_search = AB.ABPersonCreateSearchElement(
    AB.kABEmailProperty, None, None, sys.argv[1],
    AB.kABContainsSubStringCaseInsensitive
)
name_search = AB.ABSearchElement.searchElementForConjunction_children_(
    AB.kABSearchOr,
    [firstname_search, lastname_search, email_search]
)

# perform the search
matches = book.recordsMatchingSearchElement_(name_search)

# collect results
results = []
for person in matches:
    emails = person.valueForKey_('Email') or []
    company = person.valueForKey_('Organization')
    name = '%s %s' % (
        person.valueForKey_('First'),
        person.valueForKey_('Last')
    ) if person.valueForKey_('First') else company

    for i in range(len(emails)):
        results.append((
            emails.valueAtIndex_(i),
            name
        ))


# sort results
results.sort(lambda x,y: cmp(x[1], y[1]))

# output to stdout in the mutt-preferred style
print 'EMAIL\tNAME'
for result in results:
    print '%s\t%s' % result

# now search using notmuch, if requested
if len(sys.argv) > 2 and sys.argv[2] == 'extended':
    output = subprocess.check_output([
        '.mutt/search-previous-contacts',
        sys.argv[1]
    ])

    # collect the results
    results = []
    for line in output.splitlines():
        if not line: continue
        email, name = line.split(' ', 1)
        results.append((email, name))

    # sort results
    results.sort(lambda x,y: cmp(x[1], y[1]))

    # print them in addition to the address book results
    print '----------------------\t--------------------------'
    for result in results:
        print '%s\t%s' % result
