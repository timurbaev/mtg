package Store;

use strict;
use warnings;

use DBI;

our $database;

sub user_by_login {
    my $login = shift;
    my $sth = $database->prepare ('SELECT id, login, password, balance FROM Users WHERE login = ?');
    $sth->execute ($login);
    return $sth->fetchrow_hashref;
}
