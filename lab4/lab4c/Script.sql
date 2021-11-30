/* 
Lab4c Carl Terve carte495, Mattias Erlingsson mater915
*/

/* 
Drop all created tables
*/
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS contact;
DROP TABLE IF EXISTS reservationmember;
DROP TABLE IF EXISTS passenger;

DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS paymentdetails;
DROP TABLE IF EXISTS reservation;

DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS weeklyschedule;
DROP TABLE IF EXISTS weekday;
DROP TABLE IF EXISTS route;
DROP TABLE IF EXISTS airport;
DROP TABLE IF EXISTS yearpricefactor;
/*
Drop all stored procedures
*/
DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;

DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;


/*
Drop all functions
*/
DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;
DROP FUNCTION IF EXISTS generateTicketNumber;

/*
Drop all triggers
*/
DROP TRIGGER IF EXISTS ticket_trigger;

/*
DROP all views
*/
DROP VIEW IF EXISTS allFlights;
/*
TEMPLATE:

CREATE TABLE (

    PRIMARY KEY(),
    FOREIGN KEY() REFERENCES (),
);
*/
CREATE TABLE airport
(
    airport_code VARCHAR(3),
    country      VARCHAR(30),
    name         VARCHAR(30),
    PRIMARY KEY (airport_code)
);

CREATE TABLE route
(
    year        INTEGER,
    route_price DOUBLE,
    departure   VARCHAR(3),
    arrival     VARCHAR(3),
    PRIMARY KEY (year, departure, arrival),
    FOREIGN KEY (departure) REFERENCES airport (airport_code),
    FOREIGN KEY (arrival) REFERENCES airport (airport_code)
);

CREATE TABLE yearpricefactor
(
    year        INTEGER,
    year_factor DOUBLE,
    PRIMARY KEY (year)
);

CREATE TABLE weekday
(
    year           INTEGER,
    day            VARCHAR(10),
    weekday_factor DOUBLE,
    PRIMARY KEY (year, day),
    FOREIGN KEY (year) REFERENCES yearpricefactor (year)
);

CREATE TABLE weeklyschedule
(
    id             INTEGER AUTO_INCREMENT,
    year           INTEGER,
    day            VARCHAR(10),
    departure_time TIME,
    departure      VARCHAR(3),
    arrival        VARCHAR(3),
    PRIMARY KEY (id),
    FOREIGN KEY (year, departure, arrival) REFERENCES route (year, departure, arrival),
    FOREIGN KEY (year, day) REFERENCES weekday (year, day)
);

CREATE TABLE flight
(
    flight_number INTEGER AUTO_INCREMENT,
    week_id       INTEGER,
    week          INTEGER,
    PRIMARY KEY (flight_number),
    FOREIGN KEY (week_id) REFERENCES weeklyschedule (id)
);

CREATE TABLE reservation
(
    reservation_number   INTEGER AUTO_INCREMENT,
    number_of_passengers INTEGER,
    flight               INTEGER,
    PRIMARY KEY (reservation_number),
    FOREIGN KEY (flight) REFERENCES flight (flight_number)
);

CREATE TABLE passenger
(
    name            VARCHAR(30),
    passport_number INTEGER,
    PRIMARY KEY (passport_number)
);

CREATE TABLE contact
(
    reservation_number INTEGER,
    passport_number    INTEGER,
    mail               VARCHAR(30),
    phone_number       BIGINT,
    PRIMARY KEY (reservation_number, passport_number),
    FOREIGN KEY (reservation_number) REFERENCES reservation (reservation_number),
    FOREIGN KEY (passport_number) REFERENCES passenger (passport_number)
);

CREATE TABLE paymentdetails
(
    card_number BIGINT,
    name        VARCHAR(30),
    PRIMARY KEY (card_number)
);

CREATE TABLE booking
(
    booking_number INTEGER,
    card_number    BIGINT,
    booking_price  DOUBLE,

    PRIMARY KEY (booking_number),
    FOREIGN KEY (card_number) REFERENCES paymentdetails (card_number),
    FOREIGN KEY (booking_number) REFERENCES reservation (reservation_number)
);

