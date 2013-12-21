define zarafa::option (
  $option = $title,
  $value,
  $file
) {
  augeas { "zarafa-${file}-${title}":
    context => "/files${file}",
    incl    => $file,
    lens    => 'Zarafa.lns',
    changes => "set ${option} '${value}'",
    require => Class["${module_name}::augeas"]
  }
}
