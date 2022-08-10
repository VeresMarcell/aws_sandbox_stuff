      #!/bin/bash
      yum update -y
      yum install httpd -y
      service httpd start
      cd /var/www/html
      echo "<html><body><h1> I am a TF provisioned Instance and my IP is" > index.html
      curl http://169.254.169.254/latest/meta-data/public-ipv4 >> index.html
      echo " I am in " >> index.html
      curl http://169.254.169.254/latest/meta-data/placement/availability-zone >> index.html
      echo "</h1></body></html>" >> index.html
