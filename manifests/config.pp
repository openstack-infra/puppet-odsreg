# == Class: odsreg::config
#
# This class is used to manage arbitrary odsreg configurations.
#
# === Parameters
#
# [*odsreg_config*]
#   (optional) Allow configuration of arbitrary odsreg configurations.
#   The value is an hash of odsreg_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   odsreg_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class odsreg::config (
  $odsreg_config = {},
) {

  validate_hash($odsreg_config)

  create_resources('odsreg_config', $odsreg_config)
}
