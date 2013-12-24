Puppet::Type.newtype(:zarafagroup) do
  @doc = "Type to create a group in a Zarafa groupware system."

  feature :zarafadbgroup,
    "Create a Zarafa group in the Zarafa database."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the group."
  end
  
  newproperty(:email) do
    desc "The email address of the group"
  end
end
