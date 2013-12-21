class zarafa::dbhost (
  $serverhostname = hiera("${module_name}::server::hostname",'localhost'),
  $mysqluser      = hiera("${module_name}::dbhost::mysqluser",'zarafa'),
  $mysqlpassword  = hiera("${module_name}::dbhost::mysqlpassword"),
  $mysqldb        = hiera("${module_name}::dbhost::mysqldb",'zarafa'),
) {

  mysql::db { $mysqldb:
    user     => $mysqluser,
    password => $mysqlpassword,
    host     => $serverhostname
  }
}
