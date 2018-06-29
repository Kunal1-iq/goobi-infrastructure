module "ecs_service" {
  source = "git::https://github.com/wellcometrust/terraform-modules.git//ecs/service?ref=v10.3.1"
  name   = "goobi"

  cluster_id = "${module.ecs_cluster.cluster_name}"
  vpc_id     = "${module.network.vpc_id}"

  nginx_uri                = "${var.docker_repo}/httpd_proxy:itm_latest"
  app_uri                  = "${var.docker_repo}"
  primary_container_port   = "80"
  secondary_container_port = "8080"

  volume_name      = "digiverso"
  volume_host_path = "/mnt/efs/digiverso/"
  container_path   = "/efs/digiverso/"

  loadbalancer_cloudwatch_id = "${module.ecs_cluster.alb_cloudwatch_id}"

  listener_https_arn = "${module.ecs_cluster.alb_listener_https_arn}"
  listener_http_arn  = "${module.ecs_cluster.alb_listener_http_arn}"

  healthcheck_path = "/goobi/uii/index.xhtml"

  env_vars = {
    HTTPD_PORT    = "80"
    APP_PATH      = "goobi"
    APP_CONTAINER = "goobi"
    ITM_PATH      = "itm"
    ITM_CONTAINER = "itm"
    SERVERNAME    = "${var.workflow_domain_name}"
    HTTPS_DOMAIN  = "${var.workflow_domain_name}"
    DB_SERVER     = "${module.goobi_rds_cluster.host}"
    DB_PORT       = "${module.goobi_rds_cluster.port}"
    DB_NAME       = "${module.goobi_rds_cluster.database_name}"
    DB_USER       = "${module.goobi_rds_cluster.username}"
    DB_PASSWORD   = "${module.goobi_rds_cluster.password}"
    CONFIGSOURCE  = "s3"
    AWS_S3_BUCKET = "${aws_s3_bucket.workflow-configuration.bucket}"
  }

  https_domain = "${var.workflow_domain_name}"
  path_pattern = "/*"

  server_error_alarm_topic_arn = "${module.alb_server_error_alarm.arn}"
  client_error_alarm_topic_arn = "${module.alb_client_error_alarm.arn}"

  log_group_name_prefix = "goobi"
  log_retention_in_days = 60

  task_definition_template_path = "./task-definition.json.template"
}
