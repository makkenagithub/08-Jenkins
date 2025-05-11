resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}/${var.env}/backend"      # private repository created with this name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}/${var.env}frontend"     # private repository created with this name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}