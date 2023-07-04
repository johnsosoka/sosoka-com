variable "project_name" {
  default = "sosoka-com"
}

// WWW and Root

variable "domain_name" {
  type = string
  default = "sosoka"
  description = "My websites domain name"
}

variable "domain" {
  type = string
  default = "com"
  description = "The domain my site belongs to"
}
