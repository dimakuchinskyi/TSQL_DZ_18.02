create database Academy;
go
use Academy;
go
create table Faculties
(
    Id   int identity (1,1) not null primary key,
    Name nvarchar(100)      not null unique
);
create table Departments
(
    Id        int identity (1,1) not null primary key,
    Building  int                not null check (Building between 1 and 5),
    Financing money              not null check (Financing >= 0),
    Name      nvarchar(100)      not null unique,
    FacultyId int                not null,
    constraint FK_Departments_Faculties foreign key (FacultyId) references Faculties (Id)
);
create table Groups
(
    Id           int identity (1,1) not null primary key,
    Name         nvarchar(10)       not null unique,
    Year         int                not null check (Year between 1 and 5),
    DepartmentId int                not null,
    constraint FK_Groups_Departments foreign key (DepartmentId) references Departments (Id)
);
create table Curators
(
    Id      int identity (1,1) not null primary key,
    Name    nvarchar(max)      not null,
    Surname nvarchar(max)      not null
);
create table GroupsCurators
(
    Id        int identity (1,1) not null primary key,
    CuratorId int                not null,
    GroupId   int                not null,
    constraint FK_GroupsCurators_Curators foreign key (CuratorId) references Curators (Id),
    constraint FK_GroupsCurators_Groups foreign key (GroupId) references Groups (Id)
);
create table Students
(
    Id      int identity (1,1) not null primary key,
    Name    nvarchar(max)      not null,
    Surname nvarchar(max)      not null,
    Rating  int                not null check (Rating between 0 and 5)
);
create table GroupsStudents
(
    Id        int identity (1,1) not null primary key,
    GroupId   int                not null,
    StudentId int                not null,
    constraint FK_GroupsStudents_Groups foreign key (GroupId) references Groups (Id),
    constraint FK_GroupsStudents_Students foreign key (StudentId) references Students (Id)
);
create table Subjects
(
    Id   int identity (1,1) not null primary key,
    Name nvarchar(100)      not null unique
);
create table Teachers
(
    Id          int identity (1,1) not null primary key,
    Name        nvarchar(max)      not null,
    Surname     nvarchar(max)      not null,
    Salary      money              not null check (Salary > 0),
    IsProfessor bit                not null default 0
);
create table Lectures
(
    Id        int identity (1,1) not null primary key,
    Date      date               not null check (Date <= getdate()),
    SubjectId int                not null,
    TeacherId int                not null,
    constraint FK_Lectures_Subjects foreign key (SubjectId) references Subjects (Id),
    constraint FK_Lectures_Teachers foreign key (TeacherId) references Teachers (Id)
);
create table GroupsLectures
(
    Id        int identity (1,1) not null primary key,
    GroupId   int                not null,
    LectureId int                not null,
    constraint FK_GroupsLectures_Groups foreign key (GroupId) references Groups (Id),
    constraint FK_GroupsLectures_Lectures foreign key (LectureId) references Lectures (Id)
);
insert into Faculties (Name)
values (N'Computer Science'),
       (N'Mathematics'),
       (N'Physics');
insert into Departments (Building, Financing, Name, FacultyId)
values (1, 150000, N'Software Development', 1),
       (2, 80000, N'Data Science', 1),
       (3, 50000, N'Physics Department', 3);
insert into Groups (Name, Year, DepartmentId)
values (N'SD-501', 5, 1),
       (N'SD-502', 5, 1),
       (N'D221', 2, 2);
insert into Curators (Name, Surname)
values (N'John', N'Doe'),
       (N'Jane', N'Smith'),
       (N'Emily', N'Johnson');
insert into GroupsCurators (CuratorId, GroupId)
values (1, 1),
       (2, 1),
       (3, 2);
insert into Students (Name, Surname, Rating)
values (N'John', N'Doe', 4),
       (N'Jane', N'Smith', 5),
       (N'Emily', N'Johnson', 3),
       (N'Michael', N'Brown', 2);
insert into GroupsStudents (GroupId, StudentId)
values (1, 1),
       (1, 2),
       (2, 3),
       (3, 4);
insert into Subjects (Name)
values (N'Programming'),
       (N'Mathematics'),
       (N'Physics'),
       (N'AI');
