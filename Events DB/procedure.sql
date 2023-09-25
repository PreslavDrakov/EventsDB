DROP PROCEDURE IF EXISTS AllEventEarning;
DELIMITER |
CREATE PROCEDURE AllEventEarning()
BEGIN
	DECLARE cntEventRowsBegin INT;
    DECLARE cntEventRows INT;
    DECLARE cntArchiveRows INT DEFAULT 0;
    DECLARE finished INT DEFAULT 0;
    DECLARE curEventId INT;
    DECLARE curEventDate DATETIME;
    DECLARE curEventExpenses DECIMAL;
    DECLARE sponsorMoney DECIMAL;
    DECLARE standartMoney DECIMAL;
    DECLARE vipMoney DECIMAL;
    DECLARE deluxMoney DECIMAL;
    DECLARE totalProfit DECIMAL;
    DECLARE eventCursor CURSOR FOR SELECT id FROM event_info;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SELECT 'Sql Exception';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS tempTbl (
        id INT NOT NULL,
        name VARCHAR(255) NOT NULL,
        location VARCHAR(255) NOT NULL,
        address VARCHAR(255) NOT NULL,
        time_date DATETIME NOT NULL,
        occasion ENUM("concert","conference","workshop","charity","team build","trade show","comedy show") NOT NULL,
		durration TIME NOT NULL,
		expenses DECIMAL NOT NULL,
        profit DECIMAL NOT NULL
    );
    
    SELECT COUNT(*) INTO cntEventRowsBegin
    FROM event_info;
    SET cntEventRows=cntEventRowsBegin;
    
    START TRANSACTION;
		OPEN eventCursor;
		cursor_loop: LOOP
			FETCH eventCursor INTO curEventId;
			IF finished=1 THEN
				LEAVE cursor_loop;
			END IF;
			SET sponsorMoney = (SELECT IFNULL(SUM(money_given), 0) FROM event_sponsor WHERE event_sponsor.event_id = curEventId);
			SET standartMoney = (SELECT sold_tickets*price FROM ticket WHERE ticket.event_id = curEventId AND type_id IN (SELECT id 
																															FROM ticket_type 
																															WHERE type = 'Standard'));
			SET vipMoney = (SELECT sold_tickets*price FROM ticket WHERE ticket.event_id = curEventId AND type_id IN (SELECT id 
																														FROM ticket_type 
																														WHERE type = 'VIP'));
			SET deluxMoney = (SELECT sold_tickets*price FROM ticket WHERE ticket.event_id = curEventId AND type_id IN (SELECT id 
																														FROM ticket_type 
																														WHERE type = 'Delux'));
			
            SELECT expenses INTO curEventExpenses
            FROM event_info
            WHERE id=curEventId;
            
            SET totalProfit = sponsorMoney + standartMoney + vipMoney + deluxMoney - curEventExpenses;
            
			INSERT INTO tempTbl (id, name, location, address, time_date, occasion, durration, expenses, profit)
			SELECT event_info.id, event_info.name, location.name, location.address, event_info.time_date, event_info.occasion, event_info.durration,
			event_info.expenses, totalProfit
			FROM event_info JOIN location
			ON event_info.location_id=location.id
			WHERE event_info.id = curEventId;
            
            SELECT time_date INTO curEventDate
            FROM event_info
            WHERE event_info.id=curEventId;
            IF(curEventDate<NOW())
				THEN 
					DELETE FROM event_info WHERE id = curEventId;
					INSERT INTO event_archive (event_name, event_date, event_location, event_address, occasion, durration, expenses, profit, archive_date)
					SELECT name, time_date, location, address, occasion, durration, expenses, profit, NOW()
					FROM tempTbl
					WHERE id=curEventId
                    ON DUPLICATE KEY UPDATE
						profit=totalProfit;
					SET cntArchiveRows = cntArchiveRows + 1;
					SET cntEventRows = cntEventRows - 1;
			END IF;
		END LOOP;
		CLOSE eventCursor;

		SELECT DISTINCT id AS EventId, name AS EventName, location AS Location, time_date AS StartDate, occasion AS Occasion,
		durration AS Duration, expenses AS EventExpenses, profit AS EventProfit
		FROM tempTbl
		ORDER BY id;

	IF(cntEventRowsBegin=(cntEventRows+cntArchiveRows))
		THEN COMMIT;
	ELSE
		ROLLBACK;
	END IF;
	DROP TABLE tempTbl;
END;
|
DELIMITER ;
CALL AllEventEarning();
