
package SysAdmin::DB;
use strict;

use SysAdmin;
use Carp;
use locale;
use DBI;

use vars qw(@ISA $VERSION);

our @ISA = qw(SysAdmin);    # inherits from SysAdmin
our $VERSION = 0.06;

sub new {
	my $class = shift;
	
	my %attr = @_;
	
	###
	## Supported Attribute List
	#
	# DB = DataBase
	# DB_USERNAME = DataBase Username
	# DB_PASSWORD = DataBase Password
	# DB_HOST     = DataBase Host
	# DB_PORT     = DataBase Port
	# DB_DRIVER   = DBD driver to use
	#
	##
	###
	
	Carp::croak "## WARNING ##\n No \"DB\" value supplied! Please, state value for proper connection to DataBase." unless $attr{"DB"};
	Carp::croak "## WARNING ##\n No \"DB_DRIVER\" value supplied! Please, state value for proper connection to DataBase." unless $attr{"DB_DRIVER"};
	
	## Convert user input to lower case, to better match conditionals.
	my $check_db_driver_to_use = lc($attr{"DB_DRIVER"});
	
	## State DBD driver value to pass to $self
	my $db_driver_to_use = undef;
	
	## In case $attr{"DB_PORT"} is empty
	my $port_to_use = "";
	
	if($check_db_driver_to_use eq "pg"){
		$port_to_use = "5432";
		$db_driver_to_use = "Pg";
	}
	if($check_db_driver_to_use eq "mysql"){
		$port_to_use = "3306";
		$db_driver_to_use = "mysql";
	}
	if($check_db_driver_to_use eq "sqlite"){
		$db_driver_to_use = "SQLite";
	}
	if($check_db_driver_to_use eq "oracle"){
		$db_driver_to_use = "Oracle";
	}
	
	my $self = {
		_db             => $attr{"DB"},
		_db_username    => $attr{"DB_USERNAME"},
		_db_password    => $attr{"DB_PASSWORD"},
		_db_host        => $attr{"DB_HOST"} || "localhost", ## If empty
		_db_port        => $attr{"DB_PORT"} || $port_to_use,
		_db_driver      => $db_driver_to_use
	};
	    
	bless $self, $class;
	return $self;
}

sub fetchTable {

	my ($self,$db_select) = @_;
	
	my $db_database    = $self->{_db};
	my $db_username    = $self->{_db_username};
	my $db_password    = $self->{_db_password};
	my $db_host        = $self->{_db_host};
	my $db_port        = $self->{_db_port};
	my $db_driver      = $self->{_db_driver};
	
	my $table = undef; ## For return value
	
	## If $db_select is defined
	if($db_select){
		
		## Converts to lower case to verify if its a SELECT SQL statement.
		if($db_select =~ /select\s.*/i){
			
			##
			## Mostly taken from DBI/DBD module examples. 
			## Works in most DB table extractions.
			##
			
			my $dbh = undef;
			
			if($db_driver eq "SQLite"){
				$dbh = DBI->connect("dbi:SQLite:$db_database",{ AutoCommit => 1 }) or die "Could not connect to $db_database";
			}
			if($db_driver eq "Oracle"){
				$dbh = DBI->connect("dbi:Oracle:$db_database", $db_username,$db_password);
			}
			else{
				## MySQL and PostgreSQL use similar syntax
				$dbh = DBI->connect("dbi:$db_driver:dbname=$db_database;host=$db_host;port=$db_port;","$db_username","$db_password") or die "Could not connect to $db_database";
			}
			
			my $sth = $dbh->prepare($db_select) or die "Couldn't prepare statement!!!";
			$sth->execute() or die ("Cannot execute statement!!!");
			
			$table = $sth->fetchall_arrayref;
			
			$sth->finish;
			
			if($db_driver ne "SQLite"){
				$dbh->disconnect;
			}
		}
	}
	return $table;
}

sub fetchRow {
	
	my ($self,$db_select) = @_;
	
	my $db_database    = $self->{_db};
	my $db_username    = $self->{_db_username};
	my $db_password    = $self->{_db_password};
	my $db_host        = $self->{_db_host};
	my $db_port        = $self->{_db_port};
	my $db_driver      = $self->{_db_driver};
	
	my $row = undef; ## For return value
	
	## If $db_select is defined
	if($db_select){
		
		## Converts to lower case to verify if its a SELECT SQL statement.
		if($db_select =~ /select\s.*/i){
			
			##
			## Mostly taken from DBI/DBD module examples. 
			## Works in most DB table extractions.
			##
			
			my $dbh = undef;
			
			if($db_driver eq "SQLite"){
				$dbh = DBI->connect("dbi:SQLite:$db_database",{ AutoCommit => 1 }) or die "Could not connect to $db_database";
			}
			if($db_driver eq "Oracle"){
				$dbh = DBI->connect("dbi:Oracle:$db_database", $db_username,$db_password);
			}
			else{
				## MySQL and PostgreSQL use similar syntax
				$dbh = DBI->connect("dbi:$db_driver:dbname=$db_database;host=$db_host;port=$db_port;","$db_username","$db_password") or die "Could not connect to $db_database";
			}
			
			$row = $dbh->selectrow_array("$db_select");
			
			if($db_driver ne "SQLite"){
				$dbh->disconnect;
			}
		}
	}
	return $row;
}

