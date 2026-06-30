terraform {
  backend "s3" {
    # Static config — dynamic values (bucket, key, region) passed via:
    #   terraform init -backend-config="envs/<env>/backend.hcl"
    use_lockfile = true
    encrypt      = true
  }
}
