class zarafa::postfix::integration (
  $listen      = 'all',
  $dagenthost  = 'localhost:2003',
  $domains     = [ $::domain ],
  $aliasmaps   = [ '/etc/postfix/virtual.alias' ],
  $mailboxmaps = [ '/etc/postfix/virtual' ],
  $hiera_merge = false,
) {
  $myclass = "${module_name}::postfix::integration"

  case type($hiera_merge) {
    'string': {
      validate_re($hiera_merge, '^(true|false)$', "${myclass}::hiera_merge may be either 'true' or 'false' and is set to <${hiera_merge}>.")
      $hiera_merge_real = str2bool($hiera_merge)
    }
    'boolean': {
      $hiera_merge_real = $hiera_merge
    }
    default: {
      fail("${myclass}::hiera_merge type must be true or false.")
    }
  }

  if $domains != undef {
    if !is_array($domains) {
        fail("${myclass}::domains must be an array.")
    }

    if $hiera_merge_real == true {
      $domains_real = hiera_array("${myclass}::domains",undef)
    } else {
      $domains_real = $domains
    }
  }

  if $aliasmaps != undef {
    if !is_array($aliasmaps) {
        fail("${myclass}::aliasmaps must be an array.")
    }

    if $hiera_merge_real == true {
      $aliasmaps_real = hiera_array("${myclass}::aliasmaps",undef)
    } else {
      $aliasmaps_real = $aliasmaps
    }
  }

  if $mailboxmaps != undef {
    if !is_array($mailboxmaps) {
        fail("${myclass}::mailboxmaps must be an array.")
    }

    if $hiera_merge_real == true {
      $mailboxmaps_real = hiera_array("${myclass}::mailboxmaps",undef)
    } else {
      $mailboxmaps_real = $mailboxmaps
    }
  }

  postfix::main { 'inet_interfaces':
    value => $listen
  }
  postfix::main { 'virtual_mailbox_domains':
    value => $domains_real
  }
  postfix::main { 'virtual_transport':
    value => "lmtp:${dagenthost}"
  }
  postfix::main { 'virtual_mailbox_maps':
    value => "hash:${mailboxmaps_real}"
  }
  postfix::main { 'virtual_alias_maps':
    value => "hash:${aliasmaps_real}"
  }

  postfix::hash { $aliasmaps_real:
    ensure => present
  }

  postfix::hash { $mailboxmaps_real:
    ensure => present
  }
}
