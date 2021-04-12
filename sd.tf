resource "aws_service_discovery_private_dns_namespace" "namespace_dask" {
    name = "ds"
    vpc = data.aws_vpc.main.id
}

resource "aws_service_discovery_service" "sd_dask" {
    name = "sc"

    dns_config {
        namespace_id = aws_service_discovery_private_dns_namespace.namespace_dask.id

        dns_records {
            ttl = 300
            type = "A"
        }
    }
}