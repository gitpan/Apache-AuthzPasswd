use ExtUtils::MakeMaker;

print "Checking for Apache::AuthenPasswd ........ ";
eval {
    require Apache::AuthenPasswd;
};
if ($@) {
    print "failed\n";
    print <<EOT;
$@
You probably need the Apache::AuthenPasswd module.

It would be pretty strange to authorize users based on a users membership
in the /etc/group file, without having authenticated them against the
/etc/passwd file first, but I suppose it's possbile.

If in doubt, get and install Apache::AuthenPasswd module first.
EOT
} else {
    print " ok\n";
}

WriteMakefile(
    'NAME'	=> 'Apache::AuthzNIS',
    'VERSION_FROM' => 'AuthzNIS.pm', # finds $VERSION
    'dist' => {COMPRESS => 'gzip', SUFFIX => 'gz'}
);
