use v6;

say "1..2";

use NativeCall;
use HTTP::Server::Tiny;
use LWP::Simple; # bundled

sub fork()
    returns Int
    is native { ... }

constant SIGTERM = 15;

sub kill(int $pid, int $sig)
    returns Int
    is native { ... }

my $server = HTTP::Server::Tiny.new('127.0.0.1', 0);
my $port = $server.localport;

my $pid = fork();
if $pid == 0 { # child
    $server.run(sub ($env) {
        [200, ['Content-Type' => 'text/plain'], ["hello\n".encode('utf-8')]]
    });
    exit;
} elsif $pid > 0 { # parent
    sleep 0.1;
    my $content = LWP::Simple.get("http://127.0.0.1:$port/");
    say ($content eqv "hello\n" ?? "ok" !! "not ok") ~ " - content";
} else {
    die "fork failed";
}