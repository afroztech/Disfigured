#!/bin/bash

set -v

ln -s /mnt/ebs /DISFIGURED
ln -s /DISFIGURED/csv/* ~/disfigured

echo "
create keyspace stupormail with replication = {'class':'SimpleStrategy', 'replication_factor':1 };

create table stupormail.email (user text, mailbox text, message_id text, msgdate timestamp,
 subject text, tolist set<text>, fromlist set<text>, cclist set<text>, bcclist set<text>,
 body text, is_read boolean,
 primary key (user, mailbox, msgdate, message_id) )
 with clustering order by (mailbox asc, msgdate desc) ;

create table stupormail.attachments (user text, mailbox text, msgdate timestamp,
 message_id text, filename text, content_type text, bytes blob,
 primary key (user, mailbox, msgdate, message_id, filename));
" | cqlsh node0


ln /DISFIGURED/SSTables/stupormail/email/* /mnt/ephemeral/cassandra/data/stupormail/email*
ln /DISFIGURED/SSTables/stupormail/attachments/* /mnt/ephemeral/cassandra/data/stupormail/attachments*

chown -R cassandra:cassandra /mnt/ephemeral/cassandra/data

nodetool refresh stupormail email
nodetool refresh stupormail attachments

