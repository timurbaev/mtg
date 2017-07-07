package mtg;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => {'title' => 'mtg'};
};

true;