CREATE TABLE ticket
(
    ticket_number   INTEGER,
    booking_number  INTEGER,
    passport_number INTEGER,
    PRIMARY KEY (booking_number, passport_number),
    FOREIGN KEY (booking_number) REFERENCES booking (booking_number),
    FOREIGN KEY (passport_number) REFERENCES passenger (passport_number)
);

CREATE TABLE reservationmember
(
    reservation_number INTEGER,
    passport_number    INTEGER,
    PRIMARY KEY (reservation_number, passport_number),
    FOREIGN KEY (reservation_number) REFERENCES reservation (reservation_number),
    FOREIGN KEY (passport_number) REFERENCES passenger (passport_number)
);

/* PROCEDURES  - Question 3*/

/* Insert a year: PROCEDURE call: addYear(year, factor); */
DELIMITER //

CREATE PROCEDURE addYear(IN year INTEGER, IN year_factor DOUBLE)
BEGIN
    INSERT INTO yearpricefactor VALUES (year, year_factor);
END //


/*Insert a day: PROCEDURE call: addDay(year, day, factor);*/

CREATE PROCEDURE addDay(IN year INTEGER, IN day VARCHAR(10), IN weekday_factor DOUBLE)
BEGIN
    INSERT INTO weekday VALUES (year, day, weekday_factor);
END //

/* Insert a destination: PROCEDURE call: addDestination(airport_code, name,
country); */
CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
    INSERT INTO airport VALUES (airport_code, country, name);
END //

/* Insert a route: PROCEDURE call: addRoute(departure_airport_code,
arrival_airport_code, year, routeprice); */
CREATE PROCEDURE addRoute(IN departure VARCHAR(3), IN arrival VARCHAR(30), IN year INTEGER, IN route_price DOUBLE)
BEGIN
    INSERT INTO route VALUES (year, route_price, departure, arrival);
END //

/* Insert a weekly flight: PROCEDURE call: addFlight(departure_airport_code,
arrival_airport_code, year, day, departure_time); Note that this PROCEDURE
should add information in both weeklyflights and flights (you can assume
there are 52 weeks each year).*/

CREATE PROCEDURE addFlight(IN departure VARCHAR(3), IN arrival VARCHAR(3), IN year INTEGER, IN day VARCHAR(10),
                           IN departure_time TIME)
BEGIN
    DECLARE week INTEGER;
    DECLARE last_id INTEGER;
    INSERT INTO weeklyschedule(year, day, departure_time, departure, arrival)
    VALUES (year, day, departure_time, departure, arrival);
    SET last_id = LAST_INSERT_ID();
    SET week = 1;

    week_loop:
    LOOP
        IF week > 52 THEN
            LEAVE week_loop;
        ELSE
            INSERT INTO flight(week_id, week) VALUES (last_id, week);
            SET week = week + 1;
            ITERATE week_loop;
        END IF;

    END LOOP;

END //


/* FUNCTIONS - Question 4 */

CREATE FUNCTION calculateFreeSeats(flightnumber INTEGER)
    RETURNS INTEGER

BEGIN

    /* available seats*/
    DECLARE n INTEGER;
    SELECT 40 - count(booking_number)
    INTO n
    FROM ticket
    WHERE booking_number IN
          (SELECT reservation_number
           FROM reservation
           WHERE flight = flightnumber);
    RETURN n;

END //

CREATE FUNCTION calculatePrice(flightnumber INTEGER)
    RETURNS DOUBLE

BEGIN

    DECLARE total_price DOUBLE;

    DECLARE routeprice DOUBLE;
    DECLARE weekdayfactor DOUBLE;
    DECLARE yearfactor DOUBLE;
    DECLARE bookedpassengers DOUBLE;
    SET bookedpassengers = 40 - calculateFreeSeats(flightnumber);

    /* Retrieve and set route price */
    SELECT route_price
    INTO routeprice
    FROM route
             INNER JOIN weeklyschedule
                        ON route.departure = weeklyschedule.departure
                            AND route.arrival = weeklyschedule.arrival
                                AND route.year = weeklyschedule.year
             INNER JOIN flight
                 ON flightnumber = flight_number
                        AND weeklyschedule.id = flight.week_id;

    /* Retrieve and set weekday factor */
    SELECT weekday_factor
    INTO weekdayfactor
    FROM weekday
             INNER JOIN weeklyschedule
                 ON weekday.year = weeklyschedule.year
                        AND weekday.day = weeklyschedule.day
             INNER JOIN flight
                 ON flightnumber = flight_number
                        AND weeklyschedule.id = flight.week_id;

    /*Calculates and sets profit factor*/
    SELECT year_factor
    INTO yearfactor
    FROM yearpricefactor
             INNER JOIN weeklyschedule
                 ON yearpricefactor.year = weeklyschedule.year
             INNER JOIN flight
                 ON flight_number = flightnumber
                        AND weeklyschedule.id = flight.week_id;

    SET total_price = routeprice * weekdayfactor * ((bookedpassengers + 1) / 40) * yearfactor;
    RETURN ROUND(total_price,3);

