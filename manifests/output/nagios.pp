# == Define: logstash::output::nagios
#
#   The nagios output is used for sending passive check results to nagios
#   via the nagios command file.  For this output to work, your event must
#   have the following fields:  "nagios_host" "nagios_service" This field
#   is supported, but optional:   "nagios_annotation"  The easiest way to
#   use this output is with the grep filter. Presumably, you only want
#   certain events matching a given pattern to send events to nagios. So
#   use grep to match and also to add the required fields.  filter {  
#   grep {     type =&gt; "linux-syslog"     match =&gt; [ "@message",
#   "(error|ERROR|CRITICAL)" ]     add_tag =&gt; [ "nagios-update" ]    
#   add_field =&gt; [       "nagios_host", "%{@source_host}",      
#   "nagios_service", "the name of your nagios service check"     ]   } } 
#   output{   nagios {      # only process events with this tag     tags
#   =&gt; "nagios-update"   } }
#
#
# === Parameters
#
# [*commandfile*] 
#   The path to your nagios command file
#   Value type is string
#   Default value: "/var/lib/nagios3/rw/nagios.cmd"
#   This variable is optional
#
# [*exclude_tags*] 
#   Only handle events without any of these tags. Note this check is
#   additional to type and tags.
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*fields*] 
#   Only handle events with all of these fields. Optional.
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*tags*] 
#   Only handle events with all of these tags.  Note that if you specify a
#   type, the event must also match that type. Optional.
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*type*] 
#   The type to act on. If a type is given, then this output will only act
#   on messages with the same type. See any input plugin's "type"
#   attribute for more. Optional.
#   Value type is string
#   Default value: ""
#   This variable is optional
#
#
#
# === Examples
#
#
#
#
# === Extra information
#
#  This define is created based on LogStash version 1.1.5
#  Extra information about this output can be found at:
#  http://logstash.net/docs/1.1.5/outputs/nagios
#
#  Need help? http://logstash.net/docs/1.1.5/learn
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define logstash::output::nagios(
  $commandfile  = '',
  $exclude_tags = '',
  $fields       = '',
  $tags         = '',
  $type         = '',
) {

  require logstash::params

  #### Validate parameters
  if $fields {
    validate_array($fields)
    $arr_fields = join($fields, "', '")
    $opt_fields = "  fields => ['${arr_fields}']\n"
  }

  if $exclude_tags {
    validate_array($exclude_tags)
    $arr_exclude_tags = join($exclude_tags, "', '")
    $opt_exclude_tags = "  exclude_tags => ['${arr_exclude_tags}']\n"
  }

  if $tags {
    validate_array($tags)
    $arr_tags = join($tags, "', '")
    $opt_tags = "  tags => ['${arr_tags}']\n"
  }

  if $commandfile { 
    validate_string($commandfile)
    $opt_commandfile = "  commandfile => \"${commandfile}\"\n"
  }

  if $type { 
    validate_string($type)
    $opt_type = "  type => \"${type}\"\n"
  }

  #### Write config file

  file { "${logstash::params::configdir}/output_nagios_${name}":
    ensure  => present,
    content => "output {\n nagios {\n${opt_commandfile}${opt_exclude_tags}${opt_fields}${opt_tags}${opt_type} }\n}\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Class['logstash::service'],
    require => Class['logstash::package', 'logstash::config']
  }
}
