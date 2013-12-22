class zarafa::dbhost (
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $mysqluser      = hiera("${module_name}::dbhost::mysqluser",'zarafa'),
  $mysqlpassword  = hiera("${module_name}::dbhost::mysqlpassword"),
  $mysqldb        = hiera("${module_name}::dbhost::mysqldb",'zarafa'),
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
