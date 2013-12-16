# Class:: ilmt::security
#
#
class ilmt::security (
  $securitylevel = $ilmt::params::securitylevel,
  $agentcert = $ilmt::params::agentcert,
  $agentcertfilepath = $ilmt::params::agentcertfilepath,
  $servercert = $ilmt::params::servercert,
  $servercertfilepath = $ilmt::params::servercertfilepath,
) inherits ilmt::params {
  File {
    owner => 'root',
    group => 'root',
    mode  => 0600
  }

  if ( $securitylevel > 0 ) {
    # server certificate
    file { 'ilmt_server_certificate':
      ensure  => 'present',
      path    => $servercertfilepath,
      content => $servercert,
    }

    if ( $securitylevel > 1 ) {
      # agent certificate
      file { 'ilmt_agent_certificate':
        ensure  => 'present',
        path    => $agentcertfilepath,
        content => $agentcert,
      }
    }
  }
} # Class:: ilmt::security
