output "staging_proxy_public_ip" {
  value = "${module.staging_web.public_ip}"
}

output "staging_app_private_ip" {
  value = "${module.staging_app.private_ip}"
}

output "staging_db_private_ip" {
  value = "${module.staging_db.private_ip}"
}

output "staging_backend_private_ip" {
  value = "${module.staging_backend.private_ip}"
}

