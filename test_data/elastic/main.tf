module "elasticsearch" {
  source  = "infrahouse/elasticsearch/aws"
  version = "~> 0.6"
  providers = {
    aws     = aws
    aws.dns = aws
  }
  cluster_name         = local.cluster_name
  cluster_master_count = 3
  cluster_data_count   = 1
  environment          = var.environment
  internet_gateway_id  = module.service-network.internet_gateway_id
  key_pair_name        = aws_key_pair.test.key_name
  subnet_ids           = module.service-network.subnet_private_ids
  zone_id              = var.zone_id
  bootstrap_mode       = var.bootstrap_mode
}

resource "aws_key_pair" "test" {
  #  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDpgAP1z1Lxg9Uv4tam6WdJBcAftZR4ik7RsSr6aNXqfnTj4civrhd/q8qMqF6wL//3OujVDZfhJcffTzPS2XYhUxh/rRVOB3xcqwETppdykD0XZpkHkc8XtmHpiqk6E9iBI4mDwYcDqEg3/vrDAGYYsnFwWmdDinxzMH1Gei+NPTmTqU+wJ1JZvkw3WBEMZKlUVJC/+nuv+jbMmCtm7sIM4rlp2wyzLWYoidRNMK97sG8+v+mDQol/qXK3Fuetj+1f+vSx2obSzpTxL4RYg1kS6W1fBlSvstDV5bQG4HvywzN5Y8eCpwzHLZ1tYtTycZEApFdy+MSfws5vPOpggQlWfZ4vA8ujfWAF75J+WABV4DlSJ3Ng6rLMW78hVatANUnb9s4clOS8H6yAjv+bU3OElKBkQ10wNneoFIMOA3grjPvPp5r8dI0WDXPIznJThDJO5yMCy3OfCXlu38VDQa1sjVj1zAPG+Vn2DsdVrl50hWSYSB17Zww0MYEr8N5rfFE= aleks@MediaPC"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBVMh/uBvxKF88z0VxbFYJwhGJklVWf90HJOiESQetC8AJXx6M0x9faPiK5z/SsFjNerCU9TwUZzEgLudB3OWm/X8BChGH3r1g5MsP3FpCd2UCQGu5/0jdX60TePhQ+4SVuoYpjaKIKhulzKM+lEcsJHIk+pM+cKA9yCt4rWghgp7OLXAJE2cA0qy0vv/DytReHoEPFFFtrKUSltmQhu1ggGXH+5pb7kFx2GWLElhVAeG0d+mJdRUXXnDzqjGvW2IrmOAcKJXkF5m9ITjKn55UiuZIPx4k/iLMQQ+am2F/VlttAdEl8Tgo27Q5UhqAH08sHrVnr1qciS8Rdavt8rNPSseFVh7e3wVvMBH4NvEd2gVPThssxlC7BjIfLQGb1jFiRdMHagbG4U4vtpr2pus2PnmcMOQwdC3WjvmyXHjCRQiS16FwJburRfBKGhQf30wjyzvyJ3PDMk4Sni/3Gl69TKb2s91Zq56yhCCrUjMhTtqjmdNvD8jEmIswV+fTyoU= aleks@Black-MBP"
}
