#!/bin/bash
# This code gets run on the ec2 machine once it starts up

# make empty file
FILE=/home/ec2-user/.ssh/authorized_keys
if [ -f "$FILE" ]; then
  echo "$FILE exists"
else
  touch $FILE
fi

# add users public keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDG81UYCveCjecpem2ayi4z1LXBD8FWcBKldFodzJGv6YS290Y+FQy88SVjYp/Z+jm2s9AxuO62rFqSvu8flIbZnBAqWpQZj8QPRoP/GwFmV1KU33kVphs527Iev/PTEtCizkCiX8GJqTJtcH3Tv6ntYxI7vGE3s6IP0+VdyHVpwvMm+xT0j8oFFYs7JZvZOzNjPDGRUvKYH68m+hQkFfZatO2dCYB27eEacuo0MysdNLGTGwR0xB50d+AVp4sph34/OU1u76m7HUM1yu3BV70lMJY3AOMDG/uJgwj67xmp7F/g3zI6RRCEhbTe8GZ4oMamRq8mvSGkY3kh4K9qyzWX PD_2021_11_24" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDG+rla+drRNgVEpb2SIgKwVI/cAQ7uUpJMgjNwOuKK/mMi372jRmjeWRypHTxiD0qKNIZUCVJ16xh8/6HNS4NBpU/zVJIAg4w5OiyMoKYQLnuK/Ivi+hfuzzebYhIu862MNOPOCEQqOmwxAJO7MQm2/B6mmVi3oLmCKIAQQa6Oc283x8diQeGkBSzZiqHaV004LUjtKQGP8GsD4jejliqYw5xKECzxQNF4J7QIYq57vOHn8B18gyzLJJ3FqITIQlvj4MccI/Bw8R8njbDxCYZZguvv80qGWnLEbY6N516fjqgxZsqk/6QZ/JtVb9urRtOaY3tLBPTWCLY9b2LxbDkNC2AuAVg08uZHH3NeJWc31FQpXzxCm0GAosepGNiaINH6uyg2Lkcp6ixI0GFfWMjYCy6s9j/NkAGANoFpa8ftxYFn8dn4JZsYwSS4alqxMJWSbdWmG5cxnyijFgaJ6cif3Oi6ZKYM+IpVCJSmTawUPccZT4w9PxVwWSOhazzBgF8= bieker@aerortx" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDpqsUcSvoVex4IpDpUJn7AUYJ9LTDnYhGpNBf7Pww91 jack@openclimatefix.org" >> /home/ec2-user/.ssh/authorized_keys