## Find better name
sub _manipulateData {
	
	my ($self,$db_insert,$attributes_ref) = @_;
	
	## $attributes_ref must not be empty!!!
	
	my $db_database    = $self->{_db};
	my $db_username    = $self->{_db_username};
	my $db_password    = $self->{_db_password};
	my $db_host        = $self->{_db_host};
	my $db_port        = $self->{_db_port};
	my $db_driver      = $self->{_db_driver};
	
	## If $db_select is defined
	if($db_insert){
		
		## Converts to lower case to verify if its a INSERT/UPDATE/DELETE SQL statement.
		if(($db_insert =~ /insert\s.*/i) || ($db_insert =~ /update\s.*/i) || ($db_insert =~ /delete\s.*/i)){
			
			## Assumes using "?" for attribute substitution.
			my $attributes_ref_length = @$attributes_ref;
				
			if($attributes_ref_length != 0){
				
				##
				## Mostly taken from DBI/DBD module examples. 
				## Works in most DB table extractions.
				##
				
				my $dbh = undef;
				## Return ID of last insert
				my $last_id_inserted = undef;
				my $rv = undef;
				
				if($db_driver eq "SQLite"){
					$dbh = DBI->connect("dbi:SQLite:$db_database",{ AutoCommit => 0 }) or die "Could not connect to $db_database";
				}
				if($db_driver eq "Oracle"){
					$dbh = DBI->connect("dbi:Oracle:$db_database", $db_username,$db_password,{ AutoCommit => 1 });
				}
				else{
					## MySQL and PostgreSQL use similar syntax
					$dbh = DBI->connect("dbi:$db_driver:dbname=$db_database;host=$db_host;port=$db_port;",
						             "$db_username","$db_password",
							     { RaiseError => 0, AutoCommit => 1 }) or die "Could not connect to $db_database";
				}
				eval {
					my $sth = $dbh->prepare($db_insert) or die "Couldn't prepare statement!!!";
					$sth->execute(@$attributes_ref) or die "Cannot execute statement!!!";
					
					if($db_insert =~ /insert into (\w+)\s.*/i){
						$last_id_inserted = &_fetchLastId($self,$dbh,$1);
					}
					
					$sth->finish;
				};
				
				if ($@) {
					$dbh->rollback();
					die $@;
				}
				
				if($db_driver ne "SQLite"){
					$dbh->disconnect;
				}
				
				return $last_id_inserted;
			}
		}
	}
}

sub insertData {
	
	my ($self,$db_insert,$attributes_ref) = @_;
	
	&_manipulateData($self,$db_insert,$attributes_ref);
}

sub updateData {
	
	my ($self,$db_update,$attributes_ref) = @_;
	
	&_manipulateData($self,$db_update,$attributes_ref);
}

sub deleteData {
	
	my ($self,$db_delete,$attributes_ref) = @_;
	
	&_manipulateData($self,$db_delete,$attributes_ref);
}

sub _fetchLastId {
	my ($self,$dbh,$db_table) = @_;
	
	my $db_driver = $self->{_db_driver};
	
	my $last_insert_id = undef;
	
	if($db_driver eq "Pg"){
		$last_insert_id = $dbh->last_insert_id(undef,undef,"$db_table",undef);
	}
	if($db_driver eq "mysql"){
		$last_insert_id = $dbh->last_insert_id(undef,undef,"$db_table",undef);
	}
	if($db_driver eq "SQLite"){
		$last_insert_id = $dbh->last_insert_id(undef,undef,"$db_table",undef);
	}
	if($db_driver eq "Oracle"){
		$last_insert_id = $dbh->last_insert_id(undef,undef,"$db_table",undef);
	}
	if($db_driver ne "SQLite"){
		$dbh->disconnect;
	}
	
	return $last_insert_id;
}

sub close {
	my ($self) = @_;
	
	$self->{_db} = undef;
	$self->{_db_username} = undef;
	$self->{_db_password} = undef;
	$self->{_db_host} = undef;
	$self->{_db_port} = undef;
	$self->{_db_driver} = undef;
	$self->{_need_user_pass} = undef;
}

1;
__END__

=head1 NAME

SysAdmin::DB - Perl DBI/DBD wrapper module..