END //



/*QUESTION 5: Trigger that issues unique unguessable ticket-numbers*/
CREATE TRIGGER ticket_trigger
    AFTER INSERT
    ON booking
    FOR EACH ROW
BEGIN
    /*Add all passengers with corresponding unique ticket number for a booking*/
    INSERT INTO ticket(ticket_number, booking_number, passport_number)
    SELECT generateTicketNumber(), new.booking_number, passport_number
    FROM reservationmember
    WHERE reservation_number = new.booking_number;
END //

/*Function to return a random ticket number*/
CREATE FUNCTION generateTicketNumber()
    RETURNS INTEGER

BEGIN
       /*Check that ticket number doesnt exist*/
    DECLARE ticketNum INTEGER;
    DECLARE okNum INTEGER;
    SET okNum = 0;
    SET ticketNum = round(1000000*rand());
    WHILE okNum = 0 DO
        IF EXISTS(SELECT ticket_number FROM ticket WHERE ticket_number = ticketNum) = 0 THEN
            SET okNum = 1;
        ELSE
            SET ticketNum = round(1000000*rand());
        END IF;
    END WHILE;
    RETURN ticketNum;
END //

/*QUESTION 6: Stored procedures*/

CREATE PROCEDURE addReservation(departure_airport_code VARCHAR(3), arrival_airport_code VARCHAR(3),
                                year INTEGER, week INTEGER, day VARCHAR(10), time TIME, number_of_passengers INTEGER,
                                OUT output_reservation_nr INTEGER)
BEGIN
    DECLARE flight_num INTEGER;
    DECLARE free_seats INTEGER;

    SET flight_num = (SELECT flight_number
                      FROM flight
                      WHERE week_id = (
                          SELECT id
                          FROM weeklyschedule
                          WHERE weeklyschedule.year = year
                            AND weeklyschedule.departure = departure_airport_code
                            AND weeklyschedule.arrival = arrival_airport_code
                            AND weeklyschedule.departure_time = time
                            AND weeklyschedule.day = day
                      )
                        AND flight.week = week);
    IF flight_num IS NOT NULL THEN
        SET free_seats = calculateFreeSeats(flight_num);
        IF free_seats >= number_of_passengers THEN
            INSERT INTO reservation(number_of_passengers, flight) VALUES (number_of_passengers, flight_num);
            SET output_reservation_nr = LAST_INSERT_ID();
            SELECT output_reservation_nr;
        ELSE
            SELECT "Not enough seats" as "Message";
        END IF;
    ELSE
        SELECT "There exist no flight for the given route, date and time" AS "Message";
    END IF;
END //

/* Procedure to add passengers */
CREATE PROCEDURE addPassenger(reservation_nr INTEGER, passportnumber INTEGER, nameP VARCHAR(30))
BEGIN
    IF EXISTS(SELECT booking_number FROM booking WHERE booking_number = reservation_nr) = 0 THEN
        IF EXISTS(SELECT reservation_number FROM reservation WHERE reservation.reservation_number = reservation_nr) = 1 THEN
            IF EXISTS(SELECT passport_number FROM passenger WHERE passenger.passport_number = passportnumber) = 0 THEN
                INSERT INTO passenger VALUES (nameP, passportnumber);
            END IF;
            INSERT INTO reservationmember VALUES (reservation_nr, passportnumber);
        ELSE
            SELECT "The given reservation number does not exist" AS "Message";
        END IF;
    ELSE
        SELECT "The booking has already been payed and no futher passengers can be added" AS "Message";
    END IF;
END //


