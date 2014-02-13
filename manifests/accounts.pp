class zarafa::accounts (
  $users = undef,
  $groups = undef,
  $hiera_merge = false,
) {
  $myclass = "${module_name}::accounts"

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

  if $groups != undef {
    if !is_hash($groups) {
        fail("${myclass}::groups must be a hash.")
    }

    if $hiera_merge_real == true {
      $groups_real = hiera_hash("${myclass}::groups",undef)
    } else {
      $groups_real = $groups
    }

    create_resources('zarafagroup',$groups_real)
  }

  if $users != undef {
    if !is_hash($users) {
        fail("${myclass}::users must be a hash.")
    }

    if $hiera_merge_real == true {
      $users_real = hiera_hash("${myclass}::users",undef)
    } else {
      $users_real = $users
    }

    create_resources('zarafauser',$users_real)
  }
}
