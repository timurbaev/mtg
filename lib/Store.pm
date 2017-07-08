package Store;

use strict;
use warnings;

use Exporter 'import';
use DBI;
use File::Path qw/make_path/;
use File::Basename qw/dirname/;

use LWP::UserAgent;
our @EXPORT = qw (buy_card user_by_login user_has_card);

our $database;
our $FEE;
our $MAXSIZE;
our $USERAGENT;
our $HOST;
our $CARDS;

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

sub download_card {
    my $cardname = shift;
    my $useragent = LWP::UserAgent->new (agent => $USERAGENT, max_size => $MAXSIZE);
    my $request = HTTP::Request->new (GET => $HOST . "/query?q=%21$cardname&v=card&s=cname");
    my $response = $useragent->request ($request);
    return 0 unless $response->is_success;
    return 0 unless ($response->content =~ qr/<img src=\"(?<img>$HOST\/scans\/\w*\/\w*\/(?<cardid>\d*).jpg)\"\s*alt=\"$cardname\"/m);       
    my $cardid = $+{cardid};
    my $img = $+{img};
    my $sth = $database->prepare ('INSERT INTO Cards (id, name) VALUES (?, ?)');
    $sth->execute ($cardid, $cardname) or return 0; 
    my $out = File::Spec->catfile ($CARDS, $cardid . '.jpg');
    make_path (dirname ($out));
    open my $fh, '>', $out or return 0;
    close $fh;
    $request = HTTP::Request->new (GET => $img);
    $response = $useragent->request ($request, $out);
    return 0 unless $response->is_success;
    return $cardid;   
}

sub buy_card {
    my ($login, $cardname) = @_;
    my $user = user_by_login ($login);
    return unless $user;
    my $userid = $user->{id};
    my $balance = $user->{balance};
    return if ($balance < $FEE);
    my $card = card_by_cardname ($cardname);
    my $cardid = $card ? $card->{id} : download_card ($cardname);   
    return $cardid if (user_has_card ($userid, $cardid));
    purchase ($userid, $cardid);
}

1;
