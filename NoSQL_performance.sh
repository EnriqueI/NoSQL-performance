#!/bin/bash
# save as query_var_path.sh
# This script query variants and their related pathways

echo "This script query variants and their related pathways"
echo "We are using five different database models"
echo "MySQL, MongoDB, Cassandra, Neo4j, Redis and Python-shelve"



###########################
#                         #
#          MySQL          #
#                         #
###########################

# Start
echo "Starting with MySQL"

# Creating a Database - we can use -b (bash mode) instead of -e(sql fashion)
echo "Creating a Database named genomicdbS"
mysql -uroot -p -e 'CREATE DATABASE genomicdbS'

# mysql -uroot -p -e 'USE genomicdbS'

# Uploading headers of file variants
# file: px_annotation.tab.txt
echo "Uploading headers"
mysql -uroot -p genomicdbS -e 'CREATE TABLE px_annotation
(Chromosome INT,
Region INT,
Type VARCHAR(30),
Reference VARCHAR(30),
Allele VARCHAR(30),
Reference_allele VARCHAR(30),
Length INT,
Linkage VARCHAR(30),
Zygosity VARCHAR(30),
Count INT,
Coverage INT,
Frequency INT,
Probability INT,
Forward_read_count INT,
Reverse_read_count INT,
Forward_reverse_balance INT,
Average_quality INT,
Known_variation VARCHAR(30),
Variant_validated_other_experiment VARCHAR(30),
Coding_region_change VARCHAR(30),
Aminoacid_change VARCHAR(30),
Aminoacid_change_longest_transcript VARCHAR(30),
Coding_region_change_longest_transcript VARCHAR(30),
Other_variants_within_codon VARCHAR(30),
Non_synonymous VARCHAR(30))'


echo "Uploading files"

# file: clinvar.tab.txt

mysql -uroot -p genomicdbS -e 'CREATE TABLE clinvar
(#AlleleID INT	
Type VARCHAR(30),
Name VARCHAR(30),
GeneID INT,
GeneSymbol VARCHAR(30),
ClinicalSignificance VARCHAR(30),
RS_dbSNP INT,
nsv_dbVar INT,
Rcvaccession VARCHAR(30),
TestedInGTR VARCHAR(30),
PhenotypeIDs VARCHAR(30),
Origin VARCHAR(30),
Assembly VARCHAR(30),
Chromosome INT,
Start INT,
Stop INT,
Cytogenetic VARCHAR(30),
ReviewStatus VARCHAR(30),
HGVS_c VARCHAR(30),
HGVS_p VARCHAR(30),
NumberSubmitters INT,
LastEvaluated VARCHAR(30),
Guidelines VARCHAR(30),
OtherIDs VARCHAR(30))'


# file: dbsnp_ad.tab.txt

mysql -uroot -p genomicdbS -e 'CREATE TABLE dbsnp_ad
(SNP VARCHAR(30),
Sequence VARCHAR(30),
Chromosome INT,
Region INT,
Gene INT,
Functional_Consequence VARCHAR(30),
Reference VARCHAR(30), Allele VARCHAR(30),
Clinical_Significance VARCHAR(30),
MAF VARCHAR(30),
HGVS VARCHAR(30))'


# file: ucsc_ad.tab.txt

mysql -uroot -p genomicdbS -e 'CREATE TABLE ucsc_ad
(gene VARCHAR(30),
isoform VARCHAR(30),
region VARCHAR(30))'


# file: tcga_rna.tab.txt

mysql -uroot -p genomicdbS -e 'CREATE TABLE tcga_rna
(name VARCHAR(30),
value VARCHAR(30),
keggEntrez VARCHAR(30))'


# file: cpdb.tab.txt

time mysql -uroot -p genomicdbS -e 'CREATE TABLE cpdb
(pathway_source VARCHAR(90),
entrez_gene_ids VARCHAR(90))'


# file: tcga_rna_normalizedcount.tab.txt

mysql -uroot -p genomicdbS -e 'CREATE TABLE tcga_rna_normalizedcount
(gene_id VARCHAR(90),
normalized_count INT)'


# file: tcga_rna_transcriptid.tab.txt

mysql -uroot -p genomicdbS -e 'CREATE TABLE tcga_rna_transcriptid
(gene_id VARCHAR(90),
raw_count INT,
scaled_estimate INT,
transcript_id VARCHAR(90))'


# file: tcga_rna_isoform.tab.txt

mysql -uroot -p genomicdbS -e 'CREATE TABLE tcga_rna_isoform
(isoform_id VARCHAR(90),
normalized_count INT)'


#  Uploading data



