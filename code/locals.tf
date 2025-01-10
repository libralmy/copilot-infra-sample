locals {
  resource_group_name = "${var.environment_prefix}rg-infra-sample"

  # Diagnostic settings
  diagnostic_settings = {
    defaultDiagnosticSettings = {
      name                  = "Send to Log Analytics (AllLogs, AllMetrics)"
      workspace_resource_id = module.law.id
    }
  }

}