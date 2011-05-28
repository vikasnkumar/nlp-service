### COPYRIGHT: Selective Intellect LLC
### AUTHOR: Vikas N Kumar
### DATE: 24th May 2011

use Test::More;

BEGIN {
    use_ok('NLP::Service');
}

can_ok('NLP::Service', 'run');

done_testing();
