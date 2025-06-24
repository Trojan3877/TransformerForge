###############################################################################
#  Snowflake Resources — TransformerForge
#  Requires provider credentials in TF_VARS or ENV:
#   SNOWFLAKE_ACCOUNT, SNOWFLAKE_USERNAME, SNOWFLAKE_PASSWORD
###############################################################################

provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_user
  password = var.snowflake_password
  role     = "SYSADMIN"
  region   = var.snowflake_region
}

###############################################################################
#  1. Warehouse  (XS for metrics, scale as needed)
###############################################################################
resource "snowflake_warehouse" "forge_wh" {
  name            = "COMPUTE_WH"
  warehouse_size  = "XSMALL"
  auto_suspend    = 60    # seconds
  auto_resume     = true
  initially_suspended = true
}

###############################################################################
#  2. Database & Schema
###############################################################################
resource "snowflake_database" "forge_db" {
  name = "FORGE_METRICS"
  comment = "Metrics + registry for TransformerForge"
}

resource "snowflake_schema" "forge_schema" {
  name      = "PUBLIC"
  database  = snowflake_database.forge_db.name
  comment   = "Default schema for TransformerForge data"
}

###############################################################################
#  3. Registry Table
###############################################################################
resource "snowflake_table" "model_registry" {
  database = snowflake_database.forge_db.name
  schema   = snowflake_schema.forge_schema.name
  name     = "MODEL_REGISTRY"

  column {
    name = "ts"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "job_name"
    type = "VARCHAR"
  }
  column {
    name = "base_model"
    type = "VARCHAR"
  }
  column {
    name = "epochs"
    type = "INTEGER"
  }
  column {
    name = "lr"
    type = "FLOAT"
  }
  column {
    name = "model_uri"
    type = "VARCHAR"
  }
}

###############################################################################
#  4. Outputs
###############################################################################
output "snowflake_database" {
  value = snowflake_database.forge_db.name
}

output "snowflake_warehouse" {
  value = snowflake_warehouse.forge_wh.name
}

###############################################################################
#  5. Variables
###############################################################################
variable "snowflake_account"  { type = string }
variable "snowflake_user"     { type = string }
variable "snowflake_password" { type = string }
variable "snowflake_region"   { type = string default = "us-east-1" }
