Puppet::Type.newtype(:zarafauser) do
  @doc = "Type to create a user in a Zarafa groupware system."

  feature :zarafadbuser,
    "Create a Zarafa user in the Zarafa database."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The username of the user."
  end
  
  newproperty(:features, :array_matching => :all) do
    desc "A list of Zarafa features the user can use, for example 'imap' or 'pop3'"
  end

  newproperty(:groups, :array_matching => :all) do
    desc "A list of groups the user belongs to"
  end

  newproperty(:fullname) do
    desc "The full name of the Zarafa user"
  end

  newparam(:password) do
    desc "The password of the user. Has to be provided as cleartext."
  end

  newproperty(:admin, :boolean => true) do
    desc "Whether the user is an admin or not"

    newvalue(:true)
    newvalue(:false)
    
    defaultto :false
  end
  
  newproperty(:active, :boolean => true) do
    desc "Whether the user is activ (meaning: he can log in) or not"

    newvalue(:true)
    newvalue(:false)

    defaultto :true
  end

  newproperty(:quotaoverride, :boolean => true) do
    desc "Whether to override the system wide quota settings with values specific for this user."

    newvalue(:true)
    newvalue(:false)

    defaultto :false
  end

  newproperty(:hardquota) do
    desc "The hardquota of the user. When reached, the user can no longer receive or send mails/invitations etc."
  end

  newproperty(:softquota) do
    desc "The softquota of the user. When reached, the user can no longer send mails/invitations etc."
  end

  newproperty(:warnquota) do
    desc "The warnquota of the user. When reached, the user will get an email informing him of the quota limits."
  end

  newproperty(:email) do
    desc "The email address of the user"
  end

  autorequire(:zarafagroup) do
    if @parameters[:groups]
      @parameters[:groups]
    end
  end
end
