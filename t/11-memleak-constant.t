#!perl -w
use strict;
use Test::More;
use MozRepl::RemoteObject;

my $repl = eval { MozRepl::RemoteObject->install_bridge( 
)};

if (! $repl) {
    my $err = $@;
    plan skip_all => "Couldn't connect to MozRepl: $@";
    exit
} else {
    plan tests => 1;
};

my $f = $repl->constant('3');

my $g = $repl->constant('3');

my $destroyed = 0;
my $old = \&MozRepl::RemoteObject::DESTROY;
{
    no warnings 'redefine';
    *MozRepl::RemoteObject::DESTROY = sub {
        $destroyed++;
        goto &$old;
    };
};

undef $repl;

is $destroyed, 1, "Bridge with constant gets destroyed";

