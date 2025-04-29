create database Hospital;
go
use Hospital;

create table Departments
(
    Id int identity(1,1) not null primary key,
    Building int not null check (Building between 1 and 5),
    Name nvarchar(100) not null unique
);

create table Doctors
(
    Id int identity(1,1) not null primary key,
    Name nvarchar(max) not null,
    Surname nvarchar(max) not null,
    Salary money not null check (Salary > 0),
    Premium money not null default 0 check (Premium >= 0)
);

create table Wards
(
    Id int identity(1,1) not null primary key,
    Name nvarchar(20) not null unique,
    Places int not null check (Places >= 1),
    DepartmentId int not null foreign key references Departments(Id)
);

create table Examinations
(
    Id int identity(1,1) not null primary key,
    Name nvarchar(100) not null unique
);

create table DoctorsExaminations
(
    Id int identity(1,1) not null primary key,
    StartTime time not null check (StartTime between '08:00' and '18:00'),
    EndTime time not null,
    DoctorId int not null foreign key references Doctors(Id),
    ExaminationId int not null foreign key references Examinations(Id),
    WardId int not null foreign key references Wards(Id),
    constraint CHK_DoctorsExaminations_Time check (EndTime > StartTime)
);

create table Sponsors
(
    Id int identity(1,1) not null primary key,
    Name nvarchar(100) not null unique
);

create table Donations
(
    Id int identity(1,1) not null primary key,
    Amount money not null check (Amount > 0),
    Date date not null default getdate() check (Date <= getdate()),
    DepartmentId int not null foreign key references Departments(Id),
    SponsorId int not null foreign key references Sponsors(Id)
);

insert into Departments (Building, Name)
values (1, N'Cardiology'),
       (2, N'Gastroenterology'),
       (2, N'General Surgery'),
       (3, N'Microbiology'),
       (4, N'Neurology'),
       (5, N'Oncology');

insert into Doctors (Name, Surname, Salary, Premium)
values (N'Thomas', N'Gerada', 5000, 200),
       (N'Anthony', N'Davis', 4500, 300),
       (N'Joshua', N'Bell', 6000, 400);

insert into Wards (Name, Places, DepartmentId)
values (N'Ward A', 10, 1),
       (N'Ward B', 15, 2),
       (N'Ward C', 20, 3),
       (N'Ward D', 25, 3);

insert into Sponsors (Name)
values (N'Sponsor A'),
       (N'Sponsor B'),
       (N'Sponsor C');

insert into Donations (Amount, Date, DepartmentId, SponsorId)
values (1000, '2023-10-01', 1, 1),
       (2000, '2023-10-02', 2, 2),
       (500, '2023-10-03', 3, 3),
       (1500, '2023-10-04', 4, 1),
       (2500, '2023-10-05', 5, 2);

insert into Examinations (Name)
values (N'Blood Test'),
       (N'X-Ray'),
       (N'CT Scan');

insert into DoctorsExaminations (StartTime, EndTime, DoctorId, ExaminationId, WardId)
values ('12:00', '13:00', 3, 1, 1),
       ('14:00', '15:00', 3, 2, 2),
       ('10:00', '11:00', 3, 3, 3);
go
select d1.Name
from Departments d1
         join Departments d2 on d1.Building = d2.Building
where d2.Name = N'Cardiology';

go
select d1.Name
from Departments d1
where d1.Building in (
    select d2.Building
    from Departments d2
    where d2.Name in (N'Gastroenterology', N'General Surgery')
)
group by d1.Name
having count(distinct d1.Building) = 1;

go
select top 1 d.Name
from Departments d
         join Donations dn on d.Id = dn.DepartmentId
group by d.Name
order by sum(dn.Amount) asc;

go
select Surname
from Doctors
where Salary > (select Salary from Doctors where Name = N'Thomas' and Surname = N'Gerada');

go
select w.Name
from Wards w
where w.Places > (
    select avg(w2.Places)
    from Wards w2
             join Departments d on w2.DepartmentId = d.Id
    where d.Name = N'Microbiology'
);
go
select concat(Name, ' ', Surname) as FullName
from Doctors
where (Salary + Premium) > (
    select (Salary + Premium) + 100
    from Doctors
    where Name = N'Anthony' and Surname = N'Davis'
);
go
select distinct d.Name as DepartmentName
from Departments d
         join Wards w on d.Id = w.DepartmentId
         join DoctorsExaminations de on w.Id = de.WardId
         join Doctors doc on de.DoctorId = doc.Id
where doc.Name = N'Joshua' and doc.Surname = N'Bell';
go
select s.Name as SponsorName
from Sponsors s
where s.Id not in (
    select distinct d.SponsorId
    from Donations d
             join Departments dep on d.DepartmentId = dep.Id
    where dep.Name in (N'Neurology', N'Oncology')
);
go
select distinct doc.Surname
from Doctors doc
         join DoctorsExaminations de on doc.Id = de.DoctorId
where de.StartTime >= '12:00' and de.EndTime <= '15:00';

use master
drop database Hospital;