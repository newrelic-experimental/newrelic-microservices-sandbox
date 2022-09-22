output "applications" {
  value = data.newrelic_entity.applications
}

output "superheroes_workload" {
  value = newrelic_workload.superheroes_components
}