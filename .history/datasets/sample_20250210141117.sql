BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"Ownership_Percentage__c" VARCHAR(255), 
	"sims_Insurer_Type__c" VARCHAR(255), 
	"sims_Custom_Address_1__City__s" VARCHAR(255), 
	"sims_Custom_Address_1__CountryCode__s" VARCHAR(255), 
	"sims_Custom_Address_1__PostalCode__s" VARCHAR(255), 
	"sims_Custom_Address_1__StateCode__s" VARCHAR(255), 
	"sims_Custom_Address_1__Street__s" VARCHAR(255), 
	"sims_Custom_Address_2__City__s" VARCHAR(255), 
	"sims_Custom_Address_2__CountryCode__s" VARCHAR(255), 
	"sims_Custom_Address_2__PostalCode__s" VARCHAR(255), 
	"sims_Custom_Address_2__StateCode__s" VARCHAR(255), 
	"sims_Custom_Address_2__Street__s" VARCHAR(255), 
	"sims_Custom_Address_3__City__s" VARCHAR(255), 
	"sims_Custom_Address_3__CountryCode__s" VARCHAR(255), 
	"sims_Custom_Address_3__PostalCode__s" VARCHAR(255), 
	"sims_Custom_Address_3__StateCode__s" VARCHAR(255), 
	"sims_Custom_Address_3__Street__s" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES('Account-1','Sample Account for Entitlements','','','Washington','US','20500','DC','1600 Pennsylvania Ave NW','Los Angeles','US','90037','CA','700 Exposition Park Dr','New York','US','10007','NY','2 World Trade Center','');
