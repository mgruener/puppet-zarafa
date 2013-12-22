class zarafa::component::webaccess (
  $packages = hiera("${module_name}::component::webaccess::packages", 'zarafa-webaccess'),
) {
  package { $packages:
    ensure => present
  }
}
