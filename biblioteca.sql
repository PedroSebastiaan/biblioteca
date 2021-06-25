DROP DATABASE biblioteca;

--CREATE DATABASE
CREATE DATABASE biblioteca;

\c biblioteca 

CREATE TABLE partners(
    phone INT UNIQUE NOT NULL PRIMARY KEY,
    rut VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,
    address VARCHAR(20) NOT NULL
);

\copy partners FROM 'partners.csv' csv header;

CREATE TABLE authors(
    code INT UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,
    birth_date INT NOT NULL,
    death_date INT
);

\copy authors FROM 'authors.csv' csv header;

CREATE TABLE books(
    isbn VARCHAR(15) NOT NULL PRIMARY KEY,
    title VARCHAR(30) NOT NULL,
    page_count INT NOT NULL,
    loan_time INT NOT NULL
);

\copy books FROM 'books.csv' csv header;

CREATE TABLE relations(
    book_isbn VARCHAR(15) NOT NULL,
    author_code INT NOT NULL,
    coauthor_code INT,
    FOREIGN KEY (book_isbn) REFERENCES books(isbn),
    FOREIGN KEY (author_code) REFERENCES authors(code),
    FOREIGN KEY (coauthor_code) REFERENCES authors(code)
);

\copy relations FROM 'relations.csv' csv header;

CREATE TABLE loans(
    partner_phone INT,
    book_isbn VARCHAR(15),
    start_date DATE NOT NULL,
    expected_return_date DATE NOT NULL,
    real_return_date DATE NOT NULL,
    FOREIGN KEY (partner_phone) REFERENCES partners(phone),
    FOREIGN KEY (book_isbn) REFERENCES books(isbn)
);

\copy loans FROM 'loans.csv' csv header;

--CREATE REQUEST

-- Books with < 300 pages
SELECT isbn, title, page_count FROM books WHERE page_count < 300;

-- Authors was born after than 1970
SELECT name, surname FROM authors WHERE birth_date > 1970;

-- Most popular book
SELECT x.title
FROM (SELECT c.count, b.title FROM(
SELECT book_isbn, COUNT(book_isbn) FROM loans GROUP BY book_isbn) AS c
INNER JOIN books AS b
ON c.book_isbn = b.isbn) AS x
WHERE x.count = (SELECT MAX(c.count) FROM(
SELECT book_isbn, COUNT(book_isbn) FROM loans GROUP BY book_isbn) AS c
INNER JOIN books AS b
ON c.book_isbn = b.isbn);

-- Penalty users
SELECT p.name, p.surname, m.days, m.days*100 AS balance
FROM partners AS p
INNER JOIN (SELECT real_return_date::date - expected_return_date::date AS days, partner_phone
FROM loans
WHERE real_return_date::date - expected_return_date::date > 0) AS m
ON p.phone = m.partner_phone;




