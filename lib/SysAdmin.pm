package SysAdmin;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.08';

1;
__END__

=head1 NAME

SysAdmin - Parent class for SysAdmin wrapper modules.

=head1 SYNOPSIS

  ###
  ## Using the Net::SMTP/MIME::Lite wrapper module
  ###
  
  use SysAdmin::SMTP;
	
  my $smtp_object = new SysAdmin::SMTP("localhost");
	
  my $from_address = qq("Test User" <test_user\@test.com>);
  my $subject = "Test Subject";
  my $message_body = "Test Message";
  my $email_recipients = ["test_receiver\@test.com"];
	
  $smtp_object->sendEmail("FROM"    => "$from_address",
                          "TO"      => "$email_recipients",
                          "SUBJECT" => "$subject",
                          "BODY"    => "$message_body");
  
  ---
	
  ###
  ## Using the Net::SNMP wrapper module
  ###
	
  use SysAdmin::SNMP;
	
  my $ip_address = "192.168.1.1";
  my $community  = "public";
	
  my $snmp_object = new SysAdmin::SNMP(IP        => "$ip_address",
                                       COMMUNITY => "$community");
				  
  my $sysName = '.1.3.6.1.2.1.1.5.0';
	
  my $query_result = $snmp_object->snmpget("$sysName");
	
  print "$ip_address\'s System Name is $query_result\n";

  ---
	
  ###
  ## Using the DBD::Pg wrapper module
  ###
	
  use SysAdmin::DB::Pg;
	
  my $db = "dbd_test";
  my $username = "dbd_test";
  my $password = "dbd_test";
  my $host = "localhost";
  my $port = '5432';
	
  ### Database Table
  ##
  # create table status(
  # id serial primary key,
  # description varchar(25) not null);
  ##
  ###
	
  my $dbd_object = new SysAdmin::DB::Pg("DB"          => "$db",
                                        "DB_USERNAME" => "$username",
                                        "DB_PASSWORD" => "$password",
                                        "DB_HOST"     => "$host",
                                        "DB_PORT"     => "$port");
	
  ## Select Table Data
	
  ## SQL select statement
  my $select_table = qq(select id,description from status);
	
  ## Fetch table data with "fetchTable"
  my $table_results = $dbd_object->fetchTable("$select_table");
	
  ## Extract table data from $table_results array reference
  foreach my $row (@$table_results) {
	
  	my ($db_id,$db_description) = @$row;
	
	## Print Results
	print "DB_ID $db_id, DB_DESCRIPTION $db_description\n";
	
  }

  ### Insert Data
	
  ## SQL Insert statement
  my $insert_table = qq(insert into status (description) values (?));
	
  ## Insert Arguments, to subsitute "?"
  my @insert_table_values = ("Data");
	
  ## Insert data with "insertData"
  $dbd_object->insertData("$insert_table",\@insert_table_values);
  
  ## The insertData Method could also be expressed the following ways
  
  my $insert_table_values = ["Data"];
  $dbd_object->insertData("$insert_table",$insert_table_values);
  
  # or
  
  $dbd_object->insertData("$insert_table",["Data"]);
	
  ### Select Table Row
	
  ## SQL Stament to fetch last insert
  my $fetch_last_insert = qq(select description 
                             from status 
                             where description = 'Data');
	
  ## Fetch table row with "fetchRow"
  my $row_results = $object->fetchRow("$fetch_last_insert");
	
  ## Print Results
  print "Last Insert: $row_results\n";
  
  ---
	
  ###
  ## Using the IO::File wrapper module
  ###
	
  use SysAdmin::File;
	
  ## Declare file object
  my $file_object = new SysAdmin::File("/tmp/test.txt");
	
  ## Read file and dump contents to array reference
  my $array_ref = $file_object->readFile();
	
  foreach my $row (@$array_ref){
	print "Row $row\n";
  }
  
  ## Write to file
  my @file_contents = ("First Line", "Second Line");
  $file_object->writeFile(\@file_contents);
	
  ## Append file
  my @file_contents_append = ("Third Line", "Fourth Line");
  $file_object->appendFile(\@file_contents_append);
	
  ## Check File Exist
  my $file_exist = $file_object->fileExist();
	
  if($file_exist){
  	print "File exists\n";
  }
	
  ## Declare directory object
  my $directory_object = new SysAdmin::File("/tmp");
	
  ## Check Directory Exist
  my $directory_exist = $directory_object->directoryExist();
	
  if($directory_exist){
	print "Directory exists\n";
  }

=head1 DESCRIPTION

This is a master class for SysAdmin wrapper modules. Example SysAdmin modules 
are SysAdmin::DB, SysAdmin::Expect, SysAdmin::SMTP, etc.

=head1 SEE ALSO

SysAdmin::DB

SysAdmin::Expect

SysAdmin::File

SysAdmin::SMTP

SysAdmin::SNMP

=head1 AUTHOR

Miguel A. Rivera 

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