insert into Teachers (Name, Surname, Salary, IsProfessor)
values (N'Robert', N'Anderson', 70000, 1),
       (N'Laura', N'Thomas', 50000, 1),
       (N'James', N'Moore', 40000, 0);
insert into Lectures (Date, SubjectId, TeacherId)
values ('2023-10-01', 1, 1),
       ('2023-10-02', 1, 1),
       ('2023-10-03', 1, 1),
       ('2023-10-04', 1, 1),
       ('2023-10-05', 1, 1),
       ('2023-10-06', 1, 1),
       ('2023-10-07', 1, 1),
       ('2023-10-08', 1, 1),
       ('2023-10-09', 1, 1),
       ('2023-10-10', 1, 1),
       ('2023-10-11', 1, 1),
       ('2023-10-01', 2, 2),
       ('2023-10-02', 2, 2),
       ('2023-10-03', 2, 2),
       ('2023-10-04', 2, 2),
       ('2023-10-05', 2, 2),
       ('2023-10-06', 2, 2);
insert into GroupsLectures (GroupId, LectureId)
values (1, 1),
       (1, 2),
       (1, 3),
       (1, 4),
       (1, 5),
       (1, 6),
       (1, 7),
       (1, 8),
       (1, 9),
       (1, 10),
       (1, 11),
       (1, 12),
       (1, 13),
       (1, 14),
       (1, 15),
       (1, 16);
select Building
from Departments
group by Building
having sum(Financing) > 100000;
go
select g.Name as GroupName
from Groups g
         join Departments d on g.DepartmentId = d.Id
         join GroupsLectures gl on g.Id = gl.GroupId
         join Lectures l on gl.LectureId = l.Id
where g.Year = 5
  and d.Name = N'Software Development'
  and l.Date between '2023-10-01' and '2023-10-07'
group by g.Name
having count(l.Id) > 10;
go
select g.Name
from Groups g
         join GroupsStudents gs on g.Id = gs.GroupId
         join Students s on gs.StudentId = s.Id
group by g.Name
having avg(s.Rating) > (select avg(s.Rating)
                        from Groups g
                                 join GroupsStudents gs on g.Id = gs.GroupId
                                 join Students s on gs.StudentId = s.Id
                        where g.Name = N'D221');
go
select Name, Surname
from Teachers
where Salary > (select avg(Salary) from Teachers where IsProfessor = 1);
go
select g.Name
from Groups g
         join GroupsCurators gc on g.Id = gc.GroupId
group by g.Name
having count(gc.CuratorId) > 1;
go
with GroupRatings as (
    select g.Name as GroupName, avg(s.Rating) as AvgRating
    from Groups g
             join GroupsStudents gs on g.Id = gs.GroupId
             join Students s on gs.StudentId = s.Id
    group by g.Name
),
     MinGroupRating as (
         select min(AvgRating) as MinAvgRating
         from GroupRatings
         where GroupName in (
             select g.Name
             from Groups g
             where g.Year = 5
         )
     )
select gr.GroupName
from GroupRatings gr
         join MinGroupRating m on gr.AvgRating < m.MinAvgRating;
go
select s.Name, t.Name + N' ' + t.Surname as TeacherName
from Lectures l
         join Subjects s on l.SubjectId = s.Id
         join Teachers t on l.TeacherId = t.Id
group by s.Name, t.Name, t.Surname
having count(l.Id) =
       (select max(cnt) from (select count(l.Id) as cnt from Lectures l group by l.SubjectId, l.TeacherId) as subquery);
go
select top 1 s.Name
from Subjects s
         join Lectures l on s.Id = l.SubjectId
group by s.Name
order by count(l.Id) asc;
go
select count(distinct gs.StudentId) as StudentCount, count(distinct l.SubjectId) as SubjectCount
from Groups g
         join GroupsStudents gs on g.Id = gs.GroupId
         join GroupsLectures gl on g.Id = gl.GroupId
         join Lectures l on gl.LectureId = l.Id
where g.DepartmentId = (select Id from Departments where Name = N'Software Development');

use master;
drop database Academy;

select Id from Lectures;
