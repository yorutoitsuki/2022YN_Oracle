--응용SW 기초 기술활용 테스트 정리
--테이블 생성 ->데이터 추가 -> 조회/수정(alter)/삭제

--테이블 생성

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

insert into address values(4, '김은경', 'F', '010-4444-4444', '대구');

update address 
set address = '서울' 
where name = '강민제';

create table test(
name varchar2(10) primary key,
idc number not null,
adr varchar2(20) not null,
phone varchar2(20)
);

insert into test values('red', '001', 'UK', '010-1111-1111');
insert into test values('blue', '002', 'USA', '010-1111-1111');
insert into test values('yellow', '003', 'FR', '010-1111-1111');
insert into test values('whihte', '004', 'PL', '010-1111-1111');
insert into test values('green', '005', 'It', '010-1111-1111');

select * from test;

update test set adr = 'GrM'
where adr = 'FR';

insert into test values('black', '006', 'TK','010-6666-6666');