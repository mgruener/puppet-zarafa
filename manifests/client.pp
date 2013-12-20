class zarafa::client (
  $packages = hiera("${module_name}::client::packages",['zarafa-client', 'zarafa-utils']),
) {
  package { $packages:
    ensure => present
  }
}
