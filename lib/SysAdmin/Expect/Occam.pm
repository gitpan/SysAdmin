
package SysAdmin::Expect::Occam;
use strict;

use SysAdmin::Expect;
use SysAdmin::SNMP;

use vars qw(@ISA $VERSION);

our @ISA = qw(SysAdmin::Expect);    # inherits from SysAdmin::Expect
our $VERSION = 0.01;

sub new {
	my $class = shift;
	my $self  = $class->SUPER::new();
	
	my %attr = @_;
	
	###
	## Supported Attribute List
	#
	# COMMUNITY = SNMP Community String
	# TELNET_PASSWORD = Telnet password of equipment
	# TELNET_ENABLE_PASSWORD = Enable password of equipment
	#
	##
	###
	
	$self = {
		_snmpCommunity        => $attr{"COMMUNITY"} || "public",
		_telnetPassword       => $attr{"TELNET_PASSWORD"} || "pass",
		_telnetEnablePassword => $attr{"TELNET_ENABLE_PASSWORD"} || "pass"
	};
	    
	bless $self, $class;
	return $self;
}

sub activeInterfaces {
	
	my ($self) = @_;
	
	my $ifDescr = '.1.3.6.1.2.1.2.2.1.2';
	my $ifAdminStatus = '.1.3.6.1.2.1.2.2.1.7';
	
	my $ip_address = $self->{_telnetServer};
	my $community = $self->{_snmpCommunity};
	
	my $snmp_object = new SysAdmin::SNMP(IP        => "$ip_address",
					     COMMUNITY => "$community");
  
	my $interface_description_ref = $snmp_object->snmpwalk("$ifDescr");
	my $if_admin_status_ref = $snmp_object->snmpwalk("$ifAdminStatus");
	
	my %active_interfaces_found = ();
	
	foreach my $key ( sort keys %$if_admin_status_ref){
	
		if($$if_admin_status_ref{$key} =~ /(\d)/){
			if($1 eq "1"){
				
				my $active_interfaces = $$interface_description_ref{$key};
				if($active_interfaces =~ /GigabitEthernet\s\d{1,2}\/(\d{1,2})/){
					$active_interfaces_found{$key}{'id'} = $1;
					$active_interfaces_found{$key}{'type'} = "ethernet";
					$active_interfaces_found{$key}{'desc'} = $active_interfaces;
				}
				if($active_interfaces =~ /10GigabitEthernet\s\d{1,2}\/(\d{1,2})/){
					$active_interfaces_found{$key}{'id'} = $1;
					$active_interfaces_found{$key}{'type'} = "xg";
					$active_interfaces_found{$key}{'desc'} = $active_interfaces;
				}
			}
		}
	}
	return \%active_interfaces_found;
}

sub interfaceInfo {
	my ($self,$active_interfaces_ref) = @_;
	
	my $logfile = $self->{_logFile};
	my $hostname = $self->{_telnetServer};
	my $telnet_password = $self->{_telnetPassword};
	my $telnet_enable_password = $self->{_telnetEnablePassword};
	
	if(!$logfile){
		$logfile = "expect_logfile_12345.tmp";
	}
	
	$Expect::Log_Stdout=0;
	
	my $exp = new Expect;
	
	$exp->log_file("$logfile");
	
	$exp->spawn("telnet $hostname") or die "Cannot spawn command: $!\n";
	
	my $patidx = $exp->expect(30, 'Password: ');
	$exp->send("$telnet_password\n");
	$exp->send("ena\n");
	$patidx = $exp->expect(30, 'Password: ');
	$exp->send("$telnet_enable_password\n");
	$exp->send("terminal length 500\n");
	$exp->send("terminal width 500\n");
	
	foreach my $key (sort keys %$active_interfaces_ref){
		
		if($$active_interfaces_ref{$key}{'type'} eq "ethernet"){
			
			my $interface_id = $$active_interfaces_ref{$key}{'id'};
			my $interface_type = $$active_interfaces_ref{$key}{'type'};
			
			$exp->send("show interface $interface_type info $interface_id\n");
		}
	}
	
	$exp->send("exit\n");
	$exp->send("exit\n");
	$exp->soft_close();
	
	my %interface_info_extracted_from_expect = ();
	
	if( -e $logfile){
		open(HANDLE, "$logfile");
		while (<HANDLE>) {
			chomp;
			
			# 15  |SUB      |NONE |up   |INFO1  |INFO2|INFO3
			
			## REGEX based on above line
			#\s\d{1,2}\s+\|\w+\s+\|\w+\s+\|\w+\s+\|(.*?)\|(.*?)\|(.*?)$
	
			if($_ =~ /^\s(\d{1,2})\s+\|.*?\|.*?\|.*?\|(.*?)\|(.*?)\|(.*?)$/){
				
				$interface_info_extracted_from_expect{$1}{'id'} = $1;
				$interface_info_extracted_from_expect{$1}{'info1'} = $2;
				$interface_info_extracted_from_expect{$1}{'info2'} = $3;
				$interface_info_extracted_from_expect{$1}{'info3'} = $4;
				
				#print $1 . "|" . $2 . "|" . $3 . "|" . $4 . "\n";
			}
		}
		close(HANDLE);
		
		unlink $logfile;
	}
	
	return \%interface_info_extracted_from_expect;
}

1;
__END__

=head1 NAME

SysAdmin::Expect::Occam - Perl Expect class.wrapper module

=head1 SYNOPSIS

  use SysAdmin::Expect::Occam;
  
  my $expect_object = new SysAdmin::Expect::Occam(SERVER                 => "localhost",
                                                  COMMUNITY              => "public",
                                                  TELNET_PASSWORD        => "pass",
                                                  TELNET_ENABLE_PASSWORD => "pass");

=head1 DESCRIPTION

This is a sub class of SysAdmin. It was created to harness Perl Objects and keep
code apstraction to a minimum. This class acts as a master class for Expect
objects.

SysAdmin::Expect::Occam uses Expect.pm to interact with network equipment.

=head2 EXPORT

=head1 SEE ALSO

SysAdmin::Expect::Occam to interact with Occam equipment.

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE


This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