CREATE PROCEDURE addContact(reservation_nr INTEGER, passport_number INTEGER, email VARCHAR(30), phone BIGINT)
BEGIN

    IF EXISTS(SELECT reservation_number FROM reservation WHERE reservation.reservation_number = reservation_nr) = 1 THEN
        IF EXISTS(SELECT passport_number FROM passenger WHERE passenger.passport_number = passport_number) = 1 THEN
            INSERT INTO contact VALUES (reservation_nr, passport_number, email, phone);
        ELSE
            SELECT "Contact is not a passenger" as "Message";
        END IF;
    ELSE
        SELECT "The given reservation number does not exist" AS "Message";
    END IF;
END //

/*Add a payment: Procedure call to handle: addPayment (reservation_nr,
cardholder_name, credit_card_number); This procedure should, if the
reservation has a contact and there are enough unpaid seats on the plane, add
payment information to the reservation and save the amount to be drawn from
the credit card in the database. If the conditions above are not fulfilled the
appropriate error message should be shown*/

CREATE PROCEDURE addPayment(reservation_nr INTEGER, cardholder_name VARCHAR(30), credit_card_number BIGINT)
BEGIN
    DECLARE numFreeSeats INTEGER;
    DECLARE flightNum INTEGER;
    DECLARE numPassengers INTEGER;
    DECLARE price DOUBLE;
    IF EXISTS(SELECT reservation_number FROM reservation WHERE reservation_number = reservation_nr) = 1 THEN
        IF EXISTS(SELECT reservation_number FROM contact WHERE reservation_number = reservation_nr) = 1 THEN
            SELECT flight INTO flightNum FROM reservation WHERE reservation.reservation_number = reservation_nr;
            SET numFreeSeats = calculateFreeSeats(flightNum);
            SELECT sleep(5);
            SELECT COUNT(reservation_number)
            INTO numPassengers
            FROM reservationmember
            WHERE reservationmember.reservation_number = reservation_nr;
            IF (numFreeSeats >= numPassengers) THEN
                IF EXISTS(SELECT card_number FROM paymentdetails WHERE card_number=credit_card_number) = 0 THEN
                    INSERT INTO paymentdetails VALUES (credit_card_number, cardholder_name);
                END IF;
                SET price = calculatePrice(flightNum);
                INSERT INTO booking VALUES (reservation_nr, credit_card_number, price);
            ELSE
                SELECT "There are not enough seats available on the flight anymore, deleting reservation" AS "Message";
            END IF;
        ELSE
            SELECT "There is no contact for this reservation number" AS "Message";
        END IF;
    ELSE
        SELECT "The given reservation number does not exist" AS "Message";
    END IF;
END //
DELIMITER ;

/*
QUESTION 7 - . Create a view allFlights containing all flights in your database with the following
information: departure_city_name, destination_city_name, departure_time,
departure_day, departure_week, departure_year, nr_of_free_seats,
current_price_per_seat. See the testcode for an example of how it can look like.
*/


CREATE VIEW allFlights
            (departure_city_name, destination_city_name, departure_time,
             departure_day, departure_week, departure_year, nr_of_free_seats,
             current_price_per_seat)
AS
(

SELECT a.name                        AS 'departure_city_name',
       b.name                        AS 'arrival_city_name',
       departure_time,
       day,
       week,
       year,
       calculateFreeSeats(flight_number)
                                     AS 'nr_of_free_seats',
       calculatePrice(flight_number) AS 'current_price_per_seat'
FROM flight
         INNER JOIN weeklyschedule
                    ON flight.week_id = id
         INNER JOIN airport a ON departure = a.airport_code
         INNER JOIN airport b ON arrival = b.airport_code
    );


/* QUESTION 8. Answer the following theoretical questions:

a) How can you protect the credit card information in the database from hackers?
    - One way is not to store the actual credit card information in the database.
   By encrypting the sensitive data you make sure that the content in the
   database does not make any sense to the hackers.

   - Good password policy to enter the database.


b) Give three advantages of using stored procedures in the database (and thereby
   execute them on the server) instead of writing the same functions in the frontend
   of the system (in for example java-script on a web-page)?

   - Whenever you write a stored procedure they are compiled and stored which
   make responses quick when called.

   - Client must retrieve all data necessary for computation from database
     which burdens the network. This causes overhead in form of network traffic
     which is not the case when stored procedures are used.

   - More safe to do computations on server side than on client side.

   - More modular

   - Heavy computations on application-side might worsen the user experience due to
     lag, delays and such.
*/


