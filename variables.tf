
variable "cluster_name" {
  type  = string
  description = "Name of ECS cluster (default: dask-cluster)"
  default = "dask-cluster"
}