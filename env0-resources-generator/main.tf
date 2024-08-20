
locals {
  gitlab_workspaces = [for workspace in var.workspaces : workspace if try(workspace.vcs.is_gitlab, false)]
  is_gitlab = length(local.gitlab_workspaces) > 0
}
resource "local_file" "main" {
  content  = templatefile("terraform_templates/main.tftpl", { })
  filename = "${path.module}/out/main.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }
}

resource "local_file" "environments" {
  content  = templatefile("terraform_templates/environments.tftpl", { workspaces = var.workspaces, include_vcs_connection = var.include_vcs_connection})
  filename = "${path.module}/out/environments.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }
}

resource "local_file" "projects" {
  content  = templatefile("terraform_templates/projects.tftpl", { workspaces = var.workspaces })
  filename = "${path.module}/out/projects.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }
}

resource "local_file" "vcs" {
  content  = templatefile("terraform_templates/vcs.tftpl", { modules_num = length(var.modules), include_vcs_connection = var.include_vcs_connection })
  filename = "${path.module}/out/vcs.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }
}

resource "local_file" "modules" {
  content  = templatefile("terraform_templates/modules.tftpl", { modules = var.modules})
  filename = "${path.module}/out/modules.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }
}
resource "local_file" "gitlab" {
  content  = templatefile("terraform_templates/gitlab.tftpl", { workspaces = local.gitlab_workspaces })
  filename = "${path.module}/out/gitlab.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }

  count = local.is_gitlab ? 1 : 0
}


resource "local_file" "variable_sets" {
  content  = templatefile("terraform_templates/variable_sets.tftpl", { variable_sets = var.variable_sets })
  filename = "${path.module}/out/variable_sets.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }
}

resource "local_file" "terraform_variables" {
  content  = templatefile("terraform_templates/terraform_variables.tftpl", {is_gitlab = local.is_gitlab})
  filename = "${path.module}/out/variables.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }
}

