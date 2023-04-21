--создаем БД Holding (Холдинг)
USE master;
DROP DATABASE IF EXISTS Holding;
CREATE DATABASE Holding;
USE Holding;

--создаем таблицу узлов Director (Директор компании)
CREATE TABLE Director
(
  id INT NOT NULL PRIMARY KEY,
  fio NVARCHAR(150) NOT NULL
) AS NODE;
--добавим в таблицу Director 12 человек (совет директоров):
INSERT INTO Director (id, fio)
VALUES
(1, 'Осипов Максим Степанович'),
(2, 'Акимов Илья Романович'),
(3, 'Виноградова Екатерина Александровна'),
(4, 'Румянцев Тимофей Сергеевич'),
(5, 'Щербаков Егор Ильич'),
(6, 'Карасева Анна Ярославовна'),
(7, 'Максимова Алёна Владиславовна'),
(8, 'Мухин Артемий Ильич'),
(9, 'Муравьев Дамир Маркович'),
(10, 'Новиков Леон Глебович'),
(11, 'Новикова Дарья Владимировна'),
(12, 'Чистяков Дмитрий Анатольевич');
--выведем содержимое таблицы Director
SELECT *
FROM Director

--создаем таблицу узлов SisterCompany (Дочерняя компания)
CREATE TABLE SisterCompany
(
  id INT NOT NULL PRIMARY KEY,
  name NVARCHAR(100) NOT NULL,
) AS NODE;
--добавим в таблицу SisterCompany 10 человек:
INSERT INTO SisterCompany (id, name)
VALUES
(1, 'Showa Sekkei'),
(2, 'HMC Architects'),
(3, 'Page Southerland'),
(4, 'Atkins'),
(5, 'SmithGroup JJR'),
(6, 'Hassell'),
(7, 'Woods Bagot'),
(8, 'Perkins Eastman'),
(9, 'Gensler'),
(10, 'RSP Architects');
--выведем содержимое таблицы SisterCompany
SELECT *
FROM SisterCompany

--создаем таблицу узлов SubsidiaryCompany (Внучатая компания)
CREATE TABLE SubsidiaryCompany
(
  id INT NOT NULL PRIMARY KEY,
  name NVARCHAR(100) NOT NULL,
  sisterCompany NVARCHAR(100) NOT NULL,
) AS NODE;
--добавим в таблицу SubsidiaryCompany 15 человек:
INSERT INTO SubsidiaryCompany (id, name, sisterCompany)
VALUES
(1, 'Corgan', 'Woods Bagot'),
(2, 'Beck Group', 'HMC Architects'),
(3, 'Elkus Manfredi Architects', 'Gensler'),
(4, 'Ratio Architects', 'Perkins Eastman'),
(5, 'HNTB Corporation', 'Atkins'),
(6, 'Cuningham Group Architecture', 'SmithGroup JJR'),
(7, 'ZGF Architects', 'Page Southerland'),
(8, 'Robert A.M. Stern Architects', 'Showa Sekkei'),
(9, 'Cooper Carry', 'SmithGroup JJR'),
(10, 'Populous', 'RSP Architects'),
(11, 'TPG Architecture', 'Perkins Eastman'),
(12, 'LS3P', 'Hassell');
--выведем содержимое таблицы SubsidiaryCompany
SELECT *
FROM SubsidiaryCompany

--создаем таблицу ребер isFamiliar, для хранения связи "один директор знаком с другим директором"
CREATE TABLE isFamiliar AS EDGE;

--создаем таблицу ребер containsSubCompany, для хранения связи "дочерняя компания включает в себя внучатые" 
CREATE TABLE containsSubCompany AS EDGE;

--создаем таблицу ребер proposesToInclude, для хранения связи "директор предлагает включить дочернюю компанию в холдинг"
CREATE TABLE proposesToInclude AS EDGE;

--изменим все таблицы ребер, добавив в них ограничение ребер
ALTER TABLE isFamiliar ADD CONSTRAINT EC_isFamiliar CONNECTION (Director TO Director);
ALTER TABLE containsSubCompany ADD CONSTRAINT EC_containsSubCompany CONNECTION (SisterCompany TO SubsidiaryCompany);
ALTER TABLE proposesToInclude ADD CONSTRAINT EC_proposesToInclude CONNECTION (Director TO SisterCompany);

