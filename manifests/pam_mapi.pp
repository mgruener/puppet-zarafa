class zarafa::pam_mapi (
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $packages       = hiera("${module_name}::pam_mapi::packages",'pam_mapi'),
  $configure_pam  = hiera("${module_name}::pam_mapi::configure_pam",true)
) {
  package { $packages:
    ensure => present
  }

  if downcase($serverhostname) in downcase([ $::fqdn, $::hostname ]) {
    $zarafaserver = 'localhost'
  }
  else {
    $zarafaserver = $serverhostname
  }

  if $configure_pam {
    file { '/etc/pam.d/smtp':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template("${module_name}/pam_mapi-smtp.erb")
    }
  }
}
