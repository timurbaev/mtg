package Store;

use strict;
use warnings;

use DBI;

our $database;
our $FEE;

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

sub purchase {
    my ($userid, $cardid) = @_;
    my $prev = $database->{AutoCommit};
    $database->{AutoCommit} = 0;
    eval {
        my $sth = $database->prepare ('UPDATE Users SET balance = balance - ? WHERE id = ?');
        $sth->execute ($FEE, $userid) or die;
        $sth = $database->prepare ('INSERT INTO Cards_has_Users (Card_id, User_id) VALUES (?, ?)');
        $sth->execute ($cardid, $userid) or die;
        $database->commit;
    };
    if ($@) {
        $database->rollback();
        $cardid = 0;
    }
    $database->{AutoCommit} = $prev;
    return $cardid;
}
