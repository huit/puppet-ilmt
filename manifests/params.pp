# Class:: ilmt::params
#
#
class ilmt::params {
  $ensure = 'present'
  $agentcertfilepath = ''
  $agenttemppath = '/tmp/itlm'
  $citinstallpath = ''
  $fipsenabled = 'n'
  $installservercertificate = 'n'
  $messagehandleraddress = 'localhost'
  $port = 9988
  $proxyaddress = 'none'
  $proxyport = 3128
  $scangroup = 'DEFAULT'
  $secureall = 9977
  $secureauth = 9999
  $securitylevel = 0
  $servercertfilepath = ''
  $servercustomsslcertificate = 'n'
  $tmpdir = '/tmp'
  $useproxy = 'n'
  $version = '7.5.0.115'
} # Class:: ilmt::params
