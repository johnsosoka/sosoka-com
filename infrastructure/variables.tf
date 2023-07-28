variable "project_name" {
  default = "sosoka-com"
}

// All the static sites to create
variable "websites" {
  type = map(string)
  default = {
    "stage" = "stage.sosoka.com",
    "www"   = "www.sosoka.com",
    "root"  = "sosoka.com"
  }
  description = "The websites to create"
}
