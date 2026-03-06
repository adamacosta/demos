variable "network_name" {
  default = null
  type    = string
}

variable "root_disk_size" {
  default = "40Gi"
  type    = string
}

variable "run_strategy" {
  default = "RerunOnFailure"
  type    = string
}

variable "vm_cpus" {
  default = 2
  type    = number
}

variable "vm_image" {
  default = null
  type    = string
}

variable "vm_name" {
  default = null
  type    = string
}

variable "vm_namespace" {
  default = "harvester-public"
  type    = string
}

variable "vm_ram" {
  default = "4Gi"
  type    = string
}