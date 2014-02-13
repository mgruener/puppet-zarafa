class zarafa::dbhost (
  $mysqlpassword,
  $serverhostname = 'localhost',
  $mysqluser      = 'zarafa',
  $mysqldb        = 'zarafa',
) {

  if downcase($serverhostname) in downcase([ $::fqdn, $::hostname ]) {
    $zarafaserver = 'localhost'
  }
  else {
    $zarafaserver = $serverhostname
  }

  mysql::db { $mysqldb:
    user     => $mysqluser,
    password => $mysqlpassword,
    host     => $zarafaserver
  }
}
