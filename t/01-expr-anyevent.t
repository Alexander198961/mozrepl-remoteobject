#!perl -w
use strict;
use Test::More tests => 2;

use MozRepl::RemoteObject;
use MozRepl::AnyEvent;

my $arepl = MozRepl::AnyEvent->new();
$arepl->setup();

isa_ok $arepl, 'MozRepl::AnyEvent';

my $repl = MozRepl::RemoteObject->install_bridge(
    repl => $arepl,
);

my $four = $repl->expr(<<JS);
    2+2
JS

is $four, 4, "Addition in Javascript works";

my $wrapped_repl = $repl->expr(<<JS);
    repl
JS

my $repl_id = $wrapped_repl->__id;
my $identity = $repl->expr(<<JS);
    repl === repl.getLink($repl_id)
JS

is $identity, 'true', "Object identity in Javascript works";

my $adder = $repl->expr(<<JS);
    function(a,b) { return a+b }
JS
isa_ok $adder, 'MozRepl::RemoteObject::Instance';

my $five = $adder->(2,3);
is $five, 5, "Anonymous functions in Javascript work as well";