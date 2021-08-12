dependency "ecs" {
  config_path = "../"
}

inputs = {
  cluster_id = dependency.ecs.outputs.ecs_cluster_id
}

include {
  path = find_in_parent_folders("base.hcl")
}
