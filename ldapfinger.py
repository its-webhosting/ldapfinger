#!/usr/bin/env python

## NEEDS:
## pip install python-ldap

import sys
if (len(sys.argv)==1):
    print("Usage: %s uid/group" % sys.argv[0])
    print("")
    exit(1)

#import pprint
#pp = pprint.PrettyPrinter(indent=4)

import ldap
con = ldap.initialize('ldap://ldap.umich.edu')
con.protocol_version = ldap.VERSION3
#con.simple_bind_s("cn=admin,dc=example,dc=com", "my_password")
con.simple_bind_s()

def printbarrdn(r, k):
    try:
        barr=r[k]
        for b in barr:
            for s in str(b, 'utf-8').split(" $ "):
                print("              ", twosig(s) )
    except:
        pass

def printbarr(r, k):
    try:
        barr = r[k]
        for b in barr:
            for s in str(b, 'utf-8').split(" $ "):
                print("              ", s )
    except:
        pass

def twosig(dn):
	adsn = dn.split(",")
	outstr = (adsn[0].split("=", 2))[1];
	outstr += ", " + (adsn[1].split("=", 2))[1];
	return outstr

ldap_base = "dc=umich,dc=edu"

import re
mu = re.match('^\s*([a-z]{3,8})\s*$', sys.argv[1])
mg = re.match('^\s*([a-z._\- ]{3,})\s*$', sys.argv[1])

if ( mu ):
    result = con.search_s( ldap_base, ldap.SCOPE_SUBTREE, "(uid=%s)" % mu.group(1) )

    #pp.pprint(result)

    for r in result[0]:
        if (isinstance(r, str)):
            print( twosig(r) )

        if (isinstance(r,dict)):
            print(" Also Known As:")
            printbarr(r, "cn")

            print(" Affiliation:")
            printbarr(r, "ou")

            print(" E-Mail Address:")
            printbarr(r, "mail")

            print(" U of M Phone:")
            printbarr(r, "telephoneNumber")

            print(" U of M Address:")
            printbarr(r, "umichPostalAddress")

            print(" Title:")
            printbarr(r, "umichTitle")

            print(" Uniqname:")
            printbarr(r, "uid")

            print(" Favorite Beverage:")
            printbarr(r, "drink")

            print("")

elif ( mg ):
    result = con.search_s( ldap_base, ldap.SCOPE_SUBTREE, "(cn=%s)" % mg.group(1).replace('.', ' ') )

    #pp.pprint(result)

    for r in result[0]:
        if (isinstance(r, str)):
            print( twosig(r) )

        if (isinstance(r,dict)):
            print(" Also Known As:")
            printbarr(r, "cn")

            print(" Owner:")
            printbarrdn(r, "owner")

            print(" Requests To:")
            printbarr(r, "requestsTo")

            print(" Associated Domain:")
            printbarr(r, "")

            print(" Suppress 'No E-Mail Address' Errors:")
            printbarr(r, "suppressNoEmailError")

            print(" Others May Join:")
            printbarr(r, "joinable")

            print(" Directory Members:")
            printbarrdn(r, "umichDirectMember")

            print("")

