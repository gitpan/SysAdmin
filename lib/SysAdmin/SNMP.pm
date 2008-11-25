
package SysAdmin::SNMP;
use strict;

use SysAdmin;
use Net::SNMP;
use Carp;

use vars qw(@ISA $VERSION);

our @ISA = qw(SysAdmin);    # inherits from SysAdmin
our $VERSION = 0.04;

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
	
	Carp::croak "No IP address supplied" unless $self->{_ipAddress};
	
	return $self;
}

sub snmpwalk {
	
	my ($self, $oid_to_get) = @_;
	
	Carp::croak "No OID supplied" unless $oid_to_get;
	
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
		printf("## $oid_to_get %s\n", $session->error);
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
	
	Carp::croak "No OID supplied" unless $oid_to_get;
	
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

sub fetchInterfaces {
	
	my ($self) = @_;
	
	my $hostname = $self->{_ipAddress};
	my $community = $self->{_snmpCommunity};
	
	my $ifDescr = '.1.3.6.1.2.1.2.2.1.2';
	my $ifType = '.1.3.6.1.2.1.2.2.1.3';
	my $ifAdminStatus = '.1.3.6.1.2.1.2.2.1.7';
	my $ifOperStatus = '.1.3.6.1.2.1.2.2.1.8';
	my $ifAlias = '.1.3.6.1.2.1.31.1.1.1.18';
	
	my $snmp_object = new SysAdmin::SNMP(IP        => "$hostname",
                                             COMMUNITY => "$community");
	
	my $snmp_oid_to_check = $ifDescr . ".1";
	my $check_for_valid_string = $snmp_object->checkValidOID("$snmp_oid_to_check");
	
	if($check_for_valid_string eq "VALID"){
		
		my $ifDescr_ref = $snmp_object->snmpwalk("$ifDescr");
		my $ifType_ref = $snmp_object->snmpwalk("$ifType");
		my $ifAdminStatus_ref = $snmp_object->snmpwalk("$ifAdminStatus");
		my $ifOperStatus_ref = $snmp_object->snmpwalk("$ifOperStatus");
		
		my $ifAlias_check = $ifAlias . ".1";
		my $ifAlias_validity = $snmp_object->checkValidOID("$ifAlias_check");
		
		my $ifAlias_ref = undef;
		my $ifAlias_validity_result = undef;
		
		if($ifAlias_validity eq "VALID"){
			$ifAlias_ref = $snmp_object->snmpwalk("$ifAlias");
			$ifAlias_validity_result = 1;
		}
		
		my %interfaces_to_return = ();
		
		foreach my $key (sort keys %$ifDescr_ref){
			
			if($$ifDescr_ref{$key} =~ /(\d)/){
				$interfaces_to_return{$key}{'id'} = $key;
				$interfaces_to_return{$key}{'ifDescr'} = $$ifDescr_ref{$key};
				$interfaces_to_return{$key}{'ifType'} = $$ifType_ref{$key};
				$interfaces_to_return{$key}{'ifAdminStatus'} = $$ifAdminStatus_ref{$key};
				$interfaces_to_return{$key}{'ifOperStatus'} = $$ifOperStatus_ref{$key};
				if($ifAlias_validity_result){
					$interfaces_to_return{$key}{'ifAlias'} = $$ifAlias_ref{$key};
				}
				else{
					$interfaces_to_return{$key}{'ifAlias'} = "";
				}
			}
		}
		return \%interfaces_to_return;
	}
	else{
		print "## There was a problem communicating with the network device!\n";
		exit 1;
	}
}

sub fetchActiveInterfaces {
	
	my ($self) = @_;
	
	my $hostname = $self->{_ipAddress};
	my $community = $self->{_snmpCommunity};
	
	my $ifDescr = '.1.3.6.1.2.1.2.2.1.2';
	my $ifType = '.1.3.6.1.2.1.2.2.1.3';
	my $ifAdminStatus = '.1.3.6.1.2.1.2.2.1.7';
	my $ifOperStatus = '.1.3.6.1.2.1.2.2.1.8';
	my $ifAlias = '.1.3.6.1.2.1.31.1.1.1.18';
	
	my $snmp_object = new SysAdmin::SNMP(IP        => "$hostname",
                                             COMMUNITY => "$community");
	
	
	my $snmp_query_result_ref = $snmp_object->fetchInterfaces();
	
	my %active_interfaces_in_equipment = ();
	
	foreach my $key ( sort keys %$snmp_query_result_ref){
	
		if($$snmp_query_result_ref{$key}{'ifAdminStatus'} =~ /(\d)/){
			if($1 eq "1"){
				
				my $admin_status = "1";
				my $oper_status = undef;
				
				if($$snmp_query_result_ref{$key}{'ifOperStatus'} =~ /(\d)/){
					if($1 eq "1"){
						$oper_status = "1";
					}
					else{
						$oper_status = "$1";
					}
				}
	
				my $active_interfaces = $$snmp_query_result_ref{$key}{'ifDescr'};
				my $active_interfaces_alias = $$snmp_query_result_ref{$key}{'ifAlias'};
				
				$active_interfaces_in_equipment{$key}{'id'} = $key;
				$active_interfaces_in_equipment{$key}{'ifDescr'} = $$snmp_query_result_ref{$key}{'ifDescr'};
				$active_interfaces_in_equipment{$key}{'ifType'} = $$snmp_query_result_ref{$key}{'ifType'};
				$active_interfaces_in_equipment{$key}{'ifAdminStatus'} = $admin_status;
				$active_interfaces_in_equipment{$key}{'ifOperStatus'} = $oper_status;
				$active_interfaces_in_equipment{$key}{'ifAlias'} = $$snmp_query_result_ref{$key}{'ifAlias'};
			}
		}
	}
	
	return \%active_interfaces_in_equipment;
}

sub checkValidOID {
	
	my ($self, $oid_to_get) = @_;
	
	Carp::croak "No OID supplied" unless $oid_to_get;
	
	my $hostname = $self->{_ipAddress};
	my $community = $self->{_snmpCommunity};
	
	my ($session, $error) = Net::SNMP->session(Hostname => $hostname, Community => $community);
	
	my $response = "NA";
	my $scalar_to_return_from_sub = undef;
	
	if (!defined($session)) { 
		print("## There was a problem communicating with the network device!\n\n");
		exit 1;
	}
	
	my $session_error = "VALID";
	
	if (!defined($response = $session->get_request($oid_to_get))) {

		$session_error = $session->error;
		
	}
	
	$session->close;
	return $session_error;
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

=head1 METHODS

=head2 C<new()>

	my $snmp_object = new SysAdmin::SNMP(IP        => "$ip_address",
                                         COMMUNITY => "$community");

Declare the SysAdmin::SNMP object instance. Takes the network element ip
address and its SNMP community string as the only variables to use.

	IP => "$ip_address"

Declare the IP address of the network element.

	COMMUNITY => "$community"
	
Declares the SNMP community string.

=head2 C<snmpwalk()>

=head2 C<snmpget()>

=head2 C<fetchInterfaces()>

=head2 C<fetchActiveInterfaces()>

head3 C<checkValidOID()>
	
=head1 SEE ALSO

Net::SNMP - Object oriented interface to SNMP

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
