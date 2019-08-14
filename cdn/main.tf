terraform {
  backend "s3" {
    bucket = "paas-cdn-tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-1"
}

variable "domain" {
  default = "test.openregister.org"
}

variable "challenges" {
  default = {}
}

variable "routes" {
  default = []
}

variable "cname" {
  default = ""
}

data "aws_route53_zone" "target" {
  name = var.domain
}

resource "aws_route53_record" "acme" {
  for_each = var.challenges

  zone_id = data.aws_route53_zone.target.zone_id
  type = "TXT"
  name = each.key
  ttl = 120
  records = [ each.value ]
}

resource "aws_route53_record" "cname" {
  for_each = toset(var.routes)

  zone_id = data.aws_route53_zone.target.zone_id
  type = "CNAME"
  name = each.value
  ttl = 60
  records = [ var.cname ]
}