INSERT INTO "Account" VALUES('Account-2','Harco','','','New York','US','10118','NY','350 5th Ave','Burbank','US','91521','CA','500 S Buena Vista St','New York','US','10174','NY','405 Lexington Ave','');
INSERT INTO "Account" VALUES('Account-3','Harco Child 1','','Admitted Reinsurer','Cupertino','US','95014','CA','1 Infinite Loop','San Jose','US','95113','CA','11 N 1st St','Universal City','US','91608','CA','100 Universal City Plaza','');
INSERT INTO "Account" VALUES('Account-4','Harco Grandchild 2','','','Mountain View','US','94043','CA','1600 Amphitheatre Parkway','Denver','US','80206','CO','2000 E Colfax Ave','Palo Alto','US','94304','CA','3500 Deer Creek Road','');
INSERT INTO "Account" VALUES('Account-5','Harco Great-Grandchild 1','','Certified','Chicago','US','60606','IL','233 S Wacker Dr','Los Angeles','US','90017','CA','600 W Broadway','Cambridge','US','2139','MA','500 Memorial Drive','');
INSERT INTO "Account" VALUES('Account-6','Sample Account for Entitlements','','','Houston','US','77058','TX','2101 NASA Parkway','Houston','US','77002','TX','1000 N Main St','Redmond','US','98052','WA','1 Microsoft Way','');
INSERT INTO "Account" VALUES('Account-7','Harco Child 2','','','New York','US','10017','NY','89 E 42nd St','Seattle','US','98101','WA','1600 Main St','Jacksonville','US','32202','FL','1601 S Main St','');
INSERT INTO "Account" VALUES('Account-8','Harco Grandchild 1','','','Los Angeles','US','90012','CA','200 N Spring St','San Francisco','US','94109','CA','1515 Polk St','Minneapolis','US','55402','MN','800 Nicollet Mall','');
INSERT INTO "Account" VALUES('Account-9','United Insurance','','','Seattle','US','98109','WA','400 Broad St','Chicago','US','60604','IL','300 S State St','Los Angeles','US','90071','CA','350 S Grand Ave','');
INSERT INTO "Account" VALUES('Account-10','Odyssey Reinsurance Company - CT, US','','Admitted Reinsurer','Miami','US','33133','FL','3500 Pan American Dr','Washington','US','20036','DC','1225 17th St NW','Washington','US','20560','DC','1000 Independence Ave SW','');
INSERT INTO "Account" VALUES('Account-11','Allied World Specialty Insurance Company - DE, US','','','New York','US','10028','NY','1000 5th Ave','New York','US','10168','NY','33 W 42nd St','San Jose','US','95112','CA','2101 N First St','');
INSERT INTO "Account" VALUES('Account-12','Crum & Forster Holdings Corp. - US','','','Chicago','US','60637','IL','5801 S Ellis Ave','Boston','US','2108','MA','1 City Hall Square','San Francisco','US','94105','CA','1 Market St','');
INSERT INTO "Account" VALUES('Account-13','The North River Insurance Company - NJ, US','','','Cambridge','US','2139','MA','77 Massachusetts Ave','San Francisco','US','94158','CA','500 Terry A Francois Blvd','New York','US','10019','NY','1601 Broadway','');
INSERT INTO "Account" VALUES('Account-14','Allied World Insurance Company - NH, US','','','Stanford','US','94305','CA','450 Serra Mall','New York','US','10028','NY','1001 Fifth Ave','New York','US','10017','NY','350 E 45th St','');
INSERT INTO "Account" VALUES('Account-15','Crum and Forster Insurance Company - NJ, US','','Admitted Reinsurer','Chicago','US','60606','IL','100 N Riverside Plaza','Chicago','US','60603','IL','50 W Mason St','Chicago','US','60604','IL','77 W Jackson Blvd','');
INSERT INTO "Account" VALUES('Account-16','B.C. Unlimited Liability Company - Canada','','','Bloomington','US','55425','MN','60 E Broadway','Houston','US','77070','TX','3000 George Bush Hwy','Menlo Park','US','94025','CA','1 Hacker Way','');
INSERT INTO "Account" VALUES('Account-17','Allied World Assurance Company Holdings Ltd.','','Certified','Dearborn','US','48126','MI','1 American Road','Charlotte','US','28202','NC','1 N Tryon St','Washington','US','20001','DC','800 G Street NW','');
INSERT INTO "Account" VALUES('Account-18','Allied World Assurance Company (U.S.) Inc. - DE, US','','','New York','US','10007','NY','285 Fulton St','Minneapolis','US','55403','MN','800 W 6th St','San Jose','US','95131','CA','2211 N First St','');
INSERT INTO "Account" VALUES('Account-19','Allied World Surplus Lines Insurance Company - AR, US','','','Arlington','US','76011','TX','1 AT&T Way','San Diego','US','92101','CA','221 2nd St','San Francisco','US','94111','CA','600 Montgomery St','');
INSERT INTO "Account" VALUES('Account-20','Allied World National Assurance Company - NH, US','','Certified','Chicago','US','60613','IL','1060 W Addison St','Sacramento','US','95814','CA','500 S Capitol Ave','Los Angeles','US','90014','CA','600 E Grand Ave','');
INSERT INTO "Account" VALUES('Account-21','FFHL Group Limited - Canada','','','Washington','US','20566','DC','2700 F St NW','Los Angeles','US','90049','CA','1200 Getty Center Dr','San Francisco','US','94105','CA','300 S Beale St','');
INSERT INTO "Account" VALUES('Account-22','United States Fire Insurance Company - DE, US','','','San Francisco','US','94102','CA','1 Dr Carlton B Goodlett Pl','Los Angeles','US','90013','CA','410 S 4th St','Los Angeles','US','90012','CA','1401 Vine St','');
INSERT INTO "Account" VALUES('Account-23','Crum & Forster Indemnity Company - DE, US','','','Washington','US','20004','DC','First St SE','San Francisco','US','94118','CA','55 Music Concourse Dr','Seattle','US','98101','WA','1200 4th Ave','');
INSERT INTO "Account" VALUES('Account-24','Seneca Insurance Company, Inc. - NY, US','','','Philadelphia','US','19106','PA','800 Chestnut St','San Francisco','US','94109','CA','1101 Van Ness Ave','San Francisco','US','94104','CA','500 California St','');
INSERT INTO "Account" VALUES('Account-25','Odyssey US Holdings Inc. - CT, USA','','Admitted Reinsurer','Philadelphia','US','19106','PA','526 Market St','Washington','US','20002','DC','200 L St NE','San Francisco','US','94105','CA','1 S Main St','');
INSERT INTO "Account" VALUES('Account-26','Hudson Insurance Company - DE, US','','','Los Angeles','US','90012','CA','111 S Grand Ave','Washington','US','20005','DC','1400 New York Ave NW','Pasadena','US','91101','CA','350 E Colorado Blvd','');
CREATE TABLE "Ownership__c" (
	id VARCHAR(255) NOT NULL, 
	"Ownership_Percentage__c" VARCHAR(255), 
	"Type__c" VARCHAR(255), 
	"Parent__c" VARCHAR(255), 
	"Subsidiary__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Ownership__c" VALUES('Ownership__c-1','50.0','','Account-2','Account-3');
INSERT INTO "Ownership__c" VALUES('Ownership__c-2','100.0','','Account-2','Account-7');
INSERT INTO "Ownership__c" VALUES('Ownership__c-3','100.0','','Account-12','Account-22');
INSERT INTO "Ownership__c" VALUES('Ownership__c-4','100.0','','Account-13','Account-24');
INSERT INTO "Ownership__c" VALUES('Ownership__c-5','100.0','','Account-14','Account-11');
INSERT INTO "Ownership__c" VALUES('Ownership__c-6','100.0','','Account-14','Account-18');
INSERT INTO "Ownership__c" VALUES('Ownership__c-7','100.0','','Account-16','Account-14');
INSERT INTO "Ownership__c" VALUES('Ownership__c-8','100.0','','Account-16','Account-20');
INSERT INTO "Ownership__c" VALUES('Ownership__c-9','100.0','','Account-17','Account-16');
INSERT INTO "Ownership__c" VALUES('Ownership__c-10','100.0','','Account-17','Account-21');
INSERT INTO "Ownership__c" VALUES('Ownership__c-11','100.0','','Account-3','Account-8');
INSERT INTO "Ownership__c" VALUES('Ownership__c-12','100.0','','Account-21','Account-12');
INSERT INTO "Ownership__c" VALUES('Ownership__c-13','100.0','','Account-21','Account-25');
INSERT INTO "Ownership__c" VALUES('Ownership__c-14','100.0','','Account-22','Account-13');
INSERT INTO "Ownership__c" VALUES('Ownership__c-15','100.0','','Account-22','Account-15');
INSERT INTO "Ownership__c" VALUES('Ownership__c-16','100.0','','Account-22','Account-23');
INSERT INTO "Ownership__c" VALUES('Ownership__c-17','100.0','','Account-25','Account-10');
INSERT INTO "Ownership__c" VALUES('Ownership__c-18','100.0','','Account-7','Account-4');
INSERT INTO "Ownership__c" VALUES('Ownership__c-19','50.0','','Account-9','Account-3');
INSERT INTO "Ownership__c" VALUES('Ownership__c-20','100.0','','Account-10','Account-26');
CREATE TABLE "sims_Account_Address__c" (
	id VARCHAR(255) NOT NULL, 
	"sims_Address__City__s" VARCHAR(255), 
	"sims_Address__CountryCode__s" VARCHAR(255), 
	"sims_Address__PostalCode__s" VARCHAR(255), 
	"sims_Address__StateCode__s" VARCHAR(255), 
	"sims_Address__Street__s" VARCHAR(255), 
	"sims_Account__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-1','New York','US','10001','NY','100 Broadway','Account-1');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-2','New York','US','10018','NY','200 5th Ave','Account-1');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-3','Los Angeles','US','90001','CA','123 Sunset Blvd','Account-2');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-4','Los Angeles','US','90015','CA','456 Hollywood Blvd','Account-2');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-5','Los Angeles','US','90025','CA','789 Vine St','Account-2');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-6','Chicago','US','60601','IL','101 Michigan Ave','Account-3');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-7','Chicago','US','60605','IL','202 Wacker Drive','Account-3');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-8','Houston','US','77001','TX','300 Main St','Account-4');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-9','Houston','US','77002','TX','400 Milam St','Account-4');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-10','Houston','US','77003','TX','500 Fannin St','Account-4');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-11','Phoenix','US','85001','AZ','111 Central Ave','Account-5');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-12','Phoenix','US','85004','AZ','222 Grand Ave','Account-5');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-13','Philadelphia','US','19101','PA','10 Market St','Account-6');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-14','Philadelphia','US','19102','PA','20 Chestnut St','Account-6');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-15','Philadelphia','US','19103','PA','30 Walnut St','Account-6');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-16','San Antonio','US','78201','TX','400 Alamo Plaza','Account-7');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-17','San Antonio','US','78205','TX','500 River Walk','Account-7');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-18','San Diego','US','92101','CA','123 Harbor Dr','Account-8');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-19','San Diego','US','92103','CA','234 Pacific Hwy','Account-8');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-20','San Diego','US','92104','CA','345 Mission Bay Blvd','Account-8');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-21','Dallas','US','75201','TX','600 Elm St','Account-9');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-22','Dallas','US','75204','TX','700 Commerce St','Account-9');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-23','San Jose','US','95101','CA','800 Blossom Hill Rd','Account-10');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-24','San Jose','US','95112','CA','900 Almaden Expy','Account-10');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-25','San Jose','US','95116','CA','1000 Santa Clara St','Account-10');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-26','Austin','US','78701','TX','111 Congress Ave','Account-11');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-27','Austin','US','78702','TX','222 6th St','Account-11');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-28','Jacksonville','US','32202','FL','333 Riverfront Dr','Account-12');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-29','Jacksonville','US','32204','FL','444 Atlantic Blvd','Account-12');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-30','Jacksonville','US','32207','FL','555 Ocean Ave','Account-12');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-31','Fort Worth','US','76101','TX','600 Sundance Square','Account-13');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-32','Fort Worth','US','76107','TX','700 West 7th St','Account-13');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-33','Columbus','US','43085','OH','123 High St','Account-14');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-34','Columbus','US','43215','OH','234 Nationwide Blvd','Account-14');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-35','Columbus','US','43219','OH','345 S Third St','Account-14');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-36','San Francisco','US','94102','CA','100 Market St','Account-15');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-37','San Francisco','US','94103','CA','200 Mission St','Account-15');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-38','Charlotte','US','28201','NC','150 Trade St','Account-16');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-39','Charlotte','US','28202','NC','250 Tryon St','Account-16');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-40','Charlotte','US','28203','NC','350 Central Ave','Account-16');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-41','Indianapolis','US','46201','IN','400 Meridian St','Account-17');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-42','Indianapolis','US','46204','IN','500 Market St','Account-17');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-43','Seattle','US','98101','WA','600 Pike St','Account-18');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-44','Seattle','US','98109','WA','700 1st Ave','Account-18');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-45','Seattle','US','98115','WA','800 Stewart St','Account-18');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-46','Denver','US','80201','CO','900 Colfax Ave','Account-19');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-47','Denver','US','80202','CO','1000 Larimer St','Account-19');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-48','Washington','US','20001','DC','1100 Pennsylvania Ave','Account-20');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-49','Washington','US','20002','DC','1200 14th St NW','Account-20');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-50','Washington','US','20003','DC','1300 Constitution Ave NW','Account-20');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-51','Boston','US','2108','MA','1400 Beacon St','Account-21');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-52','Boston','US','2110','MA','1500 Boylston St','Account-21');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-53','El Paso','US','79901','TX','1600 Mesa St','Account-22');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-54','El Paso','US','79902','TX','1700 Paisano Blvd','Account-22');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-55','El Paso','US','79903','TX','1800 Sun Bowl Dr','Account-22');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-56','Nashville','US','37201','TN','1900 Broadway','Account-23');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-57','Nashville','US','37203','TN','2000 Music Row','Account-23');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-58','Detroit','US','48201','MI','2100 Woodward Ave','Account-24');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-59','Detroit','US','48226','MI','2200 Michigan Ave','Account-24');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-60','Detroit','US','48227','MI','2300 Gratiot Ave','Account-24');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-61','Oklahoma City','US','73101','OK','2400 N Robinson Ave','Account-25');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-62','Oklahoma City','US','73120','OK','2500 S Hudson Ave','Account-25');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-63','Portland','US','97201','OR','2600 SW 5th Ave','Account-26');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-64','Portland','US','97205','OR','2700 NE Broadway','Account-26');
INSERT INTO "sims_Account_Address__c" VALUES('sims_Account_Address__c-65','Portland','US','97209','OR','2800 SE Division St','Account-26');
COMMIT;
