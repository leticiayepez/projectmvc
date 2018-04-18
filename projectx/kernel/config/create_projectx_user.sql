drop table IF EXISTS app_user;

Create table user (
	user_id Int NOT NULL AUTO_INCREMENT,
	user_firstname Varchar(100) NOT NULL,
	user_lastname Varchar(100) NOT NULL,
	user_address Varchar(100),
        user_birthdate Date, 
	Index AI_user_id (user_id),
Primary Key (user_id)) TYPE = MyISAM;
