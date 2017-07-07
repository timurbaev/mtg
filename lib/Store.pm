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

sub card_by_cardname {
    my $cardname = shift;
    my $sth = $database->prepare ('SELECT id, name FROM Cards WHERE name = ?');
    $sth->execute ($cardname);
    return $sth->fetchrow_hashref;
}

sub user_has_card {
    my ($userid, $cardid) = @_;
    my $sth = $database->prepare ('SELECT User_id, Card_id FROM Cards_has_Users WHERE User_id = ? AND Card_id = ?');
    $sth->execute ($userid, $cardid);
    return defined $sth->fetchrow_hashref;
}
