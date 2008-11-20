#!/usr/local/bin/perl
use strict;

use SysAdmin::SNMP;

my $sysName = '.1.3.6.1.2.1.1.5.0';
my $ifDescr = '.1.3.6.1.2.1.2.2.1.2';

my $object = new SysAdmin::SNMP("192.168.1.1","public");

my $snmp_string = $object->snmpget($sysName);
my $snmp_hash_ref = $object->snmpwalk($ifDescr);

print "SNMP String $snmp_string\n";

foreach my $key ( sort keys %$snmp_hash_ref){
	
	my $value = $$snmp_hash_ref{$key};
	print "Key $key, Value $value\n";
}
