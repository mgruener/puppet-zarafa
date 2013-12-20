define zarafa::option ( $file, $value ) {
  augeas { "zarafa-${file}-${title}":
    context => "/files${file}",
    incl    => $file,
    lens    => 'Zarafa.lns',
    changes => "set ${title} '${value}'",
    require => File["${zarafa::augeas_lensdir}/zarafa.aug"]
  }
}
