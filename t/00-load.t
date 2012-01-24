#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Catalyst::Authentication::Store::CouchDB' ) || print "Bail out!\n";
}

diag( "Testing Catalyst::Authentication::Store::CouchDB $Catalyst::Authentication::Store::CouchDB::VERSION, Perl $], $^X" );
