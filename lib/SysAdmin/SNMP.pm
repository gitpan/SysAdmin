
package SysAdmin::SNMP;
use strict;

use SysAdmin;
use Net::SNMP;

use vars qw(@ISA $VERSION);

our @ISA = qw(SysAdmin);    # inherits from SysAdmin
our $VERSION = 0.01;

sub new {
	my $class = shift;
	
	my %attr = @_;
	
	###
	## Supported Attribute List
	#
	# IP = Network Element to interact with.
	# COMMUNITY = SNMP Community string.
	#
	##
	###
	
	if(!$attr{"IP"}){
		print "IP Key variable is empty!";
		exit 1;
	}
	
	my $community_string = $attr{"COMMUNITY"};
	
	if(!$community_string){
		$community_string = "public";
		print "COMMUNITY Key variable is empty, using default (public)!";
	}
	
	my $self = {
		_ipAddress      => $attr{"IP"},
		_snmpCommunity  => $community_string
	};
	    
	bless $self, $class;
	return $self;
}

sub snmpwalk {
	
	my ($self, $oid_to_get) = @_;
	
	my $hostname = $self->{_ipAddress};
	my $community = $self->{_snmpCommunity};
	
	my ($session, $error) = Net::SNMP->session(Hostname => $hostname, Community => $community);
	
	my $response = "NA";
	my %hash_to_return_from_sub = ();
	
	if (!defined($session)) { 
		print("## Cant open device.\n");
		exit 1;
	}
	if (!defined($response = $session->get_table($oid_to_get))) {
		printf("## %s\n", $session->error);
		$session->close;
		exit 1;
	}
	
	if (ref($response) ne 'HASH') {
		die "Expected a hash reference, not $response\n";
	}
	
	foreach my $key (sort keys %$response) {
		
		## Use regex to extract only the oid value different from
		## $oid_to_get.
		
		if ($key =~ /($oid_to_get)\.(\d+)/){
			## For Debugging
			#print "Key: $2 " . "Interface: " . $$response{$key} . "\n";
			$hash_to_return_from_sub{$2} = $$response{$key}
		}
	}
	
	$session->close;
	return \%hash_to_return_from_sub;

}

sub snmpget {
	
	my ($self, $oid_to_get) = @_;
	
	my $hostname = $self->{_ipAddress};
	my $community = $self->{_snmpCommunity};
	
	my ($session, $error) = Net::SNMP->session(Hostname => $hostname, Community => $community);
	
	my $response = "NA";
	my $scalar_to_return_from_sub = undef;
	
	if (!defined($session)) { 
		print("## Cant open device.\n");
		exit 1;
	}
	if (!defined($response = $session->get_request($oid_to_get))) {
		printf("## %s\n", $session->error);
		$session->close;
		exit 1;
	}
	
	## Test $response for HASH
	if (ref($response) ne 'HASH') {
		die "Expected a hash reference, not $response\n";
	}

	$scalar_to_return_from_sub = $response->{$oid_to_get};
	
	$session->close;
	return $scalar_to_return_from_sub;

}

1;
__END__

=head1 NAME

SysAdmin::SNMP - Perl SNMP class wrapper module

=head1 SYNOPSIS

  use SysAdmin::SNMP;
  
  my $ip_address = "192.168.1.1";
  my $community  = "public";
  
  my $snmp_object = new SysAdmin::SNMP(IP        => "$ip_address",
                                       COMMUNITY => "$community");
				  
  my $sysName = '.1.3.6.1.2.1.1.5.0';
  
  my $query_result = $snmp_object->snmpget("$sysName");
  
  print "$ip_address\'s System Name is $query_result

=head1 DESCRIPTION

This is a sub class of SysAdmin. It was created to harness Perl Objects and keep
code abstraction to a minimum. This class acts as a master class for SNMP
objects.

SysAdmin::SNMP uses Net::SNMP to interact with SNMP enabled equipment.

=head2 EXPORT

=head1 SEE ALSO

Net::SNMP - Object oriented interface to SNMP

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
