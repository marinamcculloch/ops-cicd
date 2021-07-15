# merge environment config terraform

inputs = merge(
  yamldecode(
    file("${find_in_parent_folders("global_config.yaml")}"),
  ),
  yamldecode(
    file("${find_in_parent_folders("environment_config.yaml")}"),
  ),
  yamldecode(
    file("${find_in_parent_folders("namespace.yaml")}"),
  ),
)

remote_state {
  backend = "s3"
  config = {
    bucket         = "bucket-name"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "aws-region"
    encrypt        = true
  }
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
}


