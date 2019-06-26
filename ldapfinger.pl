#!/usr/bin/perl -w

use Net::LDAP;
use Data::Dumper;
use strict;
use warnings;

my $user = '';
my $group = '';
my $DPAD = '              ';

my @gotten = @ARGV;

sub getattr ($ $) {
	my ($attrs, $type) = @_;

	my $rtnval = '';

	foreach my $attr (@{$attrs}) {
		if ($attr->{type} eq $type) {
			foreach my $val (@{$attr->{vals}}) {
				$val = &twosig($val) if ($val =~ m/^.*,dc=umich,dc=edu$/);
				$rtnval .= $DPAD.$val."\r\n";
			}
		}
	}
	return $rtnval;
}

sub twosig($) {
	my $dsn = shift;
	my @adsn = split m/,/, $dsn;
	my $outstr = $1 if ($adsn[0] =~ m/^[^=]+=(.+?)$/);
	$outstr .= ", $1" if ($adsn[1] =~ m/^[^=]+=(.+?)$/);
	return $outstr;
}

if ( @gotten && defined $gotten[0] && ($gotten[0] =~ m/^\s*([a-z]{3,8})\s*$/) ) {
		$user = $1;

		my $ldap;
		if ( $ldap = Net::LDAP->new('ldap.umich.edu') ) {
			my $mesg = $ldap->bind;
			$mesg = $ldap->search (
				base => 'dc=umich,dc=edu',
				filter => "(uid=$user)"
			);
			if (! $mesg->code && $mesg->entries) {
#print Dumper $mesg;
				foreach my $entry ($mesg->entries) {

					my $dsn = $entry->{asn}->{objectName};
					#print $DPAD, &twosig($dsn), "\r\n";
					print '"', &twosig($dsn), '"', "\r\n";

					my $attribs = $entry->{asn}->{attributes};

					print " Also Known As:\r\n";
					print &getattr( $attribs, 'cn' );
					print " Affiliation:\r\n";
					print &getattr( $attribs, 'ou' );
					print " E-Mail Address:\r\n";
					print &getattr( $attribs, 'mail' );
					print " U of M Phone:\r\n";
					print &getattr( $attribs, 'telephoneNumber' );

					## address is an ldap list
					print " U of M Address:\r\n";
					my $bizaddr = &getattr( $attribs, 'umichPostalAddress' );
					$bizaddr =~ s/ \$ /\r\n$DPAD/g;
					print $bizaddr;

					print " Title:\r\n";
					print &getattr( $attribs, 'umichTitle' );
					print " Uniqname:\r\n";
					print &getattr( $attribs, 'uid' );
					print " Favorite Beverage:\r\n";
					print &getattr( $attribs, 'drink' );
					print "\r\n";

				}
			}
			$mesg = $ldap->unbind;
		}
}

if ( @gotten && defined $gotten[0] && ($gotten[0] =~ m/^\s*([a-z._\- ]{3,})\s*$/) ) {
		$group = $1;
		$group =~ s/\./ /g;

		my $ldap;
		if ( $ldap = Net::LDAP->new('ldap.umich.edu') ) {
			my $mesg = $ldap->bind;
			$mesg = $ldap->search (
				base => 'dc=umich,dc=edu',
				filter => "(cn=$group)"
			);
			if (! $mesg->code && $mesg->entries) {
				foreach my $entry ($mesg->entries) {

	#print Dumper $entry;
					my $dsn = $entry->{asn}->{objectName};
	#print "DSN: $dsn\n";
					#print $DPAD, &twosig($dsn), "\r\n";
					print '"', &twosig($dsn), '"', "\r\n";

					my $attribs = $entry->{asn}->{attributes};

					print " Also Known As:\r\n";
					print &getattr( $attribs, 'cn' );
					print " Owner:\r\n";
					print &getattr( $attribs, 'owner' );
					print " Requests To:\r\n";
					print &getattr( $attribs, 'requestsTo' );
					print " Associated Domain:\r\n";
					print &getattr( $attribs, '' );
					print " Suppress 'No E-Mail Address' Errors:\r\n";
					print &getattr( $attribs, 'suppressNoEmailError' );
					print " Others May Join:\r\n";
					print &getattr( $attribs, 'joinable' );
					print " Directory Members:\r\n";
					print &getattr( $attribs, 'umichDirectMember' );
					print "\r\n";

				}
			}
			$mesg = $ldap->unbind;
		}
}
