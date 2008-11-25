#!/usr/local/bin/perl
use strict;

use SysAdmin::SMTP;

my $smtp_object = new SysAdmin::SMTP("localhost");

my $from_address = qq("Test User" <test\@test.org>);
my $subject = "Test Subject";
my $message_body = "Test Message";
my $email_recipients = ["test\@test.org"];

$smtp_object->sendEmail("FROM"    => "$from_address",
						"TO"      => "$email_recipients",
						"SUBJECT" => "$subject",
						"BODY"    => "$message_body");
