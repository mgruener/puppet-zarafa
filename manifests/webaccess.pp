class zarafa::webaccess (
  $packages = hiera("${module_name}::client::packages", 'zarafa-webaccess'),
) {
  package { $packages:
    ensure => present
  }
}
