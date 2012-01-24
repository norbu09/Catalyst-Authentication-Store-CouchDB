use inc::Module::Install;

name     'Catalyst-Authentication-Store-CouchDB';
all_from 'lib/Catalyst/Authentication/Store/CouchDB.pm';
author   q{Lenz Gschwendtner <norbu09@cpan.org>};
license  'perl';

build_requires 'Test::More';

requires 'Digest::SHA';
requires 'Data::Dumper';
requires 'Catalyst::Authentication::User';
requires 'Class::Accessor::Fast';
requires 'Store::CouchDB';
requires 'Scalar::Util';

auto_install;

WriteAll;

