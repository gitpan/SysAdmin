#!/usr/local/bin/perl
use strict;

use SysAdmin::DBD::Pg;

my $db = "dbd_test";
my $username = "dbd_test";
my $password = "dbd_test";
my $host = "localhost";
my $port = '5432';

=pod

create table status(
id serial primary key,
description varchar(25) not null);

=cut

my $object = new SysAdmin::DBD::Pg("$db","$username","$password","$host","$port");

my $select_table = qq(select id,description from status);

my $table_results = $object->fetchTable("$select_table");

foreach my $row (@$table_results) {

	my ($db_id,$db_description) = @$row;
	
	print "DB_ID $db_id, DB_DESCRIPTION $db_description\n";
	
}

my $insert_table = qq(insert into status (description) values (?));
my @insert_table_values = ("Seventh");

$object->insertData("$insert_table",\@insert_table_values);

my $fetch_last_insert = qq(select description 
	                   from status 
	                   where description = 'Seventh');

my $row_results = $object->fetchRow("$fetch_last_insert");

print "Last Insert: $row_results\n";
