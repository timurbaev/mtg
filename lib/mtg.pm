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
    template 'index' => {'title' => 'mtg'};
};

true;
