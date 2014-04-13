define zarafa::user (
  $email,
  $password,
  $ensure        = present,
  $features      = undef,
  $groups        = undef,
  $fullname      = undef,
  $admin         = undef,
  $active        = undef,
  $quotaoverride = undef,
  $hardquota     = undef,
  $softquota     = undef,
  $warnquota     = undef,
) {

  zarafauser { $title:
    ensure        => $ensure,
    name          => $name,
    email         => $email,
    password      => $password,
    features      => $features,
    groups        => $groups,
    fullname      => $fullname,
    admin         => $admin,
    active        => $active,
    quotaoverride => $quotaoverride,
    hardquota     => $hardquota,
    softquota     => $softquota,
    warnquota     => $warnquota,
  }

  postfix::virtual { $email:
    destination => $email,
  }
}
