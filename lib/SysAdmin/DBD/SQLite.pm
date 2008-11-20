
package SysAdmin::DBD::SQLite;
use strict;

use SysAdmin::DBD;
use DBI;

use vars qw(@ISA $VERSION);

our @ISA = qw(SysAdmin::DBD);    # inherits from SysAdmin::DBD
our $VERSION = 0.01;

sub fetchTable {

	my ($self,$db_select) = @_;
	
	my $db_database = $self->{_db};
	
	my $table = undef;
	
	if($db_select){
		if($db_select =~ /select\s.*/i){

			use DBI;
			
			my $dbh = DBI->connect("dbi:SQLite:$db_database") or die "Could not connect to $db_database";
			my $sth = $dbh->prepare($db_select) or die "Couldn't prepare statement!!!";
			$sth->execute() or die "Cannot execute statement!!!";
			
			$table = $sth->fetchall_arrayref;
			
			$dbh->disconnect;
			
			return $table;
		}
	}

}

sub fetchRow {
	
	my ($self,$db_select) = @_;
	
	my $db_database = $self->{_db};
	
	my $row = undef;
	
	if($db_select){
		if($db_select =~ /select\s.*/i){

			use DBI;
			
			my $dbh = DBI->connect("dbi:SQLite:$db_database") or die "Could not connect to $db_database";
			
			$row = $dbh->selectrow_array("$db_select");
			
			$dbh->disconnect;
		}
	}
	
	return $row;
}

sub insertData {
	
	my ($self,$db_insert,$attributes_ref) = @_;
	
	## $attributes_ref must not be empty!!!
	
	my $db_database = $self->{_db};
	
	if($db_insert){
		if($db_insert =~ /insert\s.*/i){
			
			my $attributes_ref_length = @$attributes_ref;
				
			if($attributes_ref_length != 0){

				use DBI;
				
				my $dbh = DBI->connect("dbi:SQLite:$db_database") or die "Could not connect to $db_database";
				my $sth = $dbh->prepare($db_insert) or die ("Couldn't prepare statement!!!");
				$sth->execute(@$attributes_ref) or die ("Cannot execute statement!!!");
				
				$dbh->disconnect;
				
			}
		}
	}
}

sub deleteData {
	
	my ($self,$db_delete,$attributes_ref) = @_;
	
	## $attributes_ref must not be empty!!!
	
	my $db_database = $self->{_db};
	
	if($db_delete){
		if($db_delete =~ /delete\s.*/i){
			
			my $attributes_ref_length = @$attributes_ref;
				
			if($attributes_ref_length != 0){

				use DBI;
				
				my $dbh = DBI->connect("dbi:SQLite:$db_database") or die "Could not connect to $db_database";
				my $sth = $dbh->prepare($db_delete) or die "Couldn't prepare statement!!!";
				$sth->execute(@$attributes_ref) or die "Cannot execute statement!!!";
				
				$dbh->disconnect;
			}
		}
	}
}

1;
__END__

=head1 NAME

SysAdmin::DBD::SQLite - Perl DBD class wrapper module.

=head1 SYNOPSIS

  use SysAdmin::DBD::SQLite;
  
  my $db = "/tmp/dbd_test.db";
  
  ### Database Table
  ##
  # create table status(
  # id serial primary key,
  # description varchar(25) not null);
  ##
  ###
  
  my $dbd_object = new SysAdmin::DBD::SQLite("DB" => "$db");

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

  ## Insert Data
  
  ## SQL Insert statement
  my $insert_table = qq(insert into status (description) values (?));
  
  ## Insert Arguments, to subsitute "?"
  my @insert_table_values = ("Seventh");
  
  ## Insert data with "insertData"
  $dbd_object->insertData("$insert_table",\@insert_table_values);
  
  ## Select Table Row

  ## SQL Stament to fetch last insert
  my $fetch_last_insert = qq(select description 
	                     from status 
	                     where description = 'Seventh');

  ## Fetch table row with "fetchRow"
  my $row_results = $object->fetchRow("$fetch_last_insert");

  ## Print Results
  print "Last Insert: $row_results\n";

=head1 DESCRIPTION

This is a sub class of SysAdmin. It was created to harness Perl Objects and keep
code abstraction to a minimum. This class acts as a sub class for DBD
objects.

SysAdmin::DBD::SQLite uses DBI and DBD::SQLite to interact with database.

=head2 EXPORT

=head1 SEE ALSO

DBI - Database independent interface for Perl
DBD::Pg - PostgreSQL database driver for the DBI module
DBD::MySQL - MySQL driver for the Perl5 Database Interface (DBI)
DBD::SQLite - Self Contained RDBMS in a DBI Driver

SysAdmin::DBD::MySQL - OO interface to interact with MySQL Databases.
SysAdmin::DBD::Pg - OO interface to interact with PostgreSQL Databases.

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
