
variable "cluster_name" {
  type  = string
  description = "Name of ECS cluster (default: dask-cluster)"
  default = "dask-cluster"
}

variable "cluster_name2" {
  type  = string
  description = "Name of ECS cluster for master and jupyter"
  default = "dask-cluster2"
}