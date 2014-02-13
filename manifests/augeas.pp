class zarafa::augeas (
  $lensdir = '/usr/share/augeas/lenses/dist'
) {
  file { "${lensdir}/zarafa.aug":
    ensure => file,
    source => "puppet:///modules/${module_name}/zarafa.aug",
    owner  => root,
    group  => root,
    mode   => '0644'
  }
}
