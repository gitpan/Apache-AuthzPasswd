package Apache::AuthzPasswd;

use strict;
use Apache::Constants ':common';

$Apache::AuthzPasswd::VERSION = '0.10';

sub handler {
    my $r = shift;
    my $requires = $r->requires;
    return OK unless $requires;

    my $name = $r->connection->user;

    for my $req (@$requires) {
        my($require, @list) = split /\s+/, $req->{requirement};

	#ok if user is one of these users
	if ($require eq "user") {
	    return OK if grep $name eq $_, @list;
	}
	#ok if user is simply authenticated
	elsif ($require eq "valid-user") {
	    return OK;
	}
	elsif ($require eq "group") {
	    foreach my $thisgroup (@list) {
		my ($group, $passwd, $gid, $members) = getgrnam $thisgroup;
		unless($group) {
		    $r->note_basic_auth_failure;
		    $r->log_reason("Apache::AuthzPasswd - group: $thisgroup unknown", $r->uri);
		    return SERVER_ERROR;
		}
		if($members =~ /\b$userin\b/) {
		    return OK;
		}
	    }
	}
    }
    
    $r->note_basic_auth_failure;
    $r->log_reason("Apache::AuthzPasswd - user $name: not authorized", $r->uri);
    return AUTH_REQUIRED;
}

1;

__END__

=head1 NAME

Apache::AuthzPasswd - mod_perl /etc/group Group Authorization module

=head1 SYNOPSIS

    <Directory /foo/bar>
    # This is the standard authentication stuff
    AuthName "Foo Bar Authentication"
    AuthType Basic

    # The following is needed when you will authenticate
    # via /etc/passwd as well as authorize via /etc/group.
    # Apache::AuthenPasswd is a separate module.
    PerlAuthenHandler Apache::AuthenPasswd

    # Standard require stuff, users, groups and
    # "valid-user" all work OK
    require user username1 username2 ...
    require group groupname1 groupname2 ...
    require valid-user

    PerlAuthzHandler Apache::AuthzPasswd

    </Directory>

    These directives can also be used in the <Location> directive or in
    an .htaccess file.

= head1 DESCRIPTION

For starters, this module could just as well be named Apache::AuthzGroup,
since it has nothing to do with /etc/passwd, but rather works with
/etc/group.  However, I prefer this name in order to maintain the
association with Apache::AuthenPasswd, since chances are they will be used
together.

This perl module is designed to work with mod_perl and the
Apache::AuthenPasswd module by Demetrios E. Paneras (B<dep@media.mit.edu>).
It is a direct adaptation (i.e. I modified the code) of Michael Parker's
(B<parker@austx.tandem.com>) Apache::AuthenSmb module (which also included
an authorization routine).

The module calls B<getgrnam> using each of the B<require group> elements as
keys, until a match with the (already authenticated) B<user> is found.

For completeness, the module also handles B<require user> and B<require
valid-user> directives.

= head2 Apache::AuthenPasswd vs. Apache::AuthzPasswd

I've taken "authentication" to be meaningful only in terms of a user and
password combination, not group membership.  This means that you can use
Apache::AuthenPasswd with the B<require user> and B<require valid-user>
directives.  In the /etc/passwd and /etc/group context I consider B<require
group> to be an "authorization" concern.  I.e., group authorization
consists of establishing whether the already authenticated user is a member
of one of the indicated groups in the B<require group> directive.  This
process may be handled by B<Apache::AuthzPasswd>.  Admittedly, AuthzPasswd
is a misnomer, but I wanted to keep AuthenPasswd and AuthzPasswd related,
if only by name.

I welcome any feedback on this module, esp. code improvements, given
that it was written hastily, to say the least.

=head1 AUTHOR

Demetrios E. Paneras <dep@media.mit.edu>

=head1 COPYRIGHT

Copyright (c) 1998 Demetrios E. Paneras, MIT Media Laboratory.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
