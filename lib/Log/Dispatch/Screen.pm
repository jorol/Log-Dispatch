package Log::Dispatch::Screen;

use strict;
use warnings;

our $VERSION = '2.59';

use Log::Dispatch::Output;

use base qw( Log::Dispatch::Output );

use Encode qw( encode );
use IO::Handle;
use Params::Validate qw(validate BOOLEAN);
Params::Validate::validation_options( allow_extra => 1 );

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my %p = validate(
        @_, {
            stderr => {
                type    => BOOLEAN,
                default => 1,
            },
            utf8 => {
                type    => BOOLEAN,
                default => 0,
            },
        }
    );

    my $self = bless \%p, $class;
    $self->_basic_init(%p);

    return $self;
}

sub log_message {
    my $self = shift;
    my %p    = @_;

    # This is a bit gross but it's important that we print directly to the
    # STDOUT or STDERR handle for backwards compatibility. Various modules
    # have tests which rely on this, so we can't open a new filehandle to fd 1
    # or 2 and use that.
    my $message
        = $self->{utf8} ? encode( 'UTF-8', $p{message} ) : $p{message};
    if ( $self->{stderr} ) {
        print STDERR $message;
    }
    else {
        print STDOUT $message;
    }
}

1;

# ABSTRACT: Object for logging to the screen

__END__

=for Pod::Coverage new log_message

=head1 SYNOPSIS

  use Log::Dispatch;

  my $log = Log::Dispatch->new(
      outputs => [
          [
              'Screen',
              min_level => 'debug',
              stderr    => 1,
              newline   => 1
          ]
      ],
  );

  $log->alert("I'm searching the city for sci-fi wasabi");

=head1 DESCRIPTION

This module provides an object for logging to the screen (really
C<STDOUT> or C<STDERR>).

Note that a newline will I<not> be added automatically at the end of a
message by default. To do that, pass C<< newline => 1 >>.

The handle will be autoflushed, but this module opens it's own handle to fd 1
or 2 instead of using the global C<STDOUT> or C<STDERR>.

=head1 CONSTRUCTOR

The constructor takes the following parameters in addition to the standard
parameters documented in L<Log::Dispatch::Output>:

=over 4

=item * stderr (0 or 1)

Indicates whether or not logging information should go to C<STDERR>. If
false, logging information is printed to C<STDOUT> instead.

This defaults to true.

=item * utf8 (0 or 1)

If this is true, then the output uses C<binmode> to apply the
C<:encoding(UTF-8)> layer to the relevant handle for output. This will not
affect C<STDOUT> or C<STDERR> in other parts of your code.

This defaults to false.

=back

=cut
