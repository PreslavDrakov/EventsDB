SELECT * 
FROM person_info
WHERE last_name LIKE '%ов' AND id BETWEEN 25 AND 40;

SELECT event_id AS EventId, ROUND(AVG(price),2) AS AvgPriceOfTickets
FROM ticket
GROUP BY event_id
ORDER BY AvgPriceOfTickets DESC;

SELECT t.id AS TicketNumber, event_info.name AS EventName, t.quantity AS TicketQuantity, 
t.sold_tickets AS SoldTickets, t.price AS Price, ticket_type.type AS TicketType, 
ticket_type.description AS TypeDescription
FROM ticket AS t JOIN ticket_type
ON t.type_id=ticket_type.id
JOIN event_info
ON t.event_id=event_info.id
WHERE t.event_id=1;

SELECT e.name AS EventName, CONCAT(s.first_name," ", s.last_name) AS SponsorName
FROM event_info AS e RIGHT OUTER JOIN sponsor AS s
ON e.id IN (SELECT event_id
						FROM event_sponsor
                        WHERE sponsor_id=s.id)
ORDER BY EventName;

SELECT event_info.name AS EventName, location.name AS Location, location.address AS Address,
event_info.time_date AS StartDateAndTime, 
CONCAT(person_info.first_name," ", person_info.last_name) AS CreatorName
FROM event_info JOIN location
ON event_info.location_id=location.id
JOIN person_info
ON person_info.id IN (SELECT creator_id
						FROM event_creator
                        WHERE event_creator.event_id = event_info.id);
                        
SELECT t.event_id AS EventId, event_info.name AS EventName, 
SUM(t.sold_tickets) AS SumOfAllSoldTicketsForTheEvent
FROM ticket AS t JOIN event_info
ON t.event_id=event_info.id
GROUP BY t.event_id
ORDER BY SumOfAllSoldTicketsForTheEvent DESC
LIMIT 5;