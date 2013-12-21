class zarafa::component::webaccess (
  $packages = hiera("${module_name}::component::client::packages", 'zarafa-webaccess'),
) {
  package { $packages:
    ensure => present
  }
}
