use v6;

class CommandLine::Usage {

    has Str $.name is required;
    has Sub $.func is required;
    has Str $.desc is required;

    has @.constraint-list;

    has Str $.text-usage                = "\nUsage:  %s%s%s\n\n%s";
    has Str $.text-options              = "Options:\n";
    has Str $.text-commands             = "Commands:\n";

    method parse {
        my @assorted-params;
        my @assorted-candidates;
        my @assorted-explanations;

        # self.get-related-candidates
        # self.parse-subcommands
        
        my @assorted-without-subcommands;
        my @assorted-with-subcommands;
        for $.func.candidates -> $candidate {
            my $param = $candidate.signature.params[0];
            if $param {
                my @constraints = $param.constraint_list();
                if @constraints.elems > 0 {
                    @assorted-with-subcommands.push: $candidate;
                } else {
                    @assorted-without-subcommands.push: $candidate;
                }
            }
        }

        #my $out2-options = self.parse-options(:candidates(@assorted-without-subcommands));
        #say @assorted-without-subcommands[0].WHY;
        #say "out2-options: $out2-options";

        my $out-commands = self.parse-subcommands(:candidates(@assorted-with-subcommands));
        #say "out2-subcommands: $out2-subcommands";

        for $.func.candidates -> $candidate {
            #say "-- CANDIDATE: " ~ $candidate.name;
            my Bool $filter-by-constraint = @.constraint-list.elems > 0; # Are we doing subcommand usage?
            if $filter-by-constraint {
                my Bool $got-it = False;
                loop ( my $i=0; $i < @.constraint-list.elems; $i++ ) {
                    my $param = $candidate.signature.params[$i];
                    my @param-constraints = $param.constraint_list();
                    my Str $first-constraint = @param-constraints[0]; # Probably doesn't scale on more complicated stuff
                    # say "$first-constraint == {@.constraint-list[$i]}";
                    $got-it = $first-constraint eq @.constraint-list[$i];
                    last if $got-it == False;
                    # if @.constraint-list[$i] eq $candidate.signature.params[0].constraint_list[$i];
                }
                if $got-it {
                    @assorted-candidates.push: $candidate;
                    @assorted-explanations.push: $candidate.WHY;
                    # say $got-it;
                }
            }
            #say 'end of filter by constraint';
            #say $candidate.WHY;
        }

        my $out-options = self.parse-options(:candidates(@assorted-candidates));

        # Three blocks: Header (command+explanation), Options if available, Commands if available
        $.desc ||= @assorted-explanations.join("\n");
        my $text-usage-line = sprintf(
            $.text-usage,
            $.name,
            ' ' ~ @.constraint-list.join(' '),
            $out-options ne $.text-options ?? ' [OPTIONS]' !! '',
            $.desc
        );
        my $text-options-line = $out-options ne $.text-options ?? "\n\n{$out-options.trim}" !! '';
        my $text-commands-line = $out-commands ne $.text-commands ?? "\n\n{$out-commands.trim}" !! '';
        my Str $out = '';
        $out ~= $text-usage-line;
        $out ~= $text-options-line;
        $out ~= $text-commands-line;
        $out ~= "\n";
        #say ">> $out <<";
        $out;
    }

    method parse-options (:@candidates) {
        # Go through assorted candidates for option list
        my $out = $.text-options;
        for @candidates -> $candidate {
            for $candidate.signature.params -> $param {
                my $short-param = '';
                my $long-param = '';
                my $default-value = '';

                if $param.perl ~~ / ':' (\w+) '(:$' (\w+) / {
                    $short-param = "-$0";
                    $long-param = "--$1";
                } elsif $param.perl ~~ / ':$' (<[\w-]>+) \s '=' \s \" (.+) \" / {
                    $long-param = "--$0";
                    $default-value = $1;
                    #say "DEFAULT VALUE: $default-value";
                } elsif $param.perl ~~ / ':$' (\w+) / {
                    $long-param = "--$0";
                } else {
                    next;
                } 
                #say $param.perl;
                $short-param ~= $short-param.chars > 0 && $long-param.chars > 0 ?? ', ' !! '  ';
                my $usage = $param.WHY;
                $usage ||= '';
                if $default-value {
                    $usage ~= ' ' if $usage.chars > 0 and $default-value.chars > 0;
                    $usage ~= "(default \"{ $default-value }\")";
                }
                $out ~= sprintf("%6s%-26s%s\n",
                    $short-param.chars > 0 ?? $short-param !! '',
                    $long-param.chars > 0 ?? $long-param !! '',
                    $usage
                    );
            }
        }
        $out;
    }
    
    method parse-subcommands (:@candidates) {
        my %out;
        for @candidates -> $candidate {
            my $param = $candidate.signature.params[0];
            my @constraints = $param.constraint_list();
            next if @constraints.elems == 0;
            my @why-block = $candidate.WHY.contents();
            for @why-block -> $text {
                if $text {
                    %out{@constraints[0]} = @why-block.join("\n");
                }
            }
        }
        my $out = $.text-commands;
        for %out.keys.sort -> $key {
            $out ~= sprintf("%2s%-14s%s\n", '', $key, %out{$key});
        }
        $out;
    }

    method toString {
        "here i am";
    }

    method print {
        say "here i am";
    }

}

