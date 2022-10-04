output "region" {
  description = "AWS region"
  value       = local.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.name
}

#kubectl config
# aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
