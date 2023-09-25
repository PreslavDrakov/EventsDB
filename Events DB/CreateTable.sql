DROP DATABASE IF EXISTS events_db;
CREATE DATABASE events_db;
USE events_db;
CREATE TABLE location(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    capacity INT NOT NULL);
    
CREATE TABLE event_info(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location_id INT NOT NULL,
    time_date DATETIME NOT NULL,
    occasion ENUM("concert","conference","workshop","charity","team build","trade show","comedy show") NOT NULL,
    durration TIME NOT NULL,
    expenses DECIMAL NOT NULL,
    UNIQUE KEY unique_event_location(time_date,location_id),
    CONSTRAINT fk_event_location FOREIGN KEY (location_id) REFERENCES location(id) ON DELETE RESTRICT ON UPDATE CASCADE);
    
CREATE TABLE sponsor(
	id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
	last_name VARCHAR(255) NOT NULL,
    company VARCHAR(255) DEFAULT NULL);
    
CREATE TABLE event_sponsor(
	event_id INT NOT NULL,
    sponsor_id INT NOT NULL,
    money_given DECIMAL NOT NULL,
    CONSTRAINT fk_es_event FOREIGN KEY (event_id) REFERENCES event_info(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_es_sponsor FOREIGN KEY (sponsor_id) REFERENCES sponsor(id) ON DELETE CASCADE ON UPDATE CASCADE);
    
CREATE TABLE person_info(
	id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL);
    
CREATE TABLE event_creator(
	event_id INT NOT NULL,
    creator_id INT NOT NULL,
    CONSTRAINT fk_ec_event FOREIGN KEY (event_id) REFERENCES event_info(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_ec_creator FOREIGN KEY (creator_id) REFERENCES person_info(id) ON DELETE RESTRICT ON UPDATE CASCADE);
    
CREATE TABLE event_participant(
	event_id INT NOT NULL,
    participant_id INT NOT NULL,
    ticket_type ENUM("VIP","Delux","Standard") NOT NULL,
    UNIQUE KEY unique_event_participant(event_id,participant_id,ticket_type),
    CONSTRAINT fk_ep_event FOREIGN KEY (event_id) REFERENCES event_info(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_ep_participant FOREIGN KEY (participant_id) REFERENCES person_info(id) ON DELETE RESTRICT ON UPDATE CASCADE);
    
CREATE TABLE ticket_type(
	id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM("VIP","Delux","Standard") NOT NULL,
    description TEXT NOT NULL);
    
CREATE TABLE ticket(
	id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    quantity INT DEFAULT 0,
    sold_tickets INT DEFAULT 0,
    price DECIMAL NOT NULL,
    type_id INT NOT NULL,
    UNIQUE KEY unique_ticket_type(event_id,type_id), 
    CONSTRAINT fk_ticket_event FOREIGN KEY (event_id) REFERENCES event_info(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_type FOREIGN KEY (type_id) REFERENCES ticket_type(id) ON DELETE RESTRICT ON UPDATE CASCADE);
    
CREATE TABLE event_archive(
    event_name VARCHAR(255) NOT NULL,
    event_date DATETIME NOT NULL,
    event_location VARCHAR(255) NOT NULL,
    event_address VARCHAR(255) NOT NULL,
    occasion ENUM("concert","conference","workshop","charity","team build","trade show","comedy show") NOT NULL,
    durration TIME NOT NULL ,
    expenses DECIMAL NOT NULL,
    profit DECIMAL NOT NULL DEFAULT 0,
    archive_date DATETIME NOT NULL,
    UNIQUE KEY unique_event_archive(event_name,event_date)); 
    

