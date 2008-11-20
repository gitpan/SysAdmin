#!/usr/local/bin/perl
use strict;

use SysAdmin::SMTP;

my $object = new SysAdmin::SMTP("localhost");


my $from_address = qq("Test Sender" <test_sender\@test.com>);
my $subject = "Test Subject";
my $message_body = "Test Message";
my @email_recipients = ("test_receiver\@test.com");

$object->sendEmail($from_address,$subject,$message_body,@email_recipients); 
