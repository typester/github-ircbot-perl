package Github::IRCBot;
use Moose;

our $VERSION = '0.01';

use POE;
use Github::IRCBot::IRC;
use Github::IRCBot::HTTPD;

has config => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

has irc => (
    is      => 'rw',
    isa     => 'Github::IRCBot::IRC',
    lazy    => 1,
    default => sub {
        my $self = shift;
        Github::IRCBot::IRC->new( $self->config->{irc} );
    },
);

has httpd => (
    is      => 'rw',
    isa     => 'Github::IRCBot::HTTPD',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $settings = $self->config->{httpd};
        $settings->{irc} = $self->irc;
        Github::IRCBot::HTTPD->new($settings);
    },
);

no Moose;

sub run {
    my $self = shift;

    $self->irc->spawn;
    $self->httpd->spawn;

    POE::Kernel->run;
}

=head1 NAME

Github::IRCBot - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use Github::IRCBot;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

__PACKAGE__->meta->make_immutable;