echo "Uploading data content"
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS px_annotation.tab.txt
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS clinvar.tab.txt
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS dbsnp_ad.tab.txt
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS ucsc_ad.tab.txt
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS tcga_rna.tab.txt
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS cpdb.tab.txt
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS tcga_rna_normalizedcount.tab.txt
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS tcga_rna_transcriptid.tab.txt
mysqlimport --local -d --ignore-lines=0 -uroot -p genomicdbS tcga_rna_isoform.tab.txt


# Query - Most Likely variant interpretation of a Dz

START_TIME=$SECONDS

echo "Querying most likely variant interpretation for Disease"
mysql -uroot -p genomicdbS -e 'SELECT
dbsnp_ad.SNP,
px_annotation.Allele,
cpdb.pathway_source
FROM
px_annotation,
dbsnp_ad,
clinvar,
tcga_rna_transcriptid,
tcga_rna_isoform,
tcga_rna,
cpdb
WHERE
px_annotation.Region = dbsnp_ad.Region AND
dbsnp_ad.SNP = clinvar.RS_dbSNP AND
clinvar.GeneID = tcga_rna_transcriptid.gene_id AND
tcga_rna_transcriptid.transcript_id = tcga_rna_isoform.isoform_id AND
tcga_rna.keggEntrez = cpdb.entrez_gene_ids
ORDER BY normalized_count
'

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
echo "Time regarding just the query"

# Dropping genomicdbS
echo "Dropping genomicdbS"
mysql -uroot -p -e 'DROP DATABASE genomicdbS'

echo "Done from MySQL"

# END

###########################
#                         #
#         MongoDB         #
#                         #
###########################

# START

echo "Starting with MongoDB"

# Mongo must be running in the background using: ./mongod
# Opening MongoDB

mongo

// SMALL DATABASE pulling all data in one collection
// Creating a new DB named "genomicdbMongo"
// Create a new DB
use genomicdbMongo

// Create new Collections (TABLES)
i = { name : "px_annot_and_DBs" }
db.px_annot_and_DBs.insert( i )

// Closing Mongodb
exit

# Using terminal to upload MongoDB

echo "Uploading JSON files in MongoDB" 

# Uploading JSON files in MongoDB:
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/clinvar.json
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/cpdb.json
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/dbsnp_ad.json
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/px_annotation.json
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/ucsc_ad.json
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/tcga_rna.json
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/tcga_rna_isoform.json
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/tcga_rna_normalizedcount.json
mongoimport -host 127.0.0.1:27017 -collection px_annot_and_DBs --db genomicdbMongo --file //Users/EIVV/Documents/Enrique_I/DB_project/MongoDB_031514/Short_DBm/tcga_rna_transcriptid.json

# Opening MongoDB
mongo

// using the created DB
use genomicdbMongo

// Insert a data manually
db.px_annot_and_DBs.insert ({ "pathway":"Prion diseases - Homo sapiens (human)", "source":"KEGG", "entrez_gene_ids":"hsa04060+7293" })

// Here I changed Region for region (in order to differentiate from Region of Px_annotation file)
db.px_annot_and_DBs.insert ({ "SNP":"rs17767244", "Sequence":"AGCTGTGTTAGAGCAGGAACCCATT[A/G]TCCTGCCAGCATGGGACCCCATGGG", "Chromosome":17, "region":770071, "Gene":"BLMH", "Functional_Consequence":"missense", "Reference":"G", "Allele":"A", "Clinical_Significance VARCHAR":"non-pathogenic", "MAF":"C=0.2736/596", "HGVS":"NC_000017.10:g.28576076T>C,NG_011440.1:g.47999A>G,NM_000386.3:c.1327A>G,NP_000377.1:p.Ile443Val,NT_010799.15:g.3313070T>C" })

// Closing MongoDB
exit

# Querying “Most accurate interpretation”
echo "Querying"
START_TIME=$SECONDS

# Opening MongoDB
mongo

// using the created DB
use genomicdbMongo

// Querying in MongoDB
db.px_annot_and_DBs.find( { $where: "this.Region == this.region" || "this.SNP == this.RS_dbSNP" ||  "this.GeneID == this.gene_id" || "this.transcript_id == this.isoform_id" || "this.keggEntrez == this.entrez_gene_ids" }, {SNP: 1, Allele: 1, pathway: 1, _id: 0} )

// Closing MongoDB
exit

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
echo "Time regarding just the query"

# Dropping genomicdbM
db.px_annot_and_DBs.find.drop()
echo "Dropping genomicdbM"

echo "Done from MongoDB"

# END

###########################
#                         #
#          Neo4j          #
#                         #
###########################

