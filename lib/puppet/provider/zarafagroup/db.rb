Puppet::Type.type(:zarafagroup).provide(:db) do
  desc "Provides the ability to create zarafa groups using the db user_plugin"

  commands :zarafaadmin => "/bin/zarafa-admin"

  has_features :zarafadbdb

  def exists?
    begin
      zarafaadmin(['--type','group','--details',@resource[:name]])
      return true
    rescue => e
      debug(e.message)
      return false
    end
  end

  def create
    createopts = ['-g',@resource[:name]]
    if @resource[:email]
      createopts << '-e' << @resource[:email]
    end

    zarafaadmin(createopts)
  end

  def destroy
    zarafaadmin(['-G',@resource[:name]])
  end

  def email
    getgroupdetails[:email]
  end

  def email=(value)
    zarafaadmin(['--update-group',@resource[:name],'-e',@resource[:email]])
  end

private
  def getgroupdetails
    groupdetails = { :groups => []}
    rawdetails = zarafaadmin(['--details',@resource[:name],'--type','group'])
    rawdetails.each_line do |line|
      case line
        when /^Groupname:/ then groupdetails[:groupname] = line[/[\w ]*$/]
        when /^Emailaddress:/ then groupdetails[:email] = line[/[\w.@ ]*$/]
      end
    end
    groupdetails
  end
end
