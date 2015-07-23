# Class:: ilmt::params
#
class ilmt::params {
  $ensure = 'present'
  $agentcert = false
  $agentcertfilepath = ''
  $agenttemppath = '/tmp/ilmt'
  $citinstallpath = ''
  $fipsenabled = 'n'
  $installservercertificate = 'n'
  $messagehandleraddress = 'localhost'
  $package = false
  $port = 9988
  $proxyaddress = 'none'
  $proxyport = 3128
  $scangroup = 'DEFAULT'
  $secureall = 9977
  $secureauth = 9999
  $securitylevel = 0
  $servercert = false
  $servercertfilepath = ''
  $servercustomsslcertificate = 'n'
  $tmpdir = '/tmp'
  $useproxy = 'n'
  $version = '7.5.0.115'

  if $::architecture == 's390x' {
  
    $machinetype = 'z9'
    $processortype = 'IFL' 
    $sharedpoolcapacity = 0
    $systemactiveprocessors = 0    # Value required if running on zLinux

  }

}