# START

echo "Starting with Neo4j"

# Neo4j must be running in the background using: neo4j console     neo4j start
# Opening Neo4J
neo4j-shell

// Creating nodes with databases’s names
CREATE (n:px_annotation { px_id: '0001', px_annotation_id: '0001' });
CREATE (n:dbsnp_ad { dbsnp_date: '04302014' });
CREATE (n:clinvar { clinvar_date: '04302014' });
CREATE (n:cpdb { cpdb_date: '04302014' });
CREATE (n:tcga_rna_transcriptid { tcga_rna_transcriptid_date: '04302014' });
CREATE (n:tcga_rna_isoform { tcga_rna_isoform_date: '04302014' });
CREATE (n:tcga_rna { tcga_rna_date: '04302014' });

// Creating relationships btw databases and data
CREATE (px_annotation)-[:DB_LOCATION]->(px_annotation_Snp);
CREATE (px_annotation_Snp)-[:LOCATION_LOCATION]->(px_annotation_Region);
CREATE (px_annotation_Region)-[:LOCATION_LOCATION]->(px_annotation_Allele);
CREATE (px_annotation_Allele)-[:LOCATION_DB]->(dbsnp_ad);
CREATE (dbsnp_ad)-[:DB_LOCATION]->(dbsnp_ad_Snp);
CREATE (dbsnp_ad_Snp)-[:LOCATION_LOCATION]->(dbsnp_ad_Region);
CREATE (dbsnp_ad_Region)-[:LOCATION_DB]->(dbsnp_ad);
CREATE (clinvar)-[:DB_LOCATION]->(clinvar_RS_dbSNP);
CREATE (clinvar_RS_dbSNP)-[:LOCATION_LOCATION]->(clinvar_GeneID );
CREATE (clinvar_GeneID )-[:LOCATION_DB]->(clinvar);
CREATE (cpdb)-[:DB_LOCATION]->(cpdb_entrez_gene_ids);
CREATE (cpdb_entrez_gene_ids)-[:LOCATION_FUNCTION]->(cpdb_pathway_source);
CREATE (cpdb_pathway_source)-[:FUNCTION_DB]->(cpdb);
CREATE (tcga_rna_transcriptid)-[:DB_LOCATION]->(tcga_rna_transcriptid_gene_id);
CREATE (tcga_rna_transcriptid_gene_id)-[:LOCATION_LOCATION]->(tcga_rna_transcriptid_transcript_id);
CREATE (tcga_rna_transcriptid_transcript_id)-[:LOCATION_DB]->(tcga_rna_transcriptid);
CREATE (tcga_rna_isoform)-[:DB_LOCATION]->(Tcga_rna_isoform_id);
CREATE (tcga_rna_isoform_id)-[:LOCATION_STATISTICS]->(tcga_rna_isoform_normalized_count);
CREATE (tcga_rna_isoform_normalized_count)-[:STATISTICS_DB]->(tcga_rna_isoform);
CREATE (tcga_rna)-[:DB_LOCATION]->(tcga_rna_isoform_id);
CREATE (tcga_rna_isoform_id )-[:LOCATION_LOCATION]->(tcga_rna_keggEntrez);
CREATE (tcga_rna_keggEntrez)-[:LOCATION_DB]->(tcga_rna);

// Creating relationships btw databases
CREATE (px_annotation)-[:DB_DB]->(dbsnp_ad);
CREATE (px_annotation)-[:DB_DB]->(clinvar);
CREATE (px_annotation)-[:DB_DB]->(cpdb);
CREATE (px_annotation)-[:DB_DB]->(tcga_rna_transcriptid);
CREATE (px_annotation)-[:DB_DB]->(tcga_rna_isoform);
CREATE (px_annotation)-[:DB_DB]->(tcga_rna );

// Closing Neo4j
neo4j stop

# Querying “Most accurate interpretation”
echo "Querying"
START_TIME=$SECONDS

# Opening Neo4j
neo4j-shell

// Querying with Neo4j
echo "Querying with Neo4j"

