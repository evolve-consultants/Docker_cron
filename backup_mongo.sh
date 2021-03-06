#Backup of All Mysql databases to a single backup file

#Variables
DATESTAMP=$(date +"%F")
TIMESTAMP=$(date +"%T")
MONGODUMP="/usr/bin/mongodump"
TMP="/backup/mongo/tmp/"
DATABASE_TAR_FILE="DB_MONGO_Backups_$DATESTAMP.tar"
BACKUP_DIR="/backup/mongo/$DATESTAMP"

#Sort out directories
mkdir -p "$BACKUP_DIR/"
rm -rf $TMP/*
echo "Starting backup at $TIMESTAMP"

#LOcal DB Backups####
$MONGODUMP --host $MONGODB_HOST --port $MONGODB_PORT --username $MONGODB_USER --password $MONGODB_PASSWORD --out $BACKUP_DIR

#Local Files backups and tarball DB backup

tar -cvf $TMP/$DATABASE_TAR_FILE $BACKUP_DIR
gzip $TMP/$DATABASE_TAR_FILE

SSHPASS=$SFTP_PASSWORD sshpass -e sftp -oBatchMode=no -oStrictHostKeyChecking=no -oPort=$SFTP_PORT -b - $SFTP_USERNAME@$SFTP_SERVER << !
   cd $SFTP_UPLOAD_DIR
   put $TMP/$DATABASE_TAR_FILE.gz
   bye
!

#Remove Local Backups
rm -rf $BACKUP_DIR