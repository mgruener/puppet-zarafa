class zarafa::accounts (
  $users = hiera_hash("${module_name}::accounts::users",undef),
  $groups = hiera_hash("${module_name}::accounts::groups",undef)
) {
  if $groups {
    create_resources('zarafagroup',$groups)
  }

  if $users {
    create_resources('zarafauser',$users)
  }
}
