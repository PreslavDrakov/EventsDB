DROP TRIGGER IF EXISTS ticket_quantity_set;
DELIMITER |
CREATE TRIGGER ticket_quantity_set BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN 
	DECLARE location_capacity INT;
	SELECT location.capacity INTO location_capacity
	FROM event_info JOIN location 
    ON event_info.location_id = location.id
	WHERE event_info.id = NEW.event_id;
    IF NEW.type_id=1
		THEN SET NEW.quantity=location_capacity*0.7;
	ELSEIF NEW.type_id=2
		THEN SET NEW.quantity=location_capacity*0.2;
	ELSEIF NEW.type_id=3
		THEN SET NEW.quantity=location_capacity*0.1;
	ELSE
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Възникна проблем при определянето на броя билети!";
	END IF;
END;
|
DELIMITER ;

DROP TRIGGER IF EXISTS increment_sold_tickets;
DELIMITER |
CREATE TRIGGER increment_sold_tickets AFTER INSERT ON event_participant
FOR EACH ROW
BEGIN
	DECLARE participant_ticket ENUM("VIP","Delux","Standard");
    DECLARE participant_ticket_id INT;
    DECLARE participant_event_id INT;
    DECLARE ticket_quantity INT;
    DECLARE ticket_sold INT;
    SELECT NEW.event_id,NEW.ticket_type INTO participant_event_id,participant_ticket;
    IF participant_ticket="Standard"
		THEN SET participant_ticket_id=1;
	ELSEIF participant_ticket="VIP"
		THEN SET participant_ticket_id=2;
	ELSEIF participant_ticket="Delux"
		THEN SET participant_ticket_id=3;
	END IF;
    SELECT t.quantity, t.sold_tickets INTO ticket_quantity, ticket_sold
    FROM ticket AS t
    WHERE t.event_id=participant_event_id AND t.type_id=participant_ticket_id;
    IF (ticket_sold+1)<=ticket_quantity
		THEN UPDATE ticket AS t
			 SET sold_tickets = sold_tickets+1
             WHERE t.event_id=participant_event_id AND t.type_id = participant_ticket_id;
	ELSE
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Няма повече налични билети от този тип за това събитие!";
	END IF;
END;
|
DELIMITER ;

DROP TRIGGER IF EXISTS archive_event;
DELIMITER |
CREATE TRIGGER archive_event AFTER DELETE ON event_info
FOR EACH ROW
BEGIN
	IF NOT EXISTS (
			SELECT event_name, event_date FROM event_archive WHERE event_name = OLD.name AND event_date = OLD.time_date
		) THEN
			INSERT IGNORE event_archive (event_name, event_date, event_location, event_address, occasion, durration, expenses, profit, archive_date)
			SELECT DISTINCT OLD.name, OLD.time_date, location.name, location.address, OLD.occasion, OLD.durration, OLD.expenses, 0, NOW()
			FROM event_info JOIN location
			ON OLD.location_id=location.id;
	END IF;
END;
|
DELIMITER ;