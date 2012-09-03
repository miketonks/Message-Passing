use strict;
use warnings;
use Test::More;
use Data::Dumper;

use Message::Passing::Filter::ToLogStash;
use Message::Passing::Output::Test;
use Sys::Hostname;

no warnings 'redefine';
sub AnyEvent::now { 1346706534 }
use warnings 'redefine';

my @data = (
    [
        'Simple empty hash',
        {},
        { '@fields' => {}, '@tags' => [] }
    ],
    [
        'MX::Storage',
        { '__CLASS__' => 'Moo', foo => 'bar' },
        { '@fields' => { foo => 'bar' }, '@tags' => [], '@type' => 'perl:Class:Moo' },
    ],
    [
        'timestamp from epoch',
        { epochtime => 1346706534 },
        { '@fields' => {}, '@tags' => [], '@timestamp' => '2012-09-03T21:08:54' },
    ],
    [
        'raw message',
        'foo',
        { '@fields' => {}, '@tags' => [], '@message' => 'foo', '@source_host' => hostname(), '@timestamp' => '2012-09-03T21:08:54', '@type' => 'generic_line' },
    ],
    [
        'filename',
        { filename => '/foo/bar', 'message' => 'foo' },
        { '@fields' => {}, '@tags' => [], '@message' => 'foo', '@source_path' => '/foo/bar' },
    ],
    [
        'date field, no epoch',
        { date => '2012-09-03T21:08:54', message => 'foo',},
        { '@fields' => {}, '@tags' => [], '@message' => 'foo', '@timestamp' => '2012-09-03T21:08:54' },
    ],
);

foreach my $datum (@data) {
    my ($name, $input, $exp) = @$datum;
    my $out = Message::Passing::Output::Test->new;
    my $in = Message::Passing::Filter::ToLogStash->new(
        output_to => $out,
    );
    $in->consume($input);
    my ($output) = $out->messages;
    is_deeply $output, $exp, $name
        or diag "Got " . Dumper($output) . " expected " . Dumper($exp);
}

done_testing;

