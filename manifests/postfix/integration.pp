class zarafa::postfix::integration (
  $listen      = hiera("${module_name}::postfix::integration::listen",'all'),
  $dagenthost  = hiera("${module_name}::postfix::integration::dagenthost",'localhost:2003'),
  $domains     = hiera_array("${module_name}::postfix::integration::domains",$::domain),
  $aliasmaps   = hiera_array("${module_name}::postfix::integration::aliasmaps",'hash:/etc/postfix/virtual'),
  $mailboxmaps = hiera_array("${module_name}::postfix::integration::mailboxmaps",'hash:/etc/postfix/virtual')
) {

  postfix::main { 'inet_interfaces':
    value => $listen
  }
  postfix::main { 'virtual_mailbox_domains':
    value => $domains
  }
  postfix::main { 'virtual_transport':
    value => "lmtp:${dagenthost}"
  }
  postfix::main { 'virtual_mailbox_maps':
    value => $mailboxmaps
  }
  postfix::main { 'virtual_alias_maps':
    value => $aliasmaps
  }
}
