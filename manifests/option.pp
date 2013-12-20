define zarafa::option ( $file, $option = $title, $value ) {
  augeas { "zarafa-${file}-${title}":
    context => "/files${file}",
    incl    => $file,
    lens    => 'Zarafa.lns',
    changes => "set ${option} '${value}'",
    require => File["${zarafa::augeas_lensdir}/zarafa.aug"]
  }
}