MATCH (Px_annotation_Snp:px_annotation_Snp), (Px_annotation_region:px_annotation_Region), (Px_annotation_Allele:px_annotation_Allele ), (Dbsnp_ad_Snp:dbsnp_ad_Snp ), (Dbsnp_ad_Region:dbsnp_ad_Region ), (Clinvar_RS_dbSNP:clinvar_RS_dbSNP ), (Clinvar_GeneID:clinvar_GeneID ), (Cpdb_entrez_gene_ids:cpdb_entrez_gene_ids ), (Cpdb_pathway_source:cpdb_pathway_source ), (Tcga_rna_transcriptid_gene_id:tcga_rna_transcriptid_gene_id ), (Tcga_rna_isoform_isoform_id:tcga_rna_isoform_isoform_id), (Tcga_rna_isoform_normalized_count:tcga_rna_isoform_normalized_count), (Tcga_rna_isoform_id:tcga_rna_isoform_id), (Tcga_rna_keggEntrez:tcga_rna_keggEntrez)
RETURN Px_annotation_Snp AS `SNP Affected`, Px_annotation_Allele AS `Allele Affected`, Cpdb_pathway_source AS `Pathway Affected`;

// Closing Neo4j
neo4j stop

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
echo "Time regarding just the query"

echo "Done with Neo4j"

# END


###########################
#                         #
#        Cassandra        #
#                         #
###########################


#START
echo "Starting with Cassandra"

# Starting Cassandra
# Opening Cassandra - Cassandra must be running in the background using: cassandra -f

# Starting CQLSH
cqlsh


// Creating a keyspace -- a namespace of tables.
CREATE KEYSPACE genomicdbcass
WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

// Authenticating the new keyspace:
USE genomicdbcass;

//Creating a user’s table.
CREATE TABLE allinfoinone (
user_id int PRIMARY KEY,
pxannotation_snp text,
pxannotation_Region text,
pxannotation_Allele text,
dbsnp_SNP text,
dbsnp_Region text,
clinvar_RS_dbSNP text,
clinvar_Gene_ID text,
cpdb_entrez_gene_ids text,
cpdb_pathway_source text,
tcgatranscriptid_gene_id text,
tcgatranscriptid_transcript_id text,
tcgaisoform_isoform_id text,
tcgaisoform_normalized_count text,
tcgarna_isoform_id text,
tcgarna_keggEntrez text
);

// Inserting values
INSERT INTO allinfoinone (user_id, pxannotation_snp, pxannotation_Region, pxannotation_Allele, dbsnp_SNP, dbsnp_Region, clinvar_RS_dbSNP, clinvar_Gene_ID, cpdb_entrez_gene_ids, cpdb_pathway_source, tcgatranscriptid_gene_id, tcgatranscriptid_transcript_id, tcgaisoform_isoform_id, tcgaisoform_normalized_count, tcgarna_isoform_id, tcgarna_keggEntrez)
  VALUES (0001, '11111', '770071', 'A', '11111', '770071', '11111', '7508', 'hsa04060+7293', 'Prion diseases - Homo sapiens (human)', '7580', 'uc010nib.1', 'uc010nib.1', '1124', 'uc010nib.1', 'hsa04060+7293');

INSERT INTO allinfoinone (user_id, pxannotation_snp, pxannotation_Region, pxannotation_Allele, dbsnp_SNP, dbsnp_Region, clinvar_RS_dbSNP, clinvar_Gene_ID, cpdb_entrez_gene_ids, cpdb_pathway_source, tcgatranscriptid_gene_id, tcgatranscriptid_transcript_id, tcgaisoform_isoform_id, tcgaisoform_normalized_count, tcgarna_isoform_id, tcgarna_keggEntrez)
  VALUES (0002, '11112', '770072', 'T', '11112', '770072', '11112', '7509', 'hsa04060+7293', 'Metabolic diseases - Homo sapiens (human)', '7582', 'uc010nib.2', 'uc010nib.2', '1123', 'uc010nib.2', 'hsa04060+7294');

INSERT INTO allinfoinone (user_id, pxannotation_snp, pxannotation_Region, pxannotation_Allele, dbsnp_SNP, dbsnp_Region, clinvar_RS_dbSNP, clinvar_Gene_ID, cpdb_entrez_gene_ids, cpdb_pathway_source, tcgatranscriptid_gene_id, tcgatranscriptid_transcript_id, tcgaisoform_isoform_id, tcgaisoform_normalized_count, tcgarna_isoform_id, tcgarna_keggEntrez)
  VALUES (0003, '11113', '770073', 'G', '11113', '770073', '11113', '7501', 'hsa04060+7294', 'Neurologic diseases - Homo sapiens (human)', '7583', 'uc010nib.3', 'uc010nib.3', '1124', 'uc010nib.3', 'hsa04060+7295');

// Closing Cassandra
EXIT

# Querying “Most accurate interpretation”
echo "Querying"
START_TIME=$SECONDS

# Starting CQLSH
cqlsh

// Start Query
SELECT pxannotation_snp, pxannotation_Allele, cpdb_pathway_source FROM allinfoinone;

