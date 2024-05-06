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

