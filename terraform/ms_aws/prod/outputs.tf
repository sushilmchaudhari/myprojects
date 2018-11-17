output "prod_proxy_public_ip" {
  value = "${module.prod_web.public_ip}"
}

output "prod_app_private_ip" {
  value = "${module.prod_app.private_ip}"
}

output "prod_db_private_ip" {
  value = "${module.prod_db.private_ip}"
}

output "prod_backend_private_ip" {
  value = "${module.prod_backend.private_ip}"
}

output "prod_legacy_private_ip" {
  value = "${module.prod_legacy.private_ip}"
}

output "prod_wiki_private_ip" {
  value = "${module.prod_wiki.private_ip}"
}
