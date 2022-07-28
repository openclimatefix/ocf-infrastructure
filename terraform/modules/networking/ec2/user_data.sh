#!/bin/bash
# This code gets run on the ec2 machine once it starts up

# make empty file
touch /home/ec2-user/.ssh/authorized_keys

# add users public keys
echo "ssh-rsa MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsF0G+f0SQpNaWnuK1YtrxUxjeVCyig5282XdOoqtzd6eM6/OcJyHF7hVkmvltgvNtpdRFCuYFoi/a+ErP00yy6iQbKwJ9SNtKZ2fsvzenQpByStZeqYoZptq2XmgQZ18ozz3Q8a4zATcww81BMm0KxckEKpy7vykg8EfKHvQlE+YsQZYfJrQSUFvMV+DL8p1/NCesR59OAW5wANrlNSI9fJvlvFnwqDhdT7KS2vDr5yH9xcCunLRY/uxTF32qvWSaOnLkBAVukIglR9XpURfshQHhWPMSXJNdo6qBK42gVYbvGWrVd+g5rx4PXvVhGygE8iuoRX1SlznfH2NaRNXNwIDAQAB peter" >> ./authorized_keys
echo "ssh-rsa fff jacob" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-rsa fff jack" >> /home/ec2-user/.ssh/authorized_keys



