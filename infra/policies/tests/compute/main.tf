resource "aws_instance" "fixture" {
  ami           = "ami-00000000"
  instance_type = "t3.micro"
}
