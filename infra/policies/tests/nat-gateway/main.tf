resource "aws_nat_gateway" "fixture" {
  subnet_id     = "subnet-00000000"
  allocation_id = "eipalloc-00000000"
}
