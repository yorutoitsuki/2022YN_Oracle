/*
 * 10장 무결성과 제약조건
 * 
 * 테이블 생성에 사용되는 제약 조건
 * 
 * 	PRIMARY KEY(PK) - 테이블의 기본 키를 정의함
	- 기본적으로 NOT NULL, UNIQUE 제약 사항이 설정됨
	(암시적 INDEX 자동 생성)
	
	FOREIGN KEY(FK)
	- 테이블에 외래 키를 정의함
	- 참조 대상을 테이블명(칼럼명) 형식으로 작성해야 함
	- 참조되는 테이블에 컬럼 값이 반드시 PK or UNIQUE 형태로 존재
	- 참조 무결성이 위배되는 상황 발생 시, 다음 옵션으로 처리 가능
	 (CASCADE, NO ACTION, SET NULL, SET DEFAULT)
	 
	UNIQUE - 테이블에서 해당하는 열값은 유일해야 함을 의미함
	- 테이블에서 모든 값이 다르게 적재되어야 하는 열에 설정함
	(암시적 INDEX 자동 생성)
	NULL 허용
	
	NOT NULL - 테이블에서 해당하는 열의 값은 NULL 불가능
	- 필수적으로 입력해야 하는 항목에 설정함
	
	CHECK - 사용자가 직접 정의하는 제약 조건
	- 발생 가능한 상황에 따라 여러 가지 조건을 설정 가능
	(예) CHECK(0 < SALARY && SALARY < 1000000000)
	-----------------------------------------------------------------------------------------------------
	DEFAULT 정의 : 아무런 값을 입력하지 않았을 때 DEFAULT 값이 입력됨
	
	제약조건 : 컬럼레벨 - 하나의 컬럼에 대해 모든 제약 조건을 정의
			테이블 레벨 - 'NOT NULL 제외'한 나머지 제약조건을 정의
 */

------------------1--------------------------------------------------------------------

DROP TABLE CUSTOMER;

CREATE TABLE CUSTOMER(
	ID VARCHAR2(20) UNIQUE,
	PWD VARCHAR2(20) NOT NULL,
	NAME VARCHAR2(20) NOT NULL,
	PHONE VARCHAR2(30),
	ADDRESS VARCHAR2(100)
);

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('CUSTOMER');

------------------2--------------------------------------------------------------------

DROP TABLE CUSTOMER;

/*
 * 제약조건이름 직접 지정할 때 형식
 * CONSTRAINT 제약조건이름
 * CONSTRAINT 테이블명_컬럼
 */
CREATE TABLE CUSTOMER(
	ID VARCHAR2(20) CONSTRAINT CUSTOMER_ID_UNIQUE UNIQUE,
	PWD VARCHAR2(20) CONSTRAINT CUSTOMER_PWD_NN NOT NULL,
	NAME VARCHAR2(20) CONSTRAINT CUSTOMER_NAME_NN NOT NULL,
	PHONE VARCHAR2(30),
	ADDRESS VARCHAR2(100)
);

------------------3--------------------------------------------------------------------

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('CUSTOMER');

DROP TABLE CUSTOMER;

CREATE TABLE CUSTOMER(
	ID VARCHAR2(20) CONSTRAINT CUSTOMER_ID_PK PRIMARY KEY,
	PWD VARCHAR2(20) CONSTRAINT CUSTOMER_PWD_NN NOT NULL,
	NAME VARCHAR2(20) CONSTRAINT CUSTOMER_NAME_NN NOT NULL,
	PHONE VARCHAR2(30),
	ADDRESS VARCHAR2(100)
);

--(4)--PK를 테이블 레벨--------------------------------------

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('CUSTOMER');

DROP TABLE CUSTOMER;

CREATE TABLE CUSTOMER(
	ID VARCHAR2(20),
	PWD VARCHAR2(20) CONSTRAINT CUSTOMER_PWD_NN NOT NULL,
	NAME VARCHAR2(20) CONSTRAINT CUSTOMER_NAME_NN NOT NULL,
	PHONE VARCHAR2(30),
	ADDRESS VARCHAR2(100),
	
	--테이블 레벨
	CONSTRAINT CUSTOMER_ID_PK PRIMARY KEY(ID)
	--CONSTRAINT CUSTOMER_ID_PK PRIMARY KE(ID, NAME) --기본키가 2개이상일 때 테이블 레벨 사용
);

/*
 * 1.1 NOT NULL 제약조건 : 컬럼 레벨로만 정의
 */

INSERT INTO CUSTOMER VALUES(NULL,NULL,NULL,'010-1111-1111', '대구 달서구');--ERROR

--1.2 UNIQUE 제약조건 : 유일한 값만 허용(단, NULL 허용)

INSERT INTO CUSTOMER VALUES('A1234','1234',NULL,'010-2222-2222', '대구 북구');
INSERT INTO CUSTOMER VALUES(NULL,'5678',NULL,'010-3333-3333', '대구 서구');

--1.3 데이터 구분을 위한 PRIMARY KEY 제약조건
--테이블의 모든 ROW를 구별하기 위한 식별자 -> INDEX번호 자동 생성됨

--1.4 '참조 무결성'을 위한 FOREIGN KEY(참조기=외래키) 제약조건
--사원테이블의 부서번호는 언제나 부서테이블을 참조 가능 : 참조 무결성

SELECT * FROM DEPARTMENT;

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMPLOYEE', 'DEPARTMENT');

INSERT INTO EMPLOYEE(ENO, ENAME, DNO) VALUES(8000,'HONG', '');--DNO의 값으로 NULL 허용

SELECT * FROM EMPLOYEE WHERE ENO = 8000;

