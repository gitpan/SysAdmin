
package SysAdmin::Expect;
use strict;

use SysAdmin;
use Expect;

use vars qw(@ISA $VERSION);

our @ISA = qw(SysAdmin);    # inherits from SysAdmin
our $VERSION = 0.01;

sub new {
	my $class = shift;
	
	my %attr = @_;
	
	###
	## Supported Attribute List
	#
	# SERVER = Network Element to connect to.
	# LOG = Show log in Standard Output
	# LOGFILE = Local File to store Expect interaction
	#
	##
	###
	
	if(!$attr{"SERVER"}){
		print "SERVER Key variable is empty!";
		exit 1;
	}
	
	my $logfile_output = undef;
	
	if($attr{"LOGFILE"}){
		$logfile_output = $attr{"LOGFILE"};
	}
	
	my $self = {
		_telnetServer => $attr{"SERVER"}
		_logStdout => $attr{"LOG"} || 0,
		_logFile => $logfile_output
	};
	    
	bless $self, $class;
	return $self;
}

1;
__END__

=head1 NAME

SysAdmin::Expect - Perl Expect class wrapper module..

=head1 SYNOPSIS

  use SysAdmin::Expect;
  
  my $expect_object = new SysAdmin::Expect(SERVER => "localhost");

=head1 DESCRIPTION

This is a sub class of SysAdmin. It was created to harness Perl Objects and keep
code abstraction to a minimum. This class acts as a master class for Expect
objects.

SysAdmin::Expect uses Expect.pm to interact with network equipment.

=head2 EXPORT

=head1 SEE ALSO

Expect.pm - Expect for Perl
SysAdmin::Expect::Occam - OO interface to interact with Occam equipment.

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE


This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
