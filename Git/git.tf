variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "repo_name" {
  description = "Nom du dépôt GitHub"
  type        = string
  default     = "Test"
}

resource "github_membership" "collaborator" {
  username = "theophilegarin@hotmail.com"
  role     = "member"
}

resource "github_repository" "mon_repo" {
  name        = var.repo_name
  description = "Un dépôt créé avec Terraform"
  visibility  = "private"  
}
