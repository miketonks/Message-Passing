use strict;
use warnings;

use Test::More;

use_ok('Message::Passing::Role::HasAConnection');
use_ok('Message::Passing::Role::ConnectionManager');
use_ok('Message::Passing');
use_ok('Message::Passing::Output::STDOUT');
use_ok('Message::Passing::Input::STDIN');
use_ok('Message::Passing::Input::FileTail');
use_ok('Message::Passing::Output::Null');
use_ok('Message::Passing::Output::Callback');
use_ok('Message::Passing::Output::Test');
use_ok('Message::Passing::Output::File');
use_ok('Message::Passing::Filter::Null');
use_ok('Message::Passing::Filter::All');
use_ok('Message::Passing::Filter::Delay');

done_testing;

