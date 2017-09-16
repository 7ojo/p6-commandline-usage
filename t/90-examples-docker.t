use v6;
use lib 'lib';
use Test;

plan 1;

my $proc = run <perl6 -Ilib -Iexamples/lib examples/docker>, :out, :err;
my $output = $proc.out.slurp-rest;
my $versus = q:to/END/;

Usage:	docker COMMAND

A self-sufficient runtime for containers

Options:
      --config string      Location of client config files (default "/Users/tojo/.docker")
  -D, --debug              Enable debug mode
      --help               Print usage
  -H, --host list          Daemon socket(s) to connect to
  -l, --log-level string   Set the logging level ("debug"|"info"|"warn"|"error"|"fatal") (default "info")
      --tls                Use TLS; implied by --tlsverify
      --tlscacert string   Trust certs signed only by this CA (default "/Users/tojo/.docker/ca.pem")
      --tlscert string     Path to TLS certificate file (default "/Users/tojo/.docker/cert.pem")
      --tlskey string      Path to TLS key file (default "/Users/tojo/.docker/key.pem")
      --tlsverify          Use TLS and verify the remote
  -v, --version            Print version information and quit

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  build       Build an image from a Dockerfile

Run 'docker COMMAND --help' for more information on a command.
END

is $output, $versus, "docker command's output matches";
