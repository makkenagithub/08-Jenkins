resource "aws_ecr_repository" "backend" {
  name                 = "expense/backend"      # private repository created with this name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "expense/frontend"     # private repository created with this name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}