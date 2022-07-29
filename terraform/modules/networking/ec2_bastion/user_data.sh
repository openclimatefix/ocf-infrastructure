#!/bin/bash
# This code gets run on the ec2 machine once it starts up

# make empty file
FILE=/home/ec2-user/.ssh/authorized_keys
if [ -f "$FILE" ]; then
  echo "$FILE exists"
else:
  touch $FILE
end

# add users public keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDG81UYCveCjecpem2ayi4z1LXBD8FWcBKldFodzJGv6YS290Y+FQy88SVjYp/Z+jm2s9AxuO62rFqSvu8flIbZnBAqWpQZj8QPRoP/GwFmV1KU33kVphs527Iev/PTEtCizkCiX8GJqTJtcH3Tv6ntYxI7vGE3s6IP0+VdyHVpwvMm+xT0j8oFFYs7JZvZOzNjPDGRUvKYH68m+hQkFfZatO2dCYB27eEacuo0MysdNLGTGwR0xB50d+AVp4sph34/OU1u76m7HUM1yu3BV70lMJY3AOMDG/uJgwj67xmp7F/g3zI6RRCEhbTe8GZ4oMamRq8mvSGkY3kh4K9qyzWX PD_2021_11_24" >> ./authorized_keys
echo "ssh-rsa fff jacob" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-rsa fff jack" >> /home/ec2-user/.ssh/authorized_keys
