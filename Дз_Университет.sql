create table facultet (
	id serial primary key,
	name varchar(50),
	price numeric(10, 2) 
);

create table cours (
	id serial primary key,
	number int,
	facultet_id int references facultet(id)
);

create table student (
	id serial primary key,
	name varchar(50),
  	surname varchar(50),
  	patronymic varchar(50),
	student_type varchar(50),
	cours_id int references cours(id)
);

select *
from facultet;

select *
from cours;

select *
from student;

insert into facultet (name, price) 
values('Инженерный', 30000), ('Экономический', 49000);

insert into cours (number, facultet_id) 
values(1, 1), (1, 2), (4, 2);

insert into student (name, surname, patronymic, student_type, cours_id) 
values('Петр', 'Петров', 'Петрович', 'бюджетник', 1),
		('Иван', 'Иванов', 'Иваныч', 'частник', 1),
		('Сергей', 'Михно', 'Иваныч', 'бюджетник', 3),
		('Ирина', 'Стоцкая', 'Юрьевна', 'частник', 3),
		('Настасья', 'Младич', null, 'частник', 2);

select student.*, cours.facultet_id, facultet.price
from student
join cours on student.cours_id = cours.id
join facultet on cours.facultet_id = facultet.id
where facultet.price > 30000;

update student
set cours_id = 2
where student.surname = 'Петров';

select *
from student
where surname is null or patronymic is null;

select *
from student
where name like '%ван%' or surname like '%ван%' or patronymic like '%ван%';

DELETE FROM student;
DELETE FROM cours;
DELETE FROM facultet;

drop table student;
drop table cours;
drop table facultet;















