class zarafa {
  $augeas_lensdir = "/usr/share/augeas/lenses/dist"

  file { "${augeas_lensdir}/zarafa.aug":
    ensure => file,
    source => "puppet:///modules/${module_name}/zarafa.aug",
    owner  => root,
    group  => root,
    mode   => '0644'
  }

  include zarafa::allinone
}
