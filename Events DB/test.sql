DROP PROCEDURE IF EXISTS discount_ticket;
DELIMITER |
CREATE PROCEDURE discount_ticket()
BEGIN
	DECLARE finished INT;
	DECLARE curEventId INT;
    DECLARE checkForTickets INT;
    DECLARE curEventDate DATETIME;
    DECLARE eventCursor CURSOR FOR SELECT id FROM event_info;
    DECLARE CONTINUE HANDLER FOR NOT FOUND  SET finished=1;
	SET finished=0;
    SET checkForTickets=0;
    
    START TRANSACTION;
    OPEN eventCursor;
    cur_loop:LOOP
		FETCH eventCursor INTO curEventId;
        IF(finished=1)
			THEN LEAVE cur_loop;
		END IF;
        SELECT time_date INTO curEventDate
        FROM event_info
        WHERE event_info.id=curEventId;
        IF(DATE(curEventDate)=DATE(NOW()))
			THEN 
				UPDATE ticket
                SET ticket.price=0.5*ticket.price
                WHERE ticket.event_id=curEventId;
		END IF;
		END LOOP;
        CLOSE eventCursor;
        COMMIT;
END;
|
DELIMITER ;