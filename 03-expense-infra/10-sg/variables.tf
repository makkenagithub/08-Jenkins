variable "project_name" {
    default = "expense"
}

variable "env" {
    default = "dev"
}

variable "sg_name" {
    default = ""
}

variable "common_tags" {
    default = {
        Project = "expense"
        Terraform = "true"
        Env = "dev"
    }

}

variable "mysql_sg_tags" {
    default = {
        Component = "mysql"
    }

}



