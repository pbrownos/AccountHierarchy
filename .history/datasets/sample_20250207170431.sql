BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"Ownership_Percentage__c" VARCHAR(255), 
	"sims_Insurer_Type__c" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES('Account-1','Harco','','','');
INSERT INTO "Account" VALUES('Account-2','Harco Child 1','','Admitted Reinsurer','');
INSERT INTO "Account" VALUES('Account-3','Harco Grandchild 2','','','');
INSERT INTO "Account" VALUES('Account-4','Harco Great-Grandchild 1','','Certified','');
INSERT INTO "Account" VALUES('Account-5','Sample Account for Entitlements','','','');
INSERT INTO "Account" VALUES('Account-6','Harco Child 2','','','');
INSERT INTO "Account" VALUES('Account-7','Harco Grandchild 1','','','');
INSERT INTO "Account" VALUES('Account-8','United Insurance','','','');
INSERT INTO "Account" VALUES('Account-9','Odyssey Reinsurance Company - CT, US','','Admitted Reinsurer','');
INSERT INTO "Account" VALUES('Account-10','Allied World Specialty Insurance Company - DE, US','','','');
INSERT INTO "Account" VALUES('Account-11','Crum & Forster Holdings Corp. - US','','','');
INSERT INTO "Account" VALUES('Account-12','The North River Insurance Company - NJ, US','','','');
INSERT INTO "Account" VALUES('Account-13','Allied World Insurance Company - NH, US','','','');
INSERT INTO "Account" VALUES('Account-14','Crum and Forster Insurance Company - NJ, US','','Admitted Reinsurer','');
INSERT INTO "Account" VALUES('Account-15','B.C. Unlimited Liability Company - Canada','','','');
INSERT INTO "Account" VALUES('Account-16','Allied World Assurance Company Holdings Ltd.','','Certified','');
INSERT INTO "Account" VALUES('Account-17','Allied World Assurance Company (U.S.) Inc. - DE, US','','','');
INSERT INTO "Account" VALUES('Account-18','Allied World Surplus Lines Insurance Company - AR, US','','','');
INSERT INTO "Account" VALUES('Account-19','Allied World National Assurance Company - NH, US','','Certified','');
INSERT INTO "Account" VALUES('Account-20','FFHL Group Limited - Canada','','','');
INSERT INTO "Account" VALUES('Account-21','United States Fire Insurance Company - DE, US','','','');
INSERT INTO "Account" VALUES('Account-22','Crum & Forster Indemnity Company - DE, US','','','');
INSERT INTO "Account" VALUES('Account-23','Seneca Insurance Company, Inc. - NY, US','','','');
INSERT INTO "Account" VALUES('Account-24','Odyssey US Holdings Inc. - CT, USA','','Admitted Reinsurer','');
INSERT INTO "Account" VALUES('Account-25','Hudson Insurance Company - DE, US','','','');
CREATE TABLE "Ownership__c" (
	id VARCHAR(255) NOT NULL, 
	"Ownership_Percentage__c" VARCHAR(255), 
	"Type__c" VARCHAR(255), 
	"Parent__c" VARCHAR(255), 
	"Subsidiary__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Ownership__c" VALUES('Ownership__c-1','50.0','','Account-1','Account-2');
INSERT INTO "Ownership__c" VALUES('Ownership__c-2','100.0','','Account-1','Account-6');
INSERT INTO "Ownership__c" VALUES('Ownership__c-3','100.0','','Account-2','Account-7');
INSERT INTO "Ownership__c" VALUES('Ownership__c-4','50.0','','Account-8','Account-2');
INSERT INTO "Ownership__c" VALUES('Ownership__c-5','100.0','','Account-6','Account-3');
INSERT INTO "Ownership__c" VALUES('Ownership__c-6','100.0','','Account-16','Account-20');
INSERT INTO "Ownership__c" VALUES('Ownership__c-7','100.0','','Account-13','Account-17');
INSERT INTO "Ownership__c" VALUES('Ownership__c-8','100.0','','Account-13','Account-10');
INSERT INTO "Ownership__c" VALUES('Ownership__c-9','100.0','','Account-24','Account-9');
INSERT INTO "Ownership__c" VALUES('Ownership__c-10','','','Account-21','Account-14');
INSERT INTO "Ownership__c" VALUES('Ownership__c-11','100.0','','Account-15','Account-19');
INSERT INTO "Ownership__c" VALUES('Ownership__c-12','100.0','','Account-15','Account-13');
INSERT INTO "Ownership__c" VALUES('Ownership__c-13','100.0','','Account-9','Account-25');
INSERT INTO "Ownership__c" VALUES('Ownership__c-14','100.0','','Account-12','Account-23');
INSERT INTO "Ownership__c" VALUES('Ownership__c-15','100.0','','Account-21','Account-12');
INSERT INTO "Ownership__c" VALUES('Ownership__c-16','100.0','','Account-21','Account-22');
INSERT INTO "Ownership__c" VALUES('Ownership__c-17','100.0','','Account-11','Account-21');
INSERT INTO "Ownership__c" VALUES('Ownership__c-18','100.0','','Account-20','Account-11');
INSERT INTO "Ownership__c" VALUES('Ownership__c-19','100.0','','Account-16','Account-15');
INSERT INTO "Ownership__c" VALUES('Ownership__c-20','100.0','','Account-20','Account-24');
COMMIT;
