# ---------------------------
# RDS パラメータグループ
# ---------------------------
# family 設定のデフォルトから変更するパラメータを設定していく
resource "aws_db_parameter_group" "master-rds-params" {
  name   = "${local.project_name_env}-master-params"
  family = "mysql5.7"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name         = "collation_server"
    value        = "utf8mb4_bin"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }
  parameter {
    name  = "innodb_buffer_pool_dump_at_shutdown"
    value = "1"
  }
  parameter {
    name         = "innodb_buffer_pool_load_at_startup"
    value        = "0"
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "long_query_time"
    value = "3"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "log_output"
    value = "FILE"
  }
  parameter {
    name  = "log_slow_admin_statements"
    value = "1"
  }
  parameter {
    name  = "max_connect_errors"
    value = "200"
  }
  parameter {
    name  = "max_connections"
    value = "5000"
  }
  # 512KB
  parameter {
    name  = "sort_buffer_size"
    value = "524288"
  }
  # 512KB
  parameter {
    name  = "read_buffer_size"
    value = "524288"
  }
  # 512KB
  parameter {
    name  = "read_rnd_buffer_size"
    value = "524288"
  }
  parameter {
    name         = "skip_name_resolve"
    value        = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "sql_mode"
    value = "NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
  }
  parameter {
    name  = "innodb_print_all_deadlocks"
    value = "1"
  }
  parameter {
    name  = "innodb_status_output"
    value = "1"
  }
  parameter {
    name  = "innodb_status_output_locks"
    value = "1"
  }
}
