# == Class: ilmt
#
# This class deploys the IBM License Metric Tool.
#
# As a prerequisite for using this class, you must download the binary RPM
# package from IBM's support site and placing this package somewhere within
# your puppetmaster's fileserver.
#
# === Parameters
#
# *ensure*
#   Set this parameter to "present" to install the package and start the agent,
#   "absent" to stop the agent and uninstall the package, "disabled" to install
#   the package and stop the agent, and a version string to install a specific
#   version of the package and start the agent.
#
# *package*
#   This package may contain a Puppet fileserver URL pointing to the location
#   of the binary RPM package.  If no value is provided for this parameter,
#   Puppet will attempt to install the binary RPM package via yum.
#
# *securitylevel*
#   Set this parameter to 0 for no encryption, 1 for server certificate
#   encryption (you must provide a value for the *servercert* parameter), or 2
#   for agent certificate encryption (you must provide values for the
#   *servercert* and *agentcert* parameters).
#
# *servercert*
#   Provide the string content of the server public certificate.
#
# *agentcert*
#   Provide the string content of the agent public certificate.
#
# === Examples
#
#  class { ilmt:
#    package => 'puppet:///depot/ILMT-TAD4D-agent-7.5.0.115-linux-x86.rpm',
#  }
#
# === Authors
#
# Steve Huff <steve_huff@harvard.edu>
#
# === Copyright
#
# Copyright 2013 President and Fellows of Harvard University
#
class ilmt (
  $ensure = $ilmt::params::ensure,
  $agentcert = $ilmt::params::agentcertfilepath,
  $agentcertfilepath = $ilmt::params::agentcertfilepath,
  $agenttemppath = $ilmt::params::agenttemppath,
  $citinstallpath = $ilmt::params::citinstallpath,
  $fipsenabled = $ilmt::params::fipsenabled,
  $installservercertificate = $ilmt::params::installservercertificate,
  $messagehandleraddress = $ilmt::params::messagehandleraddress,
  $package = $ilmt::params::package,
  $port = $ilmt::params::port,
  $proxyaddress = $ilmt::params::proxyaddress,
  $proxyport = $ilmt::params::proxyport,
  $scangroup = $ilmt::params::scangroup,
  $secureall = $ilmt::params::secureall,
  $secureauth = $ilmt::params::secureauth,
  $securitylevel = $ilmt::params::securitylevel,
  $servercert = $ilmt::params::servercert,
  $servercertfilepath = $ilmt::params::servercertfilepath,
  $servercustomsslcertificate = $ilmt::params::servercustomsslcertificate,
  $tmpdir = $ilmt::params::tmpdir,
  $useproxy = $ilmt::params::useproxy,
  $version = $ilmt::params::version,

  # IBM S390/S390x support
  $machinetype = $ilmt::params::machinetype,
  $processortype = $ilmt::params::processortype,
  $sharedpoolcapacity = $ilmt::params::sharedpoolcapacity,
  $systemactiveprocessors = $ilmt::params::systemactiveprocessors,

) inherits ilmt::params {

  # parameter validation
  validate_re(
    $ensure,
    '^((present|absent|disabled)|\d+(\.\d+)?)$',
    '$ensure must be "present", "absent", "disabled", or a version string.'
  )

  # Validate S390 variables only if we're running on s390 architecture.
  if ($::architecture == 's390') or ($::architecture == 's390x') {
    validate_re(
      $machinetype,
      '^(z9|z10)$',
      '$machinetype must be "z9" or "z10".'
    )
    validate_re(
      $processortype,
      '^(CP|IFL)$',
      '$processortype must be "CP" or "IFL".'
    )
    validate_re(
      $sharedpoolcapacity,
      '^\d+$',
      '$sharedpoolcapacity must be an integer.'
    )
    validate_re(
      $systemactiveprocessors,
      '^\d+$',
      '$systemactiveprocessors must be a positive integer.'
    )
  }

  validate_re(
    $securitylevel,
    '^(0|1|2)$',
    '$securitylevel must be "0", "1", or "2".'
  )
  validate_absolute_path($agenttemppath)

  if ( $package ) {
    validate_string($package)
  }

  validate_string($port)
  validate_string($messagehandleraddress)
  validate_string($scangroup)

  validate_re($useproxy, '^(y|n)$', '$useproxy must be "y" or "n".')
  if ( str2bool($useproxy) ) {
    validate_re($proxyport, '^\d+$', '$proxyport must be a numeric port.')
    validate_string($proxyaddress)
  }

  validate_re($fipsenabled, '^(y|n)$', '$fipsenabled must be "y" or "n".')

  if ( $citinstallpath ) {
    validate_absolute_path($citinstallpath)
  }

  if ( $securitylevel > 0 ) {
    validate_string($secureauth)

    validate_re(
      $installservercertificate,
      '^(y|n)$',
      '$installservercertificate must be "y" or "n".'
    )
    validate_re(
      $servercustomsslcertificate,
      '^(y|n)$',
      '$servercustomsslcertificate must be "y" or "n".'
    )
    if (
      str2bool($installservercertificate) and
      str2bool($servercustomsslcertificate)
    ) {
      validate_absolute_path($servercertfilepath)
      validate_re(
        $servercertfilepath,
        'cert\.arm$',
        '$servercertfilepath must end in "cert.arm".'
      )
    }

    if ( $securitylevel > 1 ) {
      validate_string($secureall)
      validate_absolute_path($agentcertfilepath)
    }
  }

  # platform compatibility
  case $::osfamily {
    'RedHat': {
      $packagename = 'ILMT-TAD4D-agent'
      $package_filename = "${packagename}-${version}-linux-x86.rpm"
    }
    default: {
      fail("'${::osfamily}' platform is not supported.")
    }
  }

  File {
    owner   => 'root',
    group   => 'root',
    mode    => 0600,
  }

  $ilmt_package_provider = 'yum'

  $ensure_response_file = $ensure ? {
    'absent' => 'absent',
    default  => 'present',
  }

  file { 'response_file':
    ensure  => $ensure_response_file,
    path    => '/etc/response_file.txt',
    content => template('ilmt/response_file.txt.erb'),
    notify  => Service['ilmt_service'],
  }

  if ( $package ) {
    $ilmt_package_source = "${tmpdir}/${package_filename}"
    $ensure_package_file = $ensure ? {
      'absent' => 'absent',
      default  => 'present',
    }
    file { 'package_file':
      ensure => $ensure_package_file,
      path   => $ilmt_package_source,
      source => $package,
      before => Package['ilmt_package'],
    }
  }
  else {
    $ilmt_package_source = undef
  }

  $ensure_ilmt_package = $ensure ? {
    'disabled' => 'present',
    default    => $ensure,
  }
  package { 'ilmt_package':
    ensure   => $ensure_ilmt_package,
    name     => $packagename,
    require  => File['response_file'],
    provider => $ilmt_package_provider,
    source   => $ilmt_package_source,
  }

  $ensure_ilmt_service = $ensure ? {
    'absent'   => 'stopped',
    'disabled' => 'stopped',
    default    => 'running',
  }
  $ensure_ilmt_service_enable = $ensure ? {
    'present' => true,
    default   => false
  }
  service { 'ilmt_service':
    ensure     => $ensure_ilmt_service,
    name       => 'tlm',
    require    => Package['ilmt_package'],
    subscribe  => Package['ilmt_package'],
    enable     => $ensure_ilmt_service_enable,
    hasrestart => false
  }

  if ( $securitylevel > 0 ) {
    class { 'ilmt::security':
      securitylevel      => $securitylevel,
      servercert         => $servercert,
      servercertfilepath => $servercertfilepath,
      agentcert          => $agentcert,
      agentcertfilepath  => $agentcertfilepath,
      before             => Package['ilmt_package'],
    }
  }
}
