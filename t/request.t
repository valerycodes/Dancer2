use strict;
use warnings;
use Test::More;

use Dancer::Core::Request;

my $env = {
    'psgi.url_scheme' => 'http',
    REQUEST_METHOD    => 'GET',
    SCRIPT_NAME       => '/foo',
    PATH_INFO         => '/bar/baz',
    REQUEST_URI       => '/foo/bar/baz',
    QUERY_STRING      => 'foo=42&bar=12&bar=13&bar=14',
    SERVER_NAME       => 'localhost',
    SERVER_PORT       => 5000,
    SERVER_PROTOCOL   => 'HTTP/1.1',
    REMOTE_ADDR       => '127.0.0.1',
    X_FORWARDED_FOR => '127.0.0.2',
    REMOTE_HOST       => 'localhost',
    HTTP_USER_AGENT        => 'Mozilla',
    REMOTE_USER => 'sukria',
};

my $req = Dancer::Core::Request->new(env => $env);

note "tests for accessors";

is $req->agent, 'Mozilla';
is $req->user_agent, 'Mozilla';
is $req->remote_address, '127.0.0.1';
is $req->address, '127.0.0.1';
is $req->forwarded_for_address, '127.0.0.2';
is $req->remote_host, 'localhost';
is $req->protocol, 'HTTP/1.1';
is $req->port, 5000;
is $req->request_uri, '/foo/bar/baz';
is $req->uri, '/foo/bar/baz';
is $req->user, 'sukria';
is $req->script_name, '/foo';
is $req->scheme, 'http';
ok(! $req->secure);
is $req->method, 'GET';
is $req->request_method, 'GET';
ok($req->is_get);
ok(!$req->is_post);
ok(!$req->is_put);
ok(!$req->is_delete);
ok(!$req->is_head);

is $req->id, 1;
is $req->to_string, '[#1] GET /foo/bar/baz';

note "tests params";
is_deeply {$req->params}, { foo => 42, bar => [12, 13, 14]};

my $forward = Dancer::Core::Request->forward($req, {to_url => '/somewhere'});
is $forward->path_info, '/somewhere';
is $forward->method, 'GET';
note "tests for uri_for";
is $req->base, 'http://localhost:5000/foo';
is $req->uri_for('bar', { baz => 'baz' }),
    'http://localhost:5000/foo/bar?baz=baz';

is $req->uri_for('/bar'), 'http://localhost:5000/foo/bar';
ok $req->uri_for('/bar')->isa('URI'), 'uri_for returns a URI';
ok $req->uri_for('/bar', undef, 1)->isa('URI'), 'uri_for returns a URI (with $dont_escape)';

is $req->request_uri, '/foo/bar/baz';
is $req->path_info, '/bar/baz';

{
    local $env->{SCRIPT_NAME} = '';
    is $req->uri_for('/foo'), 'http://localhost:5000/foo';
}

{
    local $env->{SERVER_NAME} = 0;
    is $req->base, 'http://0:5000/foo';
    local $env->{HTTP_HOST} = 'oddhostname:5000';
    is $req->base, 'http://oddhostname:5000/foo';
}
done_testing;