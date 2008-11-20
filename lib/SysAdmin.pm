package SysAdmin;

use 5.008008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);


our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

1;
__END__

=head1 NAME

SysAdmin - Perl master class for SysAdmin wrapper modules.

=head1 SYNOPSIS

  No Direct use. Try sub classes.

=head1 DESCRIPTION

This is a master class for SysAdmin wrapper modules. Example SysAdmin modules 
are SysAdmin::DBD, SysAdmin::Expect, SysAdmin::SMTP.

=head2 EXPORT

=head1 SEE ALSO

=head1 AUTHOR

Miguel A. Rivera

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
