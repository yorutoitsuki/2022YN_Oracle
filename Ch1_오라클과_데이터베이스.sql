--Ch1 오라클과 데이터베이스
/*
 * DBMS : 연관성 있는 데이터들의 집합을 효율적으로 관리하는 프로그램;
 * Oracle, My-SQL 등
 * 
 * 데이터 저장 장소인 데이터 베이스와 관리하고자 하는 모든 데이터를 서로 연관관계를 가진 테이블(=표) 형식을 저장하는 '관계형 데이터베이스' 라고함;
 * 
 * 
 * 03. SQL과 데이터 조회하기
 * 3.1 오라클에 접속하기
 * '데이터 베이스 사용자'는 '오라클 계정'과 같은 의미
 * <오라클에서 제공하는 사용자 계정>
 * 1.sys : 시스템 유지, 관리, 생성 오라클시스템의 '총관리자', sysdba권한
 * 2.system : 생선관 DB운영, 관리. '관리자'계정, sysoper권한
 * 3.hr : 처음 오라클 사용하는 사용자를 위한 '교육용 계정'
 * 
 */
drop table department;
drop table employEE;

create table department(
DNO number(2) not null primary key, --부서번호
DNAME varchar2(14), --부서명(MySQL:varchar)
LOC varchar2(13) --지역명
);

insert into DEPARTMENT values(10,'ACCOUNTING','NEW YORK');
insert into DEPARTMENT values(20,'RESEARCH','DALLAS');
insert into DEPARTMENT values(30,'SALES','CHICAGO');
insert into DEPARTMENT values(40,'OPERATIONS','BOSTON');


select * from DEPARTMENT;


--------------------부서 정보 ------------------
create table employEE(
ENO number(4) not null primary key, --사원번호
ENAME varchar2(10), -- 사원명
JOB varchar2(9), --업무명
MANAGER number(4), --해당 사원의 상사번호
HIREDATE date, --입사일
SALARY number(7,2), --급여 (실수 : 소수점을 제외한 전체 자리수, 소수점 이하 3째 자리에서 반올림하여 2째 자리까지 표현)
COMMISION number(7,2), --커미션
DNO number(2) REFERENCES DEPARTMENT(DNO) ON DELETE SET NULL -- 부서번호
);


ALTER TABLE EMPLOYEE
DROP CONSTRAINT SYS_C007073;

ALTER TABLE EMPLOYEE
ADD CONSTRAINT FOREIGN KEY(DNO) REFERENCES DEPARTMENT(DNO) ON DELETE SET NULL;

DROP TABLE EMPLOYEE;

--만약, 기곤키가 2개 이상이면

insert into EMPLOYEE values(7369,'SMITH','CLERK',7902,TO_DATE('17-12-1980','DD-MM-YYYY'),800,'',20); --''=NULL
INSERT INTO EMPLOYEE VALUES
(7499,'ALLEN','SALESMAN', 7698,to_date('20-2-1981', 'dd-mm-yyyy'),1600,300,30);
INSERT INTO EMPLOYEE VALUES
(7521,'WARD','SALESMAN', 7698,to_date('22-2-1981', 'dd-mm-yyyy'),1250,500,30);
INSERT INTO EMPLOYEE VALUES
(7566,'JONES','MANAGER', 7839,to_date('2-4-1981', 'dd-mm-yyyy'),2975,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7654,'MARTIN','SALESMAN', 7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);
INSERT INTO EMPLOYEE VALUES
(7698,'BLAKE','MANAGER', 7839,to_date('1-5-1981', 'dd-mm-yyyy'),2850,NULL,30);
INSERT INTO EMPLOYEE VALUES
(7782,'CLARK','MANAGER', 7839,to_date('9-6-1981', 'dd-mm-yyyy'),2450,NULL,10);
INSERT INTO EMPLOYEE VALUES
(7788,'SCOTT','ANALYST', 7566,to_date('13-07-1987', 'dd-mm-yyyy'),3000,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7839,'KING','PRESIDENT', NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO EMPLOYEE VALUES
(7844,'TURNER','SALESMAN',7698,to_date('8-9-1981', 'dd-mm-yyyy'),1500,0,30);
INSERT INTO EMPLOYEE VALUES
(7876,'ADAMS','CLERK',   7788,to_date('13-07-1987', 'dd-mm-yyyy'),1100,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7900,'JAMES','CLERK',   7698,to_date('3-12-1981', 'dd-mm-yyyy'),950,NULL,30);
INSERT INTO EMPLOYEE VALUES
(7902,'FORD','ANALYST',  7566,to_date('3-12-1981', 'dd-mm-yyyy'),3000,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7934,'MILLER','CLERK',  7782,to_date('23-1-1982', 'dd-mm-yyyy'),1300,NULL,10);

select * from EMPLOYEE;


--급여정보----------
--급여정보 테이블

create table salgrade(
GRADE NUMBER, --급여 등급
LOSAL NUMBER, --급여 하한값
HISAL NUMBER  --급여 상한값
);

INSERT INTO SALGRADE values(1, 700, 1200);
INSERT INTO SALGRADE values(2, 1201, 1400);
INSERT INTO SALGRADE values(3, 1401, 2000);
INSERT INTO SALGRADE values(4, 2001, 3000);
INSERT INTO SALGRADE values(5, 3001, 9999);

SELECT * FROM SALGRADE;

--1장 30p
--describe(묘사하다) run sql에서 실행되는 sql+ 명령어
--3.4 조회

SELECT ENO, ENAME FROM EMPLOY;

--3.5 산술 연산자
SELECT ENAME, SALARY, SALARY*12 AS YEAR
FROM EMPLOY
WHERE ENAME='SMITH';

SELECT ENAME, SALARY, SALARY*12 AS YEAR
FROM EMPLOY
WHERE lower(ENAME)='smith';--lower => 소문자로 변환

SELECT ENAME, SALARY, SALARY*12 AS YEAR
FROM EMPLOY
WHERE ENAME=upper('smith');

/*
 * 산술 연산에 null을 사용하는 경우에는 특별한 주의가 필요함
 * null은 미확정, 알 수 없는 값의 의미이므로 연산 할당 비교가 불가능 함
 */


select ename, salary, commision, (salary*12 + commision) as total
from employ;
--commission이 null이면 결과도 null(연산이 안되는 문제 발생)

select ename, salary, commision, (salary*12 + NVL(commision,0)) as total
from employ;
--NVL(null value,value) null값을 대체하는 매서드

select ename, salary, commision, (salary*12 + NVL2(commision,800,0)) as total
from employ;
--NVL(V1, V2, V3) V1이 null이면 V3, Not Null이면 V2 값을 사용

select ename, salary, commision, (salary*12 + NVL2(commision,800,0)) as total
from employ;


/*
 *별칭
 *1. 컬럼명 별칭
 *2. 컬럼명 AS 별칭
 *3. 컬럼명 AS "별칭"
 *
 * 반드시 "" 해야하는 경우
 * 별칭 글자 사이에 '공백, 특수문자' 또는 '대소문자 구분' 
 */

select ename "사원 이름", salary as "급 여", commision as "Cms", (salary*12 + NVL(commision,0)) as "Total"
from employ;


--중복된 데이터를 한번씩만 표시
select distinct dno
from employ;
/*
 * dual : 가상테이블, 결과값을 1개만 표시하고 싶을 때 사용
 */

--sysdate 함수 : 컴퓨터 시스템으로 부터 오늘날짜(주의 : 뒤에 () 없음)
select sysdate
from employ;

select distinct sysdate
from employ;

select * from dual;
select sysdate from dual;



commit