/*
9. Open two MySQL sessions. We call one of them A and the other one B. Write
START TRANSACTION; in both terminals.
a) In session A, add a new reservation.
We wrote START TRANSACTION; in both terminal A and B followed by adding the data in to A:

    CALL addYear(2010, 2.3);
    CALL addDay(2010,"Monday",1);
    CALL addDestination("MIT","Minas Tirith","Mordor");
    CALL addDestination("HOB","Hobbiton","The Shire");
    CALL addRoute("MIT","HOB",2010,2000);
    CALL addFlight("MIT","HOB", 2010, "Monday", "09:00:00");
    CALL addFlight("MIT","HOB", 2010, "Monday", "21:00:00");

After we added this data we created a reservation in terminal A with the following CALL:
    CALL addReservation("MIT","HOB",2010,1,"Monday","09:00:00",3,@a);

b) Is this reservation visible in session B? Why? Why not?
After what was done in a) we wrote "SELECT * FROM reservation;" in terminal B
which returned:
    Empty set (0,01 sec)
while we at the same time in terminal A get:
    +--------------------+----------------------+--------+
    | reservation_number | number_of_passengers | flight |
    +--------------------+----------------------+--------+
    |                  1 |                    3 |      1 |
    +--------------------+----------------------+--------+
    1 row in set (0,01 sec)

The reason for this is that A acquires a write lock on the tables for which it has changed but not a read lock.
Therefore B can read the last committed table which will not contain the reservation that A added, since
A has not yet committed its transaction, and therefore not yet released its lock.

If B tries to add its own reservation it will be interrupted by A

c) What happens if you try to modify the reservation from A in B? Explain what
happens and why this happens and how this relates to the concept of isolation
of transactions.

As we mentioned in b) A has a write lock on the reservation table until it commits or does a rollback.
Therefore B will have do wait for A to release its lock before it can alter the table in any way.
However, as soon as A releases the lock, B will acquire the write lock for itself and complete its query.
If B waits too long for the lock, eventually it will time out.

By using locks in this way the database ensures isolation between concurrent running transactions.
*/

/* QUESTION 10 - Is your BryanAir implementation safe when handling multiple concurrent
transactions? Let two customers try to simultaneously book more seats than what are
available on a flight and see what happens. This is tested by executing the testscripts
available on the course-page using two different MySQL sessions. Note that you
should not use explicit transaction control unless this is your solution on 10c */

/*a) Did overbooking occur when the scripts were executed? If so, why? If not,
why not?
The 2nd session was denied its booking since there were not enough seats available, the number of free seats
was 19, which was not sufficient for the booking. Therefore there was not any overbooking.
No overbooking occured, this is due to not using a START TRANSACTION(like in question9) where the commit would come
after a body of queries, now instead there is a commit after each query which ensures isolation. */

/*b) Can an overbooking theoretically occur? If an overbooking is possible, in what
order must the lines of code in your procedures/functions be executed.
Assume that we have transactions T1 and T2:
  T1: reads number of free seats in addPayment and sees that there are 40 available(and saves the nr)
  T2: reads number of free seats in addPayment and sees that there are 40 available(and saves the nr)
  T1: successfully adds payment details and completes its booking
  T2: believes that there are still 40 available seats(its saved value) and also adds payment details
      and completes its booking

Due to the fact that T2 managed to read the number of free seats after T1 did so, but before T1 could
complete its payment and booking, T2 used old data and therefore it leaves room for overbooking.
However, we cant run both T1 and T2 completely simultaneously and therefore this is not likely to practically occur.*/

