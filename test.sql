create table address(
	anum number primary key,
	name varchar2(20) not null,
	gender char(1),
	tel varchar2(20),
	address varchar2(100) not null
	
);

insert into address values(1, '강민재', 'M', '010-1111-1111', '대구');
insert into address values(2, '권은재', 'F', '010-2222-1111', '부산');
insert into address values(3, '김도영', 'M', '010-1111-2222', '서울');


select * from address;