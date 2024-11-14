terraform {
  backend "s3" {
    bucket = "terrawuff"
    key = "github-actions.tfstate"
    region = "eu-central-1"
  }
}