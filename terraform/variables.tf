# ================================
# Variables (variables.tf)
# ================================

variable "aws_region" {
  default = "us-west-2"
}

variable "github_org" {
  default = "datascientest-fastAPI-project-group-26"
}

variable "github_repo" {
  default = "fastAPI-project-release"
}

variable "argocd_app_name" {
  default = "fastapi-app"
}

variable "argocd_app_path" {
  default = "helm"
}
