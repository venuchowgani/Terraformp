locals {
    ssh_port            = 22
    http_port           = 80
    all_ports           = 0
    app_port            = 8080
    db_port             = 3306
    any_where           = "0.0.0.0/0"
    any_protocol        = "-1"
    any_where_ipv6       = "::/0"
    tcp                 = "tcp"
    default_description = "Created by Terraform"
}