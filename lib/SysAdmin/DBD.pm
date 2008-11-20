
package SysAdmin::DBD;
use strict;

use SysAdmin;

use vars qw(@ISA $VERSION);

our @ISA = qw(SysAdmin);    # inherits from SysAdmin
our $VERSION = 0.01;

sub new {
	my $class = shift;
	
	my %attr = @_;
	
	###
	## Supported Attribute List
	#
	# DB = DataBase
	# DB_USERNAME = DataBase Username
	# DB_PASSWORD = DataBase Password
	# DB_HOST = DataBase Host
	# DB_PORT = DataBase Port
	#
	##
	###
	
	if(!$attr{"DB"}){
		print "DB Key variable is empty!";
		exit 1;
	}
	
	my $self = {
		_db          => $attr{"DB"},
		_db_username => $attr{"DB_USERNAME"},
		_db_password => $attr{"DB_PORT"},
		_db_host     => $attr{"DB_HOST"} || "localhost",
		_db_port     => $attr{"DB_PORT"},
	};
	    
	bless $self, $class;
	return $self;
}

1;
__END__

=head1 NAME

SysAdmin::DBD - Perl DBD class wrapper module..

=head1 SYNOPSIS

  use SysAdmin::DBD;
  
  my $db = "dbd_test";
  my $username = "dbd_test";
  my $password = "dbd_test";
  my $host = "localhost";
  my $port = '5432';
  
  my $dbd_object = new SysAdmin::DBD("DB"          => "$db",
                                     "DB_USERNAME" => "$username",
				     "DB_PASSWORD" => "$password",
				     "DB_HOST"     => "$host",
				     "DB_PORT"     => "$port");

=head1 DESCRIPTION

This is a sub class of SysAdmin. It was created to harness Perl Objects and keep
code abstraction to a minimum. This class acts as a master class for DBD
objects.

SysAdmin::DBD uses perl's DBI and DBD to interact with database.

=head2 EXPORT

=head1 SEE ALSO

DBI - Database independent interface for Perl
DBD::Pg - PostgreSQL database driver for the DBI module
DBD::MySQL - MySQL driver for the Perl5 Database Interface (DBI)
DBD::SQLite - Self Contained RDBMS in a DBI Driver

SysAdmin::DBD::MySQL - OO interface to interact with MySQL Databases.
SysAdmin::DBD::Pg - OO interface to interact with PostgreSQL Databases.
SysAdmin::DBD::SQLite - OO interface to interact with SQLite Databases.

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
