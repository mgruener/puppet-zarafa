Puppet::Type.type(:zarafauser).provide(:db) do
  desc "Provides the ability to create zarafa users using the db user_plugin"

  commands :zarafaadmin => "/bin/zarafa-admin"

  has_features :zarafadbuser

  def exists?
    begin
      zarafaadmin(['--type','user','--details',@resource[:name]])
      return true
    rescue => e
      debug(e.message)
      return false
    end
  end

  def create
    raise Puppet::Error, "You have to provide a full name for user #{@resource[:name]}" unless @resource[:fullname]
    raise Puppet::Error, "You have to provide an email address for user #{@resource[:name]}" unless @resource[:email]
    raise Puppet::Error, "You have to provide a password for user #{@resource[:name]}" unless @resource[:password]

    createopts = ['-c',@resource[:name],'-p',@resource[:password],'-f',@resource[:fullname],'-e',@resource[:email]]
    updateopts = ['-u',@resource[:name]]
    if @resource[:admin] == :true
      createopts << '-a' << 'yes'
    end

    if @resource[:active] == :false
      createopts << '-n' << 'yes'
    end

    if @resource[:quotaoverride] == :true
      updateopts << '--qo' << 'yes'
    end

    if @resource[:hardquota]
      updateopts << '--qh' << @resource[:hardquota]
    end

    if @resource[:softquota]
      updateopts << '--qs' << @resource[:softquota]
    end

    if @resource[:warnquota]
      updateopts << '--qw' << @resource[:warnquota]
    end

    zarafaadmin(createopts)

    if updateopts.length > 2
      zarafaadmin(updateopts)
    end

    if @resource[:groups]
      @resource[:groups].each do |group|
        zarafaadmin(['-b',@resource[:name],'-i',group])
      end
    end

    if @resource[:features]
      @resource[:features].each do |feature|
        zarafaadmin(['-u',@resource[:name],'--enable-feature',feature])
      end
    end
  end

  def destroy
    zarafaadmin(['-d',@resource[:name]])
  end

  def features
    getuserdetails[:features]
  end

  def features=(value)
    oldfeatures = features

    Array(value).each do |feature|
      if !oldfeatures.include?(feature)
        zarafaadmin('-u',@resource[:name],'--enable-feature',feature)
      end
    end

    Array(oldfeatures).each do |oldfeature|
      if (!value.include?(oldfeature)) && (!oldfeature.empty?)
        zarafaadmin('-u',@resource[:name],'--disable-feature',oldfeature)
      end
    end
  end

  def groups
    getuserdetails[:groups]
  end

  def groups=(value)
    oldgroups = groups

    Array(value).each do |group|
      if !oldgroups.include?(group)
        zarafaadmin('-b',@resource[:name],'-i',group)
      end
    end

    Array(oldgroups).each do |oldgroup|
      if (!value.include?(oldgroup)) && (!oldgroup.empty?)
        zarafaadmin('-B',@resource[:name],'-i',oldgroup)
      end
    end
  end

  def fullname
    getuserdetails[:fullname]
  end

  def fullname=(value)
    zarafaadmin(['-u',@resource[:name],'-f',@resource[:fullname]])
  end

  def admin
    if getuserdetails[:admin] == 'yes'
      :true
    else
      :false
    end
  end

  def admin=(value)
    if value == :true
      zarafaadmin(['-u',@resource[:name],'-a','yes'])
    else
      zarafaadmin(['-u',@resource[:name],'-a','no'])
    end
  end

  def active
    if getuserdetails[:active] == 'yes'
      :true
    else
      :false
    end
  end

  def active=(value)
    if value == :true
      zarafaadmin(['-u',@resource[:name],'-n','no'])
    else
      zarafaadmin(['-u',@resource[:name],'-n','yes'])
    end
  end

  def quotaoverride
    if getuserdetails[:quotaoverride] == 'yes'
      :true
    else
      :false
    end
  end

  def quotaoverride=(value)
    if value == :true
      zarafaadmin(['-u',@resource[:name],'--qo','yes'])
    else
      zarafaadmin(['-u',@resource[:name],'--qo','no'])
    end
  end

  def hardquota
    quota = getuserdetails[:hardquota]
    if quota == 'unlimited'
      0
    else
      quota.to_i
    end
  end

  def hardquota=(value)
    zarafaadmin(['-u',@resource[:name],'--qh',@resource[:hardquota]])
  end

  def softquota
    quota = getuserdetails[:softquota]
    if quota == 'unlimited'
      0
    else
      quota.to_i
    end
  end

  def softquota=(value)
    zarafaadmin(['-u',@resource[:name],'--qs',@resource[:softquota]])
  end

  def warnquota
    quota = getuserdetails[:warnquota]
    if quota == 'unlimited'
      0
    else
      quota.to_i
    end
  end

  def warnquota=(value)
    zarafaadmin(['-u',@resource[:name],'--qw',@resource[:warnquota]])
  end

  def email
    getuserdetails[:email]
  end

  def email=(value)
    zarafaadmin(['-u',@resource[:name],'-e',@resource[:email]])
  end

private
  def getuserdetails
    userdetails = { :groups => []}
    foundgroups = false
    rawdetails = zarafaadmin(['--details',@resource[:name],'--type','user'])
    # go through each line of the zarafa-admin --details output and extract
    # the relevant information.
    # When a line starts with Groups, start collection the user groups
    # because all following lines contain the groups the user is member of
    rawdetails.each_line do |line|
      case line
        when /^Username:/ then userdetails[:username] = line[/[\w ]*$/]
        when /^Fullname:/ then userdetails[:fullname] = line[/[\w ]*$/]
        when /^Emailaddress:/ then userdetails[:email] = line[/[\w.@ ]*$/]
        when /^Active:/ then userdetails[:active] = line[/[\w ]*$/]
        when /^Administrator:/ then userdetails[:admin] = line[/[\w ]*$/]
        when /^ Quota overrides:/ then userdetails[:quotaoverride] = line[/[\w ]*$/]
        when /^ Warning level:/ then userdetails[:warnquota] = line[/[\w ]*$/]
        when /^ Soft level:/ then userdetails[:softquota] = line[/[\w ]*$/]
        when /^ Hard level:/ then userdetails[:hardquota] = line[/[\w ]*$/]
        when /^\tPR_EC_ENABLED_FEATURES\t/ then
          tmp = line.lstrip.rstrip.split('	')[1]
          if tmp
            userdetails[:features] = tmp.delete(' ').split(';')
          end
        when /^Groups / then foundgroups = true
        else
          if foundgroups
            group = line.lstrip.rstrip
            if (!group.empty?) && (group != 'Everyone')
              userdetails[:groups] << group
            end
          end
      end
    end
    userdetails
  end
end