--заполняем таблицы ребер
INSERT INTO isFamiliar($from_id, $to_id)
VALUES ((SELECT $node_id FROM Director WHERE id = 1), (SELECT $node_id FROM Director WHERE id = 2)),
	   ((SELECT $node_id FROM Director WHERE id = 1), (SELECT $node_id FROM Director WHERE id = 3)),
	   ((SELECT $node_id FROM Director WHERE id = 2), (SELECT $node_id FROM Director WHERE id = 6)),
	   ((SELECT $node_id FROM Director WHERE id = 2), (SELECT $node_id FROM Director WHERE id = 9)),
	   ((SELECT $node_id FROM Director WHERE id = 3), (SELECT $node_id FROM Director WHERE id = 5)),
	   ((SELECT $node_id FROM Director WHERE id = 3), (SELECT $node_id FROM Director WHERE id = 8)),
	   ((SELECT $node_id FROM Director WHERE id = 5), (SELECT $node_id FROM Director WHERE id = 2)),
	   ((SELECT $node_id FROM Director WHERE id = 6), (SELECT $node_id FROM Director WHERE id = 11)),
	   ((SELECT $node_id FROM Director WHERE id = 7), (SELECT $node_id FROM Director WHERE id = 12)),
	   ((SELECT $node_id FROM Director WHERE id = 8), (SELECT $node_id FROM Director WHERE id = 4)),
	   ((SELECT $node_id FROM Director WHERE id = 8), (SELECT $node_id FROM Director WHERE id = 10)),
	   ((SELECT $node_id FROM Director WHERE id = 10), (SELECT $node_id FROM Director WHERE id = 7)),
	   ((SELECT $node_id FROM Director WHERE id = 10), (SELECT $node_id FROM Director WHERE id = 12)),
	   ((SELECT $node_id FROM Director WHERE id = 11), (SELECT $node_id FROM Director WHERE id = 7)),
	   ((SELECT $node_id FROM Director WHERE id = 11), (SELECT $node_id FROM Director WHERE id = 9)),
	   ((SELECT $node_id FROM Director WHERE id = 12), (SELECT $node_id FROM Director WHERE id = 8)),
	   ((SELECT $node_id FROM Director WHERE id = 12), (SELECT $node_id FROM Director WHERE id = 9));

INSERT INTO containsSubCompany($from_id, $to_id)
VALUES ((SELECT $node_id FROM SisterCompany WHERE id = 1), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 8)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 2), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 2)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 3), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 7)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 4), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 5)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 5), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 6)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 5), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 9)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 6), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 12)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 7), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 1)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 8), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 4)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 8), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 11)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 9), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 3)),
	   ((SELECT $node_id FROM SisterCompany WHERE id = 10), (SELECT $node_id FROM SubsidiaryCompany WHERE id = 10));


INSERT INTO proposesToInclude($from_id, $to_id)
VALUES ((SELECT $node_id FROM Director WHERE id = 1), (SELECT $node_id FROM SisterCompany WHERE id = 8)),
	   ((SELECT $node_id FROM Director WHERE id = 2), (SELECT $node_id FROM SisterCompany WHERE id = 9)),
	   ((SELECT $node_id FROM Director WHERE id = 3), (SELECT $node_id FROM SisterCompany WHERE id = 6)),
	   ((SELECT $node_id FROM Director WHERE id = 3), (SELECT $node_id FROM SisterCompany WHERE id = 10)),
	   ((SELECT $node_id FROM Director WHERE id = 4), (SELECT $node_id FROM SisterCompany WHERE id = 1)),
	   ((SELECT $node_id FROM Director WHERE id = 5), (SELECT $node_id FROM SisterCompany WHERE id = 2)),
	   ((SELECT $node_id FROM Director WHERE id = 5), (SELECT $node_id FROM SisterCompany WHERE id = 6)),
	   ((SELECT $node_id FROM Director WHERE id = 6), (SELECT $node_id FROM SisterCompany WHERE id = 5)),
	   ((SELECT $node_id FROM Director WHERE id = 7), (SELECT $node_id FROM SisterCompany WHERE id = 3)),
	   ((SELECT $node_id FROM Director WHERE id = 8), (SELECT $node_id FROM SisterCompany WHERE id = 6)),
	   ((SELECT $node_id FROM Director WHERE id = 8), (SELECT $node_id FROM SisterCompany WHERE id = 7)),
	   ((SELECT $node_id FROM Director WHERE id = 9), (SELECT $node_id FROM SisterCompany WHERE id = 6)),
	   ((SELECT $node_id FROM Director WHERE id = 10), (SELECT $node_id FROM SisterCompany WHERE id = 4)),
	   ((SELECT $node_id FROM Director WHERE id = 11), (SELECT $node_id FROM SisterCompany WHERE id = 2)),
	   ((SELECT $node_id FROM Director WHERE id = 11), (SELECT $node_id FROM SisterCompany WHERE id = 9)),
	   ((SELECT $node_id FROM Director WHERE id = 12), (SELECT $node_id FROM SisterCompany WHERE id = 8)),
	   ((SELECT $node_id FROM Director WHERE id = 12), (SELECT $node_id FROM SisterCompany WHERE id = 10));
      

--запросы на выборку к графовым таблицам

