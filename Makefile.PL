use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'SysAdmin',
    VERSION_FROM      => 'lib/SysAdmin.pm', # finds $VERSION
    PREREQ_PM => {
    	'DBI' => 1.40,
	'DBD::Pg' => 0,
	'DBD::SQLite' => 0,
	'DBD::MySQL' => 0,
	'MIME::Lite' => 0,
	'Net::SMTP' => 0,
	'Expect' => 0,
	'Net::SNMP' => 0,
	'Filter::Util::Call' => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/SysAdmin.pm', # retrieve abstract from module
       AUTHOR         => 'Miguel A. Rivera <marr@cpan.org>') : ()),
);
