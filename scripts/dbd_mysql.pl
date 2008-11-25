#!/usr/local/bin/perl
use strict;

use DBI;
use SysAdmin::DB;

my $db = "dbdtest";
my $username = "dbdtest";
my $password = "dbdtest";
my $host = "localhost";
my $port = '3306';
my $driver = "mysql";

=pod

create table status(
id serial primary key,
description varchar(25) not null);

=cut

my $dbd_object = new SysAdmin::DB("DB"          => "$db",
                                  "DB_USERNAME" => "$username",
                                  "DB_PASSWORD" => "$password",
                                  "DB_HOST"     => "$host",
                                  "DB_PORT"     => "$port",
                                  "DB_DRIVER"   => "$driver");

my $select_table = qq(select id,description from status);

my $table_results = $dbd_object->fetchTable("$select_table");

foreach my $row (@$table_results) {

	my ($db_id,$db_description) = @$row;
	
	print "DB_ID $db_id, DB_DESCRIPTION $db_description\n";
	
}

my $insert_table = qq(insert into status (description) values (?));
my @insert_table_values = ("First");

my $last_id = $dbd_object->insertData("$insert_table",\@insert_table_values);

print "Last ID $last_id\n";

my $fetch_last_insert = qq(select description 
	                   from status 
	                   where description = 'First');

my $insert_results = $dbd_object->fetchRow("$fetch_last_insert");

print "Last Insert: $insert_results\n";

my $update_table = qq(update status set description = ? where description = ?);
my @update_table_values = ("Second","First");

$dbd_object->updateData("$update_table",\@update_table_values);

my $fetch_last_update = qq(select description 
	                   from status 
	                   where description = 'Second');

my $update_results = $dbd_object->fetchRow("$fetch_last_update");

print "Last Update: $update_results\n";