--MATCH

--1. Кого из директоров знает директор холдинга (Осипов Максим Степанович)?
SELECT Director1.fio, Director2.fio AS [familiarDirector]
FROM Director AS Director1, isFamiliar, Director AS Director2
WHERE MATCH(Director1-(isFamiliar)->Director2) AND Director1.fio = 'Осипов Максим Степанович';

--2а. Какие компании предлагает включить в холдинг один из директоров (Виноградова Екатерина Александровна)?
SELECT Director.fio, SisterCompany.name AS [companyName]
FROM Director AS Director, proposesToInclude, SisterCompany AS SisterCompany
WHERE MATCH(Director-(proposesToInclude)->SisterCompany) AND Director.fio = 'Виноградова Екатерина Александровна';

--2б. Какие компании предлагает включить в холдинг один из директоров (Чистяков Дмитрий Анатольевич)?
SELECT Director.fio, SisterCompany.name AS [companyName]
FROM Director AS Director, proposesToInclude, SisterCompany AS SisterCompany
WHERE MATCH(Director-(proposesToInclude)->SisterCompany) AND Director.fio = 'Чистяков Дмитрий Анатольевич';

--3. Какие внучатые компании входят в дочернюю компанию холдинга Perkins Eastman?
SELECT SisterCompany.name AS [nameOfSisterComapny], SubsidiaryCompany.name AS [nameOfSubsidiaryCompany]
FROM SubsidiaryCompany AS SubsidiaryCompany, containsSubCompany, SisterCompany AS SisterCompany
WHERE MATCH(SubsidiaryCompany<-(containsSubCompany)-SisterCompany) AND SisterCompany.name = 'Perkins Eastman';

--4. Какие внучатые компании войдут в холдинг после предложения директора с id = 3 включить соответствующие дочерние компании? 
--Вывести id и ФИО директора, дочерние компании и соответстующие им внучатые компании
SELECT Director.id AS [IDdirector], Director.fio AS [DirectorWhoProposes], SisterCompany.name AS [nameOfSisterCompany], SubsidiaryCompany.name AS [nameOfSubsidiaryCompany]
FROM SubsidiaryCompany AS SubsidiaryCompany, containsSubCompany, SisterCompany AS SisterCompany, proposesToInclude, Director AS Director
WHERE MATCH(SubsidiaryCompany<-(containsSubCompany)-SisterCompany<-(proposesToInclude)-Director) AND Director.id = 3;

--5. С кем может познакомиться директор холдинга (Осипов Максим Степанович) через своего партнёра по бизнесу Акимова Илью Романовича?
--Вывести ФИО директора холдинга и ФИО его потенциальных новых знакомых
SELECT DISTINCT Director1.fio AS [HoldingDirector], Director3.fio AS [newFamiliardirector]
FROM Director AS Director1, isFamiliar AS familiar1, Director AS Director2, isFamiliar AS familiar2, Director AS Director3
WHERE MATCH(Director1-(familiar1)->Director2-(familiar2)->Director3) AND Director1.fio = 'Осипов Максим Степанович' AND Director2.fio = 'Акимов Илья Романович';

--SHORTEST_PATH

--1а. Максимально возможное кол-во знакомств директора холдинга (Осипова Максима Степановича)
SELECT Director1.fio AS holdingDirector, STRING_AGG(Director2.fio, '->') WITHIN GROUP (GRAPH PATH) AS newFamiliar
FROM Director AS Director1, isFamiliar FOR PATH AS familiar, Director FOR PATH AS Director2
WHERE MATCH(SHORTEST_PATH(Director1(-(familiar)->Director2)+)) AND Director1.fio = 'Осипов Максим Степанович';

--1б. Максимально возможное кол-во знакомств одного из директоров (Мухина Артемия Ильича)
SELECT Director1.fio AS holdingDirector, STRING_AGG(Director2.fio, '->') WITHIN GROUP (GRAPH PATH) AS newFamiliar
FROM Director AS Director1, isFamiliar FOR PATH AS familiar, Director FOR PATH AS Director2
WHERE MATCH(SHORTEST_PATH(Director1(-(familiar)->Director2)+)) AND Director1.fio = 'Мухин Артемий Ильич';

--2. Просмотреть знакомых и потенциальных знакомых директора холдинга (Осипова Максима Степановича) на глубину не более 2ух уровней
SELECT Director1.fio AS holdingDirector, STRING_AGG(Director2.fio, '->') WITHIN GROUP (GRAPH PATH) AS newFamiliar
FROM Director AS Director1, isFamiliar FOR PATH AS familiar, Director FOR PATH AS Director2
WHERE MATCH(SHORTEST_PATH(Director1(-(familiar)->Director2){1, 2})) AND Director1.fio = 'Осипов Максим Степанович';

