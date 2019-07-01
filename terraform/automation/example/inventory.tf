data "template_file" "inventory" {
  template = "${file("script.sh")}"
  vars {
    APPS = "${join(" ", module.app-ec2.private_ips)}"
    WORKERS = "${join(" ", module.worker-ec2.private_ips)}"
    REDIS_JOBS = "${join(" ", module.ec-redis-jobs.redis_primary_endpoint)}"
    REDIS_CACHE = "${join(" ", module.ec-redis-cache.redis_primary_endpoint)}"
    DB_MASTER = "${join(" ", module.master_db.db_host)}"
    DB_REPLICA = "${join(" ", module.replica.db_host)}"
    ENV = "${lookup(var.tags, "Environment")}"
  }
}

resource "null_resource" "create_inventory" {

    triggers {
        template = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.inventory.rendered}' > /tmp/inventory.sh"
    }
}

resource "null_resource" "run_inventory" {

    triggers {
        template = "${data.template_file.inventory.rendered}"
    }

    depends_on = ["null_resource.create_inventory"]

    provisioner "local-exec" {
        command = "chmod +x /tmp/inventory.sh"
    }

    provisioner "local-exec" {
        command = "/tmp/inventory.sh > inventory/inventory"
    }
}

# Database.yml

data "template_file" "database_yml" {
  template = "${file("templates/database.yml.tpl")}"
  vars {
    DB_USER = "${var.database_user}"
    DB_PASSWORD = "${var.database_passwd}"
    DB_NAME =  "${var.database_name}"
    DB_HOST = "${join(" ", module.master_db.db_host)}"
  }
}

resource "null_resource" "db_yml" {

    triggers {
        template = "${data.template_file.database_yml.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.database_yml.rendered}' > inventory/database.yml"
    }
}

# redis.yml

data "template_file" "redis_yml" {
  template = "${file("templates/redis.yml.tpl")}"
  vars {
    REDIS_CACHE = "${join(" ", module.ec-redis-cache.redis_primary_endpoint)}"
  }
}

resource "null_resource" "redis_yml" {

    triggers {
        template = "${data.template_file.redis_yml.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.redis_yml.rendered}' > inventory/redis.yml"
    }
}


# redis-jobs.yml

data "template_file" "redis_jobs_yml" {
  template = "${file("templates/redis-jobs.yml.tpl")}"
  vars {
    REDIS_JOBS = "${join(" ", module.ec-redis-jobs.redis_primary_endpoint)}"
  }
}

resource "null_resource" "redis_jobs_yml" {

    triggers {
        template = "${data.template_file.redis_jobs_yml.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.redis_jobs_yml.rendered}' > inventory/redis-jobs.yml"
    }
}
