output "load_balancer_dns" {
    value = aws_lb.dask_lb.dns_name
    description = "DNS address of the load balancer. Provides access to the Jupyter notebook instance."
}