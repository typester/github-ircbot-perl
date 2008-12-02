package Github::IRCBot::IRC;
use Moose;

use POE qw/Component::IRC/;

has server => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has port => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 6667 },
);

has nick => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { 'bot' },
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
                    map { $_ => "poe_$_" } qw/_start _default irc_001 irc_433 say/,
                },
            ],
        );
    },
);

has channels => (
    is      => 'rw',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub { [] },
);

has component => (
    is  => 'rw',
    isa => 'POE::Component::IRC',
);

no Moose;

sub spawn {
    my $self = shift;
    $self->session;
}

sub poe__start {
    my ($self, $kernel, $session) = @_[OBJECT, KERNEL, SESSION];

    $kernel->alias_set('irc');

    my $irc = $self->{component} = POE::Component::IRC->spawn(
        Nick     => $self->nick,
        Ircname  => $self->nick,
        Username => $self->nick,
        Server   => $self->server,
        Port     => $self->port,
    );
    $irc->yield( register => 'all' );
    $irc->yield( connect  => {} );
}

sub poe_irc_001 {
    my ($self, $kernel) = @_[OBJECT, KERNEL];
    $self->component->yield( join => $_ ) for @{ $self->channels };
}

sub poe_irc_433 {
    my ($self, $kernel) = @_[OBJECT, KERNEL];
    my ($nick, $d) = $self->nick =~ /^(.*?)(\d*)$/;
    $d = defined $d ? ++$d : 1;

    $self->component->yield( nick => $nick . $d );
}

sub poe__default {
    my ($event, $args) = @_[ARG0 .. $#_];

    print "$event: ";
    for my $arg (@$args) {
        print ref($arg) ? '[' . join(',', @$args) . ']'
            : $arg;
        print ", ";
    }
    print "\n";
}

sub poe_say {
    my ($self, $kernel, $session, $channel, $message) = @_[OBJECT, KERNEL, SESSION, ARG0, ARG1];
    $self->component->yield( privmsg => $channel => $message );
}

__PACKAGE__->meta->make_immutable;

