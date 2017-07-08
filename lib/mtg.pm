package mtg;
use Dancer2;
use Dancer2::Plugin::Database;
use Store;

our $VERSION = '0.1';

my $cards = 'cards';
$Store::database = database;
$Store::FEE = 1;
$Store::MAXSIZE = 1000 * 1024; #1000 kb
$Store::USERAGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.0; it-IT; rv:1.7.12) Gecko/20050915';
$Store::HOST = 'http://magiccards.info';
$Store::CARDS = "public/$cards";

get '/' => sub {
    my $login = session 'login';
    my $user = user_by_login ($login);
    if ($login and $user) {
        return template 'index' => {'login' => $login, 'balance' => $user->{balance}};
    } else {
        redirect '/login';
    }
};

post '/' => sub {
    my $cardname = params->{cardname};
    my $login = session 'login';
    my $user = user_by_login ($login);    
    if ($login and $user) {
        my $userid = $user->{id};
        my $cardid = buy_card ($login, $cardname);
        if ($cardid) {
            redirect "/img/$cardid.jpg";
        } else {
            return '<div>Something wend wrong!</div><meta http-equiv="refresh" content="3;url=/"/>';
        }
    }
    else {
        redirect '/login';
    }
};

get '/login' => sub {
    my $login = session 'login';
    if ($login) {
        redirect '/';
    } else {
        template 'login';
    }
};

post '/login' => sub {
    my $login = lc params->{login};
    my $password = params->{password};
    my $user = user_by_login ($login);
    if ($user and $password eq $user->{password}) {
        session 'login' => $login;
        redirect '/';
    } else {
        return '<div>Log in failed, try again</div><meta http-equiv="refresh" content="3;url=/login"/>';
    }
};

get '/logout' => sub {
    app->destroy_session;
    redirect '/login';
};

get '/img/*' => sub {
    my ($cardid) = splat;
    my $login = session 'login';
    my $user = user_by_login ($login);
    if ($login and $user) {
        send_file "$cards/$cardid" if (user_has_card ($user->{id}, $cardid));
    }
    redirect '/login';
};

true;