/*
 * 삽입 방법 -2, 제약조건을 삭제하지 않고 일시적으로 비활성화 -> 데이터 처림 -> 다시 활성화
 * 먼저 USER_CONSTRAINTS 데이터 사전을 이용하여 CONSTRAINT_NAME과 CONSTRAINT_TYPE 조회
 */

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE, STATUS
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMPLOYEE', 'DEPARTMENT');

--제약조건 비활성화
ALTER TABLE EMPLOYEE
DISABLE CONSTRAINT SYS_C007048;

INSERT INTO EMPLOYEE(ENO, ENAME, DNO) VALUES(9000,'DONG', 50);


DELETE 
FROM EMPLOYEE 
WHERE ENO = 
		(SELECT ENO 
		FROM EMPLOYEE
		WHERE DNO NOT IN (
					SELECT DNO 
					FROM DEPARTMENT));
					
UPDATE EMPLOYEE
SET DNO = NULL
WHERE DNO NOT IN(
			SELECT DNO
			FROM DEPARTMENT);

SELECT DNO FROM EMPLOYEE
MINUS
SELECT DNO FROM DEPARTMENT;
		

SELECT * FROM EMPLOYEE;
SELECT ENO FROM EMPLOYEE
WHERE DNO NOT IN (SELECT DNO FROM DEPARTMENT);

ALTER TABLE EMPLOYEE
ENABLE CONSTRAINT SYS_C007048;
/*
 * 삽입 방법 2 정리 : 제약 조건 잠시 비활성화 시켜 원하는 데이터를 삽입하더라도 다시 제약조건 활성화 시키면
 * 오류가 잘생하니 삽입한 데이터를 삭제하거나 수정해야 하는 번거러움이 생김
 * 고로 비추천
 */

/*
 * 삭제(부모인 부서 테이블에서 삭제하는 방법)
 */

DROP TABLE DEPARTMENT CASCADE;

/*
 * 1. 부모 테이블 부터 생성:
 * 주의 제약조건은 복사가 안됨
 * 
 * 2. 자식 테이블 생성:
 */

CREATE TABLE DEPARTMENT2
AS SELECT * FROM DEPARTMENT;

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('DEPARTMENT2');

ALTER TABLE DEPARTMENT2
ADD CONSTRAINT DEPARTMENT2_DNO_PK PRIMARY KEY(DNO);

/*
 * 2.
 */
CREATE TABLE EMP_SECOND(
ENO NUMBER(4) CONSTRAINT EMP_SECOND_DNO_PK PRIMARY KEY,
ENMAE VARCHAR2(10),
JOB VARCHAR2(9),
SALARY NUMBER(7,2) DEFAULT 10000 CHECK(SALARY > 0),
DNO NUMBER(2), 
CONSTRAINT EMP_SECOND_DNO_FK FOREIGN KEY(DNO) REFERENCES DEPARTMENT2(DNO) ON DELETE SET NULL
);


/*
 * ON DELETE 뒤에
 * 1. NO ACTION (기본값) : 부모 테이블 기본키 값을 자식 테이블에서 참조하고 있으면 부모 테이블의 행에 대한 삭제 불가
 * RESTRICT(MYSQL에서 기본값, MYSQL에서 RESTRICT는 NO ACTION과 같은 의미로 사용함)
 * 
 * 오라클 에서는 RESTRICT와 NO ACTION은 약간의 차이가 있음
 * 오라클 에서는 ON DETELE NO ACTION 불가능
 * CASCADE, SET NULL 만 가능
 */


drop table department2 cascade constraints;
/*
 * 부서 테이블을 참조하고 있는 사원 테이블의 '제약 조건'을 먼저 제거하고 부서테이블이 drop됨
 * 먼저, 사원테이블의 참조키 제약조건 제거 후 부서테이블 제거됨
 */

insert into emp_second values(1,'김', '영업', null, 30);
insert into emp_second values(2,'이', '조사', 2000, 20);
insert into emp_second values(3,'박', '운영', 3000, 40);
insert into emp_second values(4,'조', '상담', 3000, 20);

/*
 * 1.5 check 제약조건 : 값의 범위나 조건 지정
 * currval, nextval, rownum 사용불가
 * sysdate 함수 사용불가
 * 
 * check(salary > 0)
 */
--ORA-02290: check constraint (SYSTEM.SYS_C007077) violated
insert into emp_second values(5, '강', '상담', -4000, 20);


insert into emp_second values(5, '강', '상담', 4000, 20);

/*
 * 1.6 default 정의
 * default 값 넣는 2가지 방법
 */
insert into emp_second(eno,ename,job,dno) values(6,'권','인사',30);
insert into emp_second values(6,'권','인사',default,30);--default 대신 1000입력됨
insert into emp_second values(5,'강','상담', 4000, 20);

select * from emp_second;
/*
 * 지금 부터 부모인 부서테이블에서 dno=20 인 row 삭제하면 자식테이블인 사원테이블에서 dno=20인 row도 함께 삭제됨
 * 이유 : foreign key(dno) references department2(dno) on delete cascade
 */
delete from department2 where dno = 20;

select * from department2;
select * from emp_second;

delete from department where dno = 20;
/*
 * 오류, 이유:자식에서 참조하고 있으면 부모의 레코드를 삭제불가(no action(=기본값))
 */

--테이블 전체(테이블 구조 + 데이터) 제거
drop table DEPARTMENT2;--실패, 현재 사원테이블의 참조키로 참조하고 있으므로 테이블 전체 제거 안됨

--테이블 데이터만 삭제(테이블 구조는 남기고)
truncate table department2;--rollback이 불가능함
delete from department2;--rollback 가능하므로(혹시 잘못 삭제 후 다시 복원가능)