// Closing Cassandra
EXIT
launchctl unload /usr/local/Cellar/cassandra/2.0.7/homebrew.mxcl.cassandra.plist

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
echo "Time regarding just the query"

echo "Done with Cassandra"

# END


###########################
#                         #
#          Redis          #
#                         #
###########################


#START

echo "Starting with Redis"

# Opening Redis - It must be running in the background using redis-server /usr/local/etc/redis.conf
redis-cli

echo 'Creating a hash table as genomicdbredis'
hset genomicdbredis:px_annotation snp "11111"
hset genomicdbredis:px_annotation Region "770071"
hset genomicdbredis:px_annotation Allele "A"
hset genomicdbredis:bsnp_ad SNP "11111"
hset genomicdbredis:bsnp_ad Region "770071"
hset genomicdbredis:clinvar RS_dbSNP "11111"
hset genomicdbredis:clinvar Gene_ID "7508"
hset genomicdbredis:cpdb gene_ids "hsa04060+7293"
hset genomicdbredis:cpdb pathway_source "Prion diseases - Homo sapiens (human)"
hset genomicdbredis:tcga_rna_transcriptid gene_id "7508"
hset genomicdbredis:tcga_rna_transcriptid transcript_id "uc010nib.1"
hset genomicdbredis:tcga_rna_isoform isoform_id "uc010nib.1"
hset genomicdbredis:tcga_rna_isoform normalized_count: "1124"
hset genomicdbredis:tcga_rna isoform_id: "uc010nib.1"
hset genomicdbredis:tcga_rna keggEntrez: "hsa04060+7293"

echo 'Closing Redis'
EXIT

# Querying “Most accurate interpretation”
echo "Querying"
START_TIME=$SECONDS

# Opening Redis
redis-cli

echo 'Querying the created hash table'
hget genomicdbredis:px_annotation snp
hget genomicdbredis:px_annotation Allele
hget genomicdbredis:cpdb pathway_source

echo 'Closing Redis'
launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.redis.plist

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
echo "Time regarding just the query"

echo "Done with Redis"



# END


###########################
#                         #
#         Python          #
#                         #
###########################

# START

echo "Starting with Python"

# Opening Python
python


import shelve

genomicdbpy = shelve.open('genomicdbpy.db')

try:
    genomicdbpy['px_annotation'] = {'id': '5324df5bbe43d0609a61e080', 'px_annotation_SNP': 11111, 'px_annotation_Region': 770071, 'px_annotation_Allele': 'A'}
    genomicdbpy['dbsnp_ad'] = {'id': '5324df5bbe43d0609a61e084','clinvar_RS_dbSNP': 11111, 'clinvar_GeneID': 7508} 
    genomicdbpy['clinvar'] = {'id': '5324df5bbe43d0609a61e084','clinvar_RS_dbSNP': 11111, 'clinvar_GeneID': 7508}
    genomicdbpy['cpdb'] = {'id': '5324df5bbe43d0609a61e086', 'cpdb_entrez_gene_ids': 'hsa04060+7293', 'cpdb_pathway_source': 'Prion diseases - Homo sapiens (human)'}
    genomicdbpy['tcga_rna_transcriptid'] = {'id': '5324df5bbe43d0609a61e088', 'tcga_rna_transcriptid_gene_id': 7508, 'tcga_rna_transcriptid_transcript_id': 'uc010nib.1'}
    genomicdbpy['tcga_rna_isoform'] = {'id': '5324df5bbe43d0609a61e090', 'tcga_rna_isoform_isoform_id': 'uc010nib.1', 'tcga_rna_isoform_normalized_count': 1124}
    genomicdbpy['tcga_rna'] = {'id': '5324df5bbe43d0609a61e092', 'tcga_rna_isoform_id': 'uc010nib.1', 'tcga_rna_keggEntrez': 'hsa04060+7293'}
finally:
    genomicdbpy.close()



#To access the data again, open the shelf and use it like a dictionary:

import shelve

genomicdbpy = shelve.open('genomicdbpy.db')

try:
  existing = genomicdbpy['px_annotation'], genomicdbpy['dbsnp_ad'], genomicdbpy['clinvar'], genomicdbpy['cpdb'], genomicdbpy['tcga_rna_transcriptid'], genomicdbpy['tcga_rna_isoform'], genomicdbpy['tcga_rna'] 

finally:
       genomicdbpy.close()

print(existing)


# Closing Python
exit


# Starting query
# Querying “Most accurate interpretation”
echo "Querying"
START_TIME=$SECONDS


# Opening Python


# Query


# Closing Python
exit

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
echo "Time regarding just the query"


echo "Done for DBproject"