/*c) Try to make the theoretical case occur in reality by simulating that multiple
sessions call the procedure at the same time. To specify the order in which the
lines of code are executed use the MySQL query SELECT sleep(5); which
makes the session sleep for 5 seconds. Note that it is not always possible to
make the theoretical case occur, if not, motivate why.

We place the SELECT sleep(5); directly after SET numFreeSeats = calculateFreeSeats(flightNum);, this will result in the
scenario mentioned in B). Thanks to the sleep T1 and T2 will execute the following lines of code with the same
value for the number of free seats on the flight. This means that both transactions will eventually be successfull in
adding a payment and completing its booking which will result in an overbooking.

Below you can see parts of the values and results from T1 and T2 respectively.

  T1:
+--------------+----------------+
| numFreeSeats | reservation_nr |
+--------------+----------------+
|           40 |              1 |
+--------------+----------------+
+-----------------------------------------------------------------------------------------+------------------+
| Message                                                                                 | nr_of_free_seats |
+-----------------------------------------------------------------------------------------+------------------+
| Nr of free seats on the flight (should be 19 if no overbooking occured, otherwise -2):  |               19 |
+-----------------------------------------------------------------------------------------+------------------+
  T2:
+--------------+----------------+
| numFreeSeats | reservation_nr |
+--------------+----------------+
|           40 |              2 |
+--------------+----------------+
+-----------------------------------------------------------------------------------------+------------------+
| Message                                                                                 | nr_of_free_seats |
+-----------------------------------------------------------------------------------------+------------------+
| Nr of free seats on the flight (should be 19 if no overbooking occured, otherwise -2):  |               -2 |
+-----------------------------------------------------------------------------------------+------------------+
  */



/*d) Modify the testscripts so that overbookings are no longer possible using
(some of) the commands START TRANSACTION, COMMIT, LOCK TABLES, UNLOCK
TABLES, ROLLBACK, SAVEPOINT, and SELECT…FOR UPDATE. Motivate why your
solution solves the issue, and test that this also is the case using the sleep
implemented in 10c. Note that it is not ok that one of the sessions ends up in a
deadlock scenario. Also, try to hold locks on the common resources for as
short time as possible to allow multiple sessions to be active at the same time.
Note that depending on how you have implemented the project it might be very
hard to block the overbooking due to how transactions and locks are
implemented in MySQL. If you have a good idea of how it should be solved but
are stuck on getting the queries right, talk to your lab-assistant and he or she
might help you get it right or allow you to hand in the exercise with
pseudocode and a theoretical explanation

By encapsulating addPayment in the testscript (Question10MakeBooking.sql) with LOCK TABLES and UNLOCK TABLES we can ensure
that overbooking cant occur as in the case with 10c. All tables used during the addPayment procedure are either read or write
locked depending on what is done with the tables. We also locked ticket since it may be used in the trigger.
Here follows what we added in the testscript:

LOCK TABLES reservation read, contact read, ticket write, reservationmember read, paymentdetails write, route read,
flight read, weekday read, yearpricefactor read, booking write, weeklyschedule read;
    CALL addPayment (@a, "Sauron",7878787878);
UNLOCK TABLES;

And instead of the result in 10c (still using the SELECT sleep(5);), we now instead get the following for two
transactions T1 and T2:

T1:
+-----------------------------------------------------------------------------------------+------------------+
| Message                                                                                 | nr_of_free_seats |
+-----------------------------------------------------------------------------------------+------------------+
| Nr of free seats on the flight (should be 19 if no overbooking occured, otherwise -2):  |               19 |
+-----------------------------------------------------------------------------------------+------------------+
T2:
+-----------------------------------------------------------------------------------------+------------------+
| Message                                                                                 | nr_of_free_seats |
+-----------------------------------------------------------------------------------------+------------------+
| Nr of free seats on the flight (should be 19 if no overbooking occured, otherwise -2):  |               19 |
+-----------------------------------------------------------------------------------------+------------------+

Where T1 gets to complete the payment and the booking and no overbooking occured. 
  */

/* QUESTION: Identify one case where a secondary index would be useful. Design the index,
describe and motivate your design.

Lets assume that the police is searching for a mr Anderson,
which they suspect will leave the country, most likely through a flight with BrianAir.
It would then be handy to be able to search for a last name among all the passenger
with a reservation in the flight company.

The company could then use secondary indexes on non-key.
The index file could contain all the passengers last names in order. These would however not be unique
since the last name of a passengers is not unique.
Each entry in the index file would then point to the first entry in the block where the actual passengers is.

Since the number of passengers flying with BrianAir would be big, all scenarios where you would have to
search in the passenger table could benefit from such an index. This saves the company, and the police a lot of time.

*/




