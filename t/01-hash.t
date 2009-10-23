#!perl -w
use strict;
use Test::More tests => 7;

use MozRepl::RemoteObject;

my $repl = MozRepl->new;
$repl->setup({
    client => {
        extra_client_args => {
            binmode => 1,
        }
    },
    log => [qw/ error/],
    #log => [qw/ debug error/],
    plugins => { plugins => [qw[ Repl::Load ]] }, # I'm loading my own JSON serializer
});

diag "--- Loading object functionality into repl\n";
MozRepl::RemoteObject->install_bridge($repl);

# create a nested object
sub genObj {
    my ($repl,$val) = @_;
    my $rn = $repl->repl;
    my $obj = MozRepl::RemoteObject->expr(<<JS)
(function(repl, val) {
    return { bar: { baz: { value: val } }, foo: 1 };
})($rn, "$val")
JS
}

my $foo = genObj($repl, 'deep');
isa_ok $foo, 'MozRepl::RemoteObject';

my $bar = $foo->{bar};
isa_ok $bar, 'MozRepl::RemoteObject';

my $baz = $bar->{baz};
isa_ok $baz, 'MozRepl::RemoteObject';

my $val = $baz->{value};
is $val, 'deep';

$val = $baz->{nonexisting};
is $val, undef, 'Nonexisting properties return undef';

$baz->{ 'test' } = 'foo';
is $baz->{ test }, 'foo', 'Setting a value works';

my @keys = $foo->__keys;
is_deeply \@keys, ['bar','foo'], 'We can get at the keys';