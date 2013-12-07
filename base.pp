class profile::base ($packages = hiera_hash("${module_name}::base::packages",undef),
                     $sysctlvalues = hiera_hash("${module_name}::base::sysctlvalues",undef),
                     $grubkernelparams = hiera_hash("${module_name}::base::grubkernelparameter",undef),
                     $sshd_config = hiera_hash("${module_name}::base::sshd_config",undef),
                     $sshd_subsystems = hiera_hash("${module_name}::base::sshd_subsystems",undef)) {

  include etckeeper
  include network
  include usermanagement
  include puppet

  if $packages != undef {
    create_resources('package',$packages)
  }
  if $sysctlvalues != undef {
    create_resources('sysctl',$sysctlvalues)
  }
  if $grubkernelparams != undef {
    create_resources('kernel_parameter',$grubkernelparams)
  }
  if $sshd_config != undef {
    create_resources('sshd_config',$sshd_config)
  }
  if $sshd_subsystems != undef {
    create_resources('sshd_config_subsystem',$sshd_subsystems)
  }

  # "brute-force" changes for which I have yet
  # to find a more flexible/scalable solution
  file_line { "root unalias cp":
    ensure => absent,
    line => "alias cp='cp -i'",
    path => "/root/.bashrc"
  }

  file_line { "root unalias mv":
    ensure => absent,
    line => "alias mv='mv -i'",
    path => "/root/.bashrc"
  }

  file_line { "root unalias rm":
    ensure => absent,
    line => "alias rm='rm -i'",
    path => "/root/.bashrc"
  }

  augeas { "grub config":
    context => "/files/etc/grub.conf",
    incl => "/etc/grub.conf",
    lens => "Grub.lns",
    changes => [
      "rm hiddenmenu",
      "rm splashimage",
      "set timeout 10",
    ]
  }
}
