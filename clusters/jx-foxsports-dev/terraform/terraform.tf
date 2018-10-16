terraform {
  required_version = ">= 0.11.0"
  backend "gcs" {
    bucket      = "regal-operand-219605-foxsports-terraform-state"
    prefix      = "jx-foxsports-dev"
  }
}