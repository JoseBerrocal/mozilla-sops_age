# Mozilla SOPS and AGE

## Project Overview

Test encryption and decryption of variables to be used by different services in a docker-compose setup using mozilla sops and age


## Prerequisites

* docker
* docker-compose

---

## Procedure

### Cleaning variables and Key
```bash
git clone git@github.com:JoseBerrocal/mozilla-sops_age.git
cd mozilla-sops_age
rm decrypt/keys.txt;
echo "" > .env;
```
___

The first part will involve accessing a Node container, installing the required packages(mozilla sops & age), and proceeding to generate an encrypted variable file(.env)

### Enter the Node container and install Mozilla SOPS and Age
```bash
docker run -v ./decrypt:/decrypt -v ./.env:/root/.env -w /root -ti node:20-alpine /bin/ash
apk add --no-cache curl gnupg age;
curl -Lo /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64;
chmod +x /usr/local/bin/sops;
```


### Generate Keys
```bash
age-keygen -o keys.txt;
mkdir ~/.sops;
cp ./keys.txt ~/.sops;
cp ./keys.txt /decrypt;
chown node:node /decrypt/keys.txt;
echo "export SOPS_AGE_KEY_FILE=$HOME/.sops/keys.txt" > .ashrc;
source .ashrc;
```

### Generate a variable file and encrypt it (you can replace 'password124' with any desired value)
```bash
echo "MYSQL_ROOT_PASSWORD=password124" > .env;
sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE  |grep "public key:" | cut -d ' ' -f4) -i .env;
exit;
```


### Additional commands - Not required for execution
```bash
##ENCRYPT##
sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE  |grep "public key:" | cut -d ' ' -f4) -i .env
##DECRYPT##
sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE  |grep "public key:" | cut -d ' ' -f4) -i .env
```
___

The second part involves starting the services of the docker-compose to decrypt the variable file and then passing this variable to the MySQL service

### Decrypt the variable file
```bash
docker-compose down --volume;
docker volume create sops_age_db;
docker-compose up -d sops;
```

### Start all services
```bash
docker-compose up -d;
```

### Check logs after (MySQL init process done. Ready for start up)
```bash
docker-compose logs mysql;
```
### Connect to database
```bash
mysql -u root -p -h 127.0.0.1 -P 3326
password124
```

### Connect to the database from within the container
```bash
docker exec -ti mysql_svc bash 
mysql -u root -p -h 127.0.0.1
password124
```