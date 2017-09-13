use v6;
use lib 'lib';
use Test;
use CommandLine::Usage;

{
    #| My explanation here
    multi my-main('one', 'two') { ... }
    multi my-main('one', 'three') { ... }
    multi my-main('three') { ... }
    multi my-main('four') { ... }
    my $usage = CommandLine::Usage.new(
        :command-name('my-command'),
        :func(&my-main),
        :constraint-list<one two>
        );
    my $text = $usage.parse;
    my $versus = q:to/END/;
    
    Usage:  my-command one two

    My explanation here
    END
    is $text, $versus, 'my-command one two --help';
}

{
    #| Explanation of subcommand run and it's options
    multi my-main('run',
        Str :$project,
        Str :$network = 'acme',
        Str :$domain = 'localhost',
        Str :$data-path = '~/.platform'
        ) { ... }

    multi my-main('stop',
        Str :$project,
        Str :$data-path = '~/.platform'
        ) { ... }

    my $usage = CommandLine::Usage.new(
        :command-name('my-command'),
        :func(&my-main),
        :constraint-list<run>
        );
    
    my $text = $usage.parse;
    my $versus = q:to/END/;
    
    Usage:  my-command run [OPTIONS]

    Explanation of subcommand run and it's options

    Options:
          --project                 
          --network                 (default "acme")
          --domain                  (default "localhost")
          --data-path               (default "~/.platform")
    END
    is $text, $versus, "my-command run --help";
}
