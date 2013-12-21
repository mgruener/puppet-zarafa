class zarafa::component::client (
  $packages = hiera("${module_name}::component::client::packages",['zarafa-client', 'zarafa-utils']),
) {
  package { $packages:
    ensure => present
  }
}
