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
#   This package must contain a Puppet fileserver URL pointing to the location
#   of the binary RPM package.
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
  $servercertfilepath = $ilmt::params::servercertfilepath,
  $servercustomsslcertificate = $ilmt::params::servercustomsslcertificate,
  $tmpdir = $ilmt::params::tmpdir,
  $useproxy = $ilmt::params::useproxy,
  $version = $ilmt::params::version
) inherits ilmt::params {

  # parameter validation
  validate_re(
    $ensure,
    '^((present|absent|disabled)|\d+(\.\d+)?)$',
    '$ensure must be "present", "absent", "disabled", or a version string.'
  )
  validate_re(
    $securitylevel,
    '^(0|1|2)$',
    '$securitylevel must be "0", "1", or "2".'
  )
  validate_absolute_path($agenttemppath)

  if ( $package ) {
    validate_string($package)
  }
  else {
    notify { '$package parameter not provided, package management disabled.': }
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
      installservercertificate,
      '^(y|n)$',
      '$installservercertificate must be "y" or "n".'
    )
    validate_re(
      servercustomsslcertificate,
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

  $ensure_response_file = $ensure ? {
    'absent' => 'absent',
    default  => 'present',
  }
  file { 'response_file':
    ensure  => $ensure_response_file,
    path    => '/etc/response_file.txt',
    content => template('ilmt/response_file.txt.erb'),
  }

  if ( $package ) {
    $ensure_package_file = $ensure ? {
      'absent' => 'absent',
      default  => 'present',
    }
    $package_file_path = "${tmpdir}/${package_filename}"
    file { 'package_file':
      ensure => $ensure_package_file,
      path   => $package_file_path,
      source => $package,
    }

    $ensure_ilmt_package = $ensure ? {
      'disabled' => 'present',
      default    => $ensure,
    }
    package { 'ilmt_package':
      ensure   => $ensure_ilmt_package,
      name     => $packagename,
      require  => File['package_file','response_file'],
      provider => 'rpm',
      source   => $package_file_path,
    }
  }
}
