
package SysAdmin::SMTP;
use strict;

use SysAdmin;
use MIME::Lite;
use Net::SMTP;
use Carp;

use vars qw(@ISA $VERSION);

our @ISA = qw(SysAdmin);    # inherits from SysAdmin
our $VERSION = 0.02;

sub new {
	my $class = shift;
	my $self = {
		_smtpServer => shift
	};
	
	bless $self, $class;
	
	Carp::croak "No smtp server supplied" unless $self->{_smtpServer};
	
	return $self;
}

sub sendEmail {
	my $self = shift;
	
	my $smtp_server = $self->{_smtpServer};
	
	my %attr = @_;
	
	my $from_address = $attr{'FROM'};
    my @email_recipients = @{$attr{'TO'}};
	my $subject = $attr{'SUBJECT'};
	my $message_body = $attr{'BODY'};
	
	my $email_recipients = join ",", @email_recipients;

	my $mime_type_attach = "text/html";

	my $msg = MIME::Lite->new (
	From => $from_address,
	To => $email_recipients,
	Subject => $subject,
	Type =>'multipart/alternative') or &dienice ("Error creating multipart container: $!\n");
                                                                   
	$msg->attach (
	Type => 'text/html;charset=ISO-8859-1',
	Encoding => 'quoted-printable',
	Data => $message_body) or &dienice ("Error adding the text message part: $!\n");

	my $smtp = Net::SMTP->new($smtp_server, Debug   => 0);
	die "Couldn\'t connect to server" unless $smtp;

	$smtp->mail( $from_address );
	$smtp->to( @email_recipients  );

	$smtp->data();
	$smtp->datasend($msg->as_string);
	$smtp->dataend();
	$smtp->quit;
}

1;
__END__

=head1 NAME

SysAdmin::SMTP - Perl Net::SMTP class wrapper module.

=head1 SYNOPSIS

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
	

=head1 DESCRIPTION

This is a sub class of SysAdmin. It was created to harness Perl Objects and keep
code abstraction to a minimum.

SysAdmin::SMTP uses Net::SMTP, MIME::Lite to send emails.

=head1 METHODS

=head2 C<new()>

	my $smtp_object = new SysAdmin::SMTP("localhost");
	
Declare the SysAdmin::SMTP object instance. Takes the SMTP server as the only
variable to use.

=head2 C<sendEmail()>

	my $from_address = qq("Test User" <test_user\@test.com>);
	my $subject = "Test Subject";
	my $message_body = "Test Message";
	my $email_recipients = ["test_receiver\@test.com"];
	
	$smtp_object->sendEmail("FROM"    => "$from_address",
                            "TO"      => "$email_recipients",
                            "SUBJECT" => "$subject",
                            "BODY"    => "$message_body");
														

=head1 SEE ALSO

Net::SMTP - Simple Mail Transfer Protocol Client
MIME::Lite - low-calorie MIME generator 

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
