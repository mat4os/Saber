USE `saber` ;

SELECT * FROM DF_MODULOS ;

DELETE FROM DF_MODULOS WHERE ID_MODULO > 0 ;

INSERT INTO DF_MODULOS (DES_MODULO) VALUES ('Scraping Invertia') ;

-- INSERT INTO DF_MODULOS (ID_MODULO, DES_MODULO) VALUES (6, 'Cosa') ;



SELECT ID_TICKER, TICKER, NOMBRE FROM DF_TICKERS;

SELECT ID_MODULO, DES_MODULO FROM DF_MODULOS;




SELECT * FROM DF_VALORES
ORDER BY FECHA DESC

;

INSERT INTO DF_VALORES(ID_TICKER, ID_MODULO, FECHA, VALOR) VALUES (1, 1, CURDATE(), 1);



SELECT ID_TICKER
FROM DF_TICKERS
WHERE TICKER = 'BAAAAA'
;

SELECT ID_MODULO FROM DF_MODULOS WHERE LOWER(TRIM(DES_MODULO)) = LOWER(TRIM('AAAAA'))
;





SELECT ID_MODULO FROM DF_MODULOS WHERE LOWER(TRIM(DES_MODULO)) = LOWER(TRIM('scrap_invertia_cortop'))

;



SELECT * FROM DF_VALORES ORDER BY FECHA DESC;
;

SELECT ID, NOMBRE, URL FROM RSS_ORIGEN;

SELECT * FROM RSS_FEED;


INSERT INTO RSS_FEED (ID_FEED, ID_RSS, IDENTIFIER, TITLE, LINK, DESCRIPTION, PUBLISHED) VALUES (%s, %s, %s, %s, %s, %s, %s);




SELECT ID_FEED FROM RSS_FEED WHERE ID_RSS = 1 AND IDENTIFIER = 'AAAA';


SELECT * FROM RSS_FEED;

SELECT * FROM RSS_CATEGORIA;

INSERT INTO RSS_CATEGORIA(ID_FEED, CATEGORY) VALUES ()
;


DELETE FROM RSS_CATEGORIA WHERE ID_FEED > 0;

DELETE FROM RSS_FEED WHERE ID_FEED > 0;


SELECT *
FROM RSS_FEED
WHERE PUBLISHED BETWEEN CURDATE()-10 AND CURDATE()
	AND UPPER() LIKE '%%'
;

 SELECT STR_TO_DATE('2013-02-11', '%Y-%m-%d');

SELECT *
FROM RSS_CATEGORIA
LIMIT 10;


SELECT *
FROM RSS_FEED
WHERE ID_RSS != 11
;

SELECT ID_RSS, COUNT(*) AS NUM
FROM RSS_FEED
GROUP BY ID_RSS
ORDER BY NUM DESC
;


DELETE FROM RSS_CATEGORIA;

DELETE FROM RSS_FEED;

DELETE FROM RSS_ORIGEN;


SELECT ID_MODULO, COUNT(*) AS NUM
FROM DF_VALORES
GROUP BY ID_MODULO
ORDER BY NUM DESC;

SELECT * FROM DF_MODULOS;

SELECT *
FROM DF_VALORES
WHERE ID_MODULO >= 6;




SELECT * FROM DF_TERMINOS
;

SELECT * FROM DF_NLP ORDER BY FECHA DESC;

SELECT * FROM DF_VALORES;

SELECT * FROM DF_MODULOS;

SELECT * FROM DF_TICKERS;

SELECT * FROM DF_DatosMacro;


SELECT ID_TERMINO, ID_TICKER, TERMINO FROM DF_TERMINOS;

INSERT INTO DF_TERMINOS (ID_TICKER, TERMINO) VALUES (%s %s);

# terminos = [ticker, nombre, 'dow30', 'nasdaq', 'dolar'] # TODO falta que estos terminos salgan de verdad de algun sitio y sean diferentes para cada ticker

SELECT * FROM DF_TICKERS;

SELECT CONCAT('INSERT INTO DF_TERMINOS (ID_TICKER, TERMINO) VALUES (', ID_TICKER, ', ''', NOMBRE, ''');' )
FROM DF_TICKERS;


SELECT tic.NOMBRE, ter.TERMINO
FROM DF_TICKERS tic, DF_TERMINOS ter
WHERE tic.ID_TICKER = ter.ID_TICKER
ORDER BY tic.NOMBRE, ter.TERMINO;



SELECT
	v.ID_TICKER,
    v.ID_MODULO,
	tic.TICKER,
	tic.NOMBRE AS EMPRESA,
    mo.DES_MODULO AS MODULO,
    v.FECHA,
    v.VALOR
FROM DF_VALORES v, DF_TICKERS tic, DF_MODULOS mo
WHERE
	v.ID_TICKER = tic.ID_TICKER
	AND v.ID_MODULO = mo.ID_MODULO
ORDER BY FECHA DESC, ID_TICKER, ID_MODULO;




SELECT
	v.ID_TICKER,
    v.ID_MODULO,
	tic.TICKER,
	tic.NOMBRE AS EMPRESA,
    mo.DES_MODULO AS MODULO,
    v.FECHA,
    v.VALOR
FROM DF_VALORES v, DF_TICKERS tic, DF_MODULOS mo
WHERE
	v.ID_TICKER = tic.ID_TICKER
	AND v.ID_MODULO = mo.ID_MODULO    
    ;
-- ORDER BY FECHA DESC, ID_TICKER, ID_MODULO;


