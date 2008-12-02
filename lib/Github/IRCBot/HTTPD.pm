package Github::IRCBot::HTTPD;
use Moose;

use POE qw/Component::Server::HTTP/;
use JSON::XS ();

has port => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 3000 },
);

has session => (
    is      => 'rw',
    isa     => 'POE::Session',
    lazy    => 1,
    default => sub {
        my $self = shift;
        POE::Session->create(
            object_states => [
                $self => {
                    map { $_ => "poe_$_" } qw/_start/,
                },
            ],
        );
    },
);

has aliases => (
    is  => 'rw',
    isa => 'HashRef',
);

has json => (
    is      => 'rw',
    isa     => 'JSON::XS',
    lazy    => 1,
    default => sub { JSON::XS->new->latin1 },
);

sub spawn {
    my $self = shift;
    $self->session;
}

sub poe__start {
    my ($self, $kernel, $session) = @_[OBJECT, KERNEL, SESSION];

    $kernel->alias_set('httpd');

    POE::Component::Server::HTTP->new(
        Port           => $self->port,
        ContentHandler => {
            '/' => sub {
                my ($request, $response) = @_;
                
            },
        },
    );
}

__PACKAGE__->meta->make_immutable;

