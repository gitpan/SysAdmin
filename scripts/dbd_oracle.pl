#!/usr/local/bin/perl
use strict;

use SysAdmin::DB;

my $db = "soverdb";
my $username = "fms_bdgav";
my $password = "fms_bdgav01p";
my $host = "192.9.200.125";
my $port = '1521';
my $driver = "Oracle";

my $dbd_object = new SysAdmin::DB("DB"          => "$db",
                                  "DB_USERNAME" => "$username",
                                  "DB_PASSWORD" => "$password",
                                  "DB_HOST"     => "$host",
                                  "DB_PORT"     => "$port",
                                  "DB_DRIVER"   => "$driver");

my $select_table = qq(select CODALERT,NEAFFECTED from NXC_ALERTDETAIL);

my $table_results = $dbd_object->fetchTable("$select_table");

foreach my $row (@$table_results) {

	my ($db_id,$db_description) = @$row;
	
	print "DB_ID $db_id, DB_DESCRIPTION $db_description\n";
	
}
=pod
my $insert_table = qq(insert into status (description) values (?));

my $last_id = $dbd_object->insertData("$insert_table",["First"]);

print "Last ID $last_id\n";

my $fetch_last_insert = qq(select description 
	                   from status 
	                   where description = 'First');

my $insert_results = $dbd_object->fetchRow("$fetch_last_insert");

print "Last Insert: $insert_results\n";

my $update_table = qq(update status set description = ? where description = ?);

$dbd_object->updateData("$update_table",["Second","First"]);

my $fetch_last_update = qq(select description 
	                   from status 
	                   where description = 'Second');

my $update_results = $dbd_object->fetchRow("$fetch_last_update");

print "Last Update: $update_results\n";
=cut
