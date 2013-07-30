package Message::Passing::Input::LogTail;
use Moo;
use MooX::Types::MooseLike::Base qw/ Str Int /;
use AnyEvent;
use Scalar::Util qw/ weaken /;
use POSIX ":sys_wait_h";
use Sys::Hostname::Long;
use AnyEvent::Handle;
use namespace::clean -except => 'meta';

use constant HOSTNAME => hostname_long();

use Log::Unrotate;

with 'Message::Passing::Role::Input';

has filename => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has _reader => (
    is => 'ro',
    lazy => 1,
    builder => '_build_reader',
    clearer => 1,
);

has raw => (
    is => 'ro',
    default => sub { 0 },
);

sub _emit_line {
    my ($self, $line) = @_;

    my $data = $self->raw ? $line : {
        filename  => $self->filename,
        message   => $line,
        hostname  => HOSTNAME,
        epochtime => AnyEvent->now,
        type      => 'log_line',
    };
    $self->output_to->consume($data);
}

sub _build_reader {
    my $self = shift;
    weaken($self);

    my $filename = $self->filename;

    die("Cannot open filename '$filename'")
        unless -r $self->filename;

warn ">>>> Open log file: $filename";

    my $reader = Log::Unrotate->new({
        log => $filename,
        pos => $filename . '.pos',
        #autofix_cursor => 1,
        end => 'future',
    });

    return $reader;
}

sub _read_log {
    my $self = shift;

    my $reader = $self->_reader;

    while (my $line = $reader->read()) {

#warn "line: $line";
        $self->_emit_line($line);
        $reader->commit(); # serialize the position on disk into 'pos' file
    }

    my $timer;
    $timer = AnyEvent->timer (after => 2, cb => sub {
#warn "wake";
        undef $timer;
        $self->_read_log();
    });
}

sub BUILD {
    my $self = shift;
    $self->_read_log;
}


1;

=head1 NAME

Message::Passing::Input::LogTail - Incremental Log tailing input with transparent rotation handling

=head1 SYNOPSIS

    message-pass --input LogTail
      --input_options '{"filename": "/var/log/foo.log"} --output STDOUT
      {"filename":"/var/log/foo.log","message":"example line",
      "hostname":"www.example.com","epochtime":"1346705476","type":"log_line"}

=head1 DESCRIPTION

Tail log files into Message::Passing with automatic handling for last log
position (survises a restart or reboot without loss / duplication) and
log rotation.  Wrapper to Log::Unrotate for the clever bits.

=head1 ATTRIBUTES

=head2 filename

The filename of the log file to tail.

=head2 raw

If the file data should be output raw (as just a line). Normally lines are
output as a hash of data including the fields showing in the SYNOPSIS.

=head1 SEE ALSO

L<Message::Passing>

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing>.

=cut

