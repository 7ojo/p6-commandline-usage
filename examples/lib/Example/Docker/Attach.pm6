unit module Example::Docker::Attach;

use CommandLine::Usage;

#| Attach local standard input, output, and error streams to a running container
multi command('attach',
    :$detach-keys,              #= Override the key sequence for detaching a container
    :$no-stdin,                 #= Do not attach STDIN
    :$sig-proxy                 #= Proxy all received signals to the process (default true)
    ) is export {
    say "i am here on Example::Docker::Attach::command('attach')";
}

multi command('attach',
    Bool :h( :help($help) )     #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :func(&command),
        :constraint-list<attach>
        )
        .parse
        .say;
}
