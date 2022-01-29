output "alb_cname" {
  value = module.alb.lb_dns_name
}

output "rds_masterpassword" {
  value = nonsensitive(module.drupal-db.db_master_password)
}
output "rds_connectionstring" {
  value = module.drupal-db.db_instance_endpoint
}

output "rds_username" {
  value = nonsensitive(module.drupal-db.db_instance_username)
}
