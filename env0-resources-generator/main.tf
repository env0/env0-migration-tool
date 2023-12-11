resource "local_file" "main" {
  content  = templatefile("terraform_templates/main.tftpl", { })
  filename = "${path.module}/out/main.tf"

  provisioner "local-exec" {
    command = "terraform fmt ${self.filename}"
  }
}

resource "local_file" "environments" {
  content  = templatefile("terraform_templates/environments.tftpl", { workspaces = var.workspaces })
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