=head1 SYNOPSIS

  ## Example using PostgreSQL Database
	
  use SysAdmin::DB;
	
  my $db = "dbd_test";
  my $username = "dbd_test";
  my $password = "dbd_test";
  my $host = "localhost";
  my $port = '5432';
  my $driver = "pg"; ## Change to "mysql" for MySQL connection
	
  ### Database Table
  ##
  # create table status(
  # id serial primary key,
  # description varchar(25) not null);
  ##
  ###
	
  my $dbd_object = new SysAdmin::DB("DB"          => "$db",
                                    "DB_USERNAME" => "$username",
                                    "DB_PASSWORD" => "$password",
                                    "DB_HOST"     => "$host",
                                    "DB_PORT"     => "$port",
                                    "DB_DRIVER"   => "$driver");
  ###
  ## DB and DB_DRIVER are always required!
  ###
	
  ###
  ## For databases that need username and password (MySQL, PostgreSQL),
  ## DB_USERNAME and DB_PASSWORD are also required
  ###
	
  ### For SQLite, simply declare DB and DB_DRIVER, example:
  ##
  ## my $db = "/tmp/dbd_test.db";
  ## my $dbd_object = new SysAdmin::DB("DB"       => "$db",
  ##                                   "DB_DRIVER => "sqlite");
  ##
  ###
	
	
  ###
  ## Work with "$dbd_object"
  ###
	
  ### Insert Data
	
  ## SQL Insert statement
  my $insert_table = qq(insert into status (description) values (?));
	
  ## Insert Arguments, to subsitute "?"
  my @insert_table_values = ("DATA");
	
  ## Insert data with "insertData"
	
  $dbd_object->insertData("$insert_table",\@insert_table_values);
	
  ## By declaring a variable, it returns the last inserted ID
	
  my $last_insert_id = $dbd_object->insertData("$insert_table",\@insert_table_values);
	
  ## The insertData Method could also be expressed the following ways
  
  my $insert_table_values = ["Data"];
  $dbd_object->insertData("$insert_table",$insert_table_values);
  
  # or
  
  $dbd_object->insertData("$insert_table",["Data"]);
	

  ### Select Table Data
	
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
	
	
  ### Select Table Row
	
  ## SQL Stament to fetch last insert
  my $fetch_last_insert = qq(select description 
                             from status 
                             where id = $last_insert_id);
	
  ## Fetch table row with "fetchRow"
  my $row_results = $object->fetchRow("$fetch_last_insert");
	
  ## Print Results
  print "Last Insert: $row_results\n";
				    

=head1 DESCRIPTION

This is a sub class of SysAdmin. It was created to harness Perl Objects and keep
code abstraction to a minimum.

SysAdmin::DB uses perl's DBI and DBD to interact with database.

Currently DBD::Pg, DBD::mysql and DBD::SQLite are supported.

=head1 METHODS

=head2 C<new()>

	my $dbd_object = new SysAdmin::DB("DB"          => "$db",
                                      "DB_USERNAME" => "$username",
                                      "DB_PASSWORD" => "$password",
                                      "DB_HOST"     => "$host",
                                      "DB_PORT"     => "$port",
                                      "DB_DRIVER"   => "$driver");

Creates SysAdmin::DB object instance. Used to declare the database connection
information.

	"DB" => "$db"

State database name to connect to
	
	"DB_USERNAME" => "$username"
	
State a privileged user to connect to the C<DB> database
	
	"DB_PASSWORD" => "$password",
	
State a privileged user's password to connect to the C<DB> database
	
	"DB_HOST"     => "$host"

State the IP address/Hostname of the database server

	"DB_PORT"     => "$port"
	
State the listening port of the database server. PostgreSQL 5432, MySQL 3306

	"DB_DRIVER"   => "$driver"

State the database driver to use. Currently supported: Pg, mysql and SQLite

=head2 C<insertData()>

	## SQL Insert statement
	my $insert_table = qq(insert into status (description) values (?));
	
	## Insert Arguments, to subsitute "?"
	my @insert_table_values = ("DATA");
	
	## Insert data with "insertData"
	
	$dbd_object->insertData("$insert_table",\@insert_table_values);
	
	## By declaring a variable, it returns the last inserted ID
	
	my $last_insert_id = $dbd_object->insertData("$insert_table",\@insert_table_values);
	
=head2 C<fetchTable()>	

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

=head2 C<fetchRow()>

	## Select Table Row
	
	## SQL Stament to fetch last insert
	my $fetch_last_insert = qq(select description 
                               from status 
                               where id = $last_insert_id);
	
	## Fetch table row with "fetchRow"
	
	my $row_results = $object->fetchRow("$fetch_last_insert");
	
	## Print Results
	print "Last Insert: $row_results\n";

=head1 SEE ALSO

DBI - Database independent interface for Perl
DBD::Pg - PostgreSQL database driver for the DBI module
DBD::MySQL - MySQL driver for the Perl5 Database Interface (DBI)
DBD::SQLite - Self Contained RDBMS in a DBI Driver

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
