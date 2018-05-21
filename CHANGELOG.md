
## 1.0.0-rc2 (2018-05-21)

BACKWARDS INCOMPATIBILITIES / NOTES:

  * Update Prometheus to 2.2.1.
  * Change `prometheus_ip` output to `prometheus_primaryip`. 
  * Remove `role_tag_value` variable and `prometheus_role_tag` output.

IMPROVEMENTS:

  * Add `cns_fqdn_base` variable to allow customization of CNS names.
  * Change firewall rules to rely on CNS service names instead of (now removed) `role` tag.
  
## 1.0.0-rc1 (2018-02-10)

  * Initial working example
