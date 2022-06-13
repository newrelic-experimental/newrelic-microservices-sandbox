
locals {
  # Note: These must be an exact match to New Relic app names (Case sensitive).
  # TODO: templatize this on both sides so that they are guaranteed to be the same
  app_names = ["Gateway", "Superhero Service", "Customers Service"]
}

data "newrelic_entity" "applications" {
  count = "${length(local.app_names)}"
  name = "${element(local.app_names, count.index)}"
  type = "APPLICATION"
  domain = "APM"
  tag {
    key = "accountID"
    value = var.new_relic_account_id
  }
}

resource "newrelic_entity_tags" "application_tags" {
    count = "${length(local.app_names)}"
    guid = "${element(data.newrelic_entity.applications[*].guid, count.index)}"

    tag {
        key = "automation"
        values = ["terraform"]
    }

    tag {
        key = "project"
        values = ["${var.cluster_name}"]
    }
    
    tag {
        key = "owner"
        values = ["${var.owner}"]
    }
}

resource "newrelic_alert_policy" "application_health" {
  name = "Application Health"
}

resource "newrelic_alert_condition" "appplication_error_percentage" {
  policy_id = newrelic_alert_policy.application_health.id

  name        = "Error Percentage (High)"
  type        = "apm_app_metric"
  entities    = data.newrelic_entity.applications[*].application_id
  metric      = "error_percentage"
  condition_scope = "application"

  term {
    duration      = 5
    operator      = "above"
    priority      = "critical"
    threshold     = "0"
    time_function = "all"
  }
}

resource "newrelic_workload" "superheroes_components" {
    name = "Superheroes Components"
    account_id = var.new_relic_account_id

    entity_search_query {
        query = "tags.clusterName = '${var.cluster_name}'"
    }
}

resource "newrelic_entity_tags" "superheroes_components_tags" {
    guid = newrelic_workload.superheroes_components.guid

    tag {
        key = "automation"
        values = ["terraform"]
    }

    tag {
        key = "project"
        values = ["${var.cluster_name}"]
    }
    
    tag {
        key = "owner"
        values = ["${var.owner}"]
    }
}

