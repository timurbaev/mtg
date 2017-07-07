#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use mtg;

mtg->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    mtg->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use mtg;
use Plack::Builder;

builder {
    enable 'Deflater';
    mtg->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use mtg;
use mtg_admin;

builder {
    mount '/'      => mtg->to_app;
    mount '/admin'      => mtg_admin->to_app;
}

=end comment

=cut

