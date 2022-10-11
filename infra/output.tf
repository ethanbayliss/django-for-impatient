output "region" {
  description = "AWS region"
  value       = local.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.name
}

#kubectl config
# aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
