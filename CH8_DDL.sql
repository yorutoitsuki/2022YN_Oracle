/*
 * 북스 8장. 테이블 생성 수정 제거하기
 * 데이터 정의어 (DDL)
 *	1.create : db 객체 생성
 *	2.ALTER  : DB 객체 수정
 *  3.DROP   : DB 객체 삭제
 * 	4.RENAME : DB 이름 변경
 * 	5.TRUNCATE : DB 객체 내용 및 저장 공간 삭제
 */

/*
 * ★★  DELETE(DML:데이터 조작어)/ TRUNCATE, DROP(DDL:데이터 정의어) 명령어의 차이점
 (DELETE, TRUNCATE, DROP 명령어는 모두 삭제하는 명령어이지만 중요한 차이점이 있다.)
 
1. DELETE 명령어      : 데이터는 지워지지만 테이블 용량은 줄어 들지 않는다.
                                      원하는 데이터만 삭제할 수 있다.
                                      삭제 후 잘못 삭제한 것은 되돌릴 수 있다.(rollback)  

2. TRUNCATE  명령어 : 용량이 줄어 들고, index 등도 모두 삭제된다.
                                       테이블은 삭제하지는 않고, 데이터만 삭제한다.
                                       한꺼번에 다 지워야 한다. 
                                       삭제 후 절대 되돌릴 수 없다.   

3. DROP 명령어           : 테이블 전체를 삭제(테이블 공간과 객체를 삭제한다.)  
                                       삭제 후 절대 되돌릴 수 없다.  
 */


--1. 테이블 구조를 만드는 CREATE TABLE문(교재206p)
--테이블 생성하기 위해서는 테이블명 정의, 테이블을 구성하는 컬럼의 데이터 타입과 무결성 제약 조건 정의

--<'테이블명' 및 '컬럼명' 정의 규칙>
--문자(영어 대소문자)로 시작, 30자 이내
--문자(영어 대소문자), 숫자0~9, 특수문자(_ $ #)만 사용가능
--대소문자 구별없음, 소문자로 저장하려면 ''로 묶어줘야 함
--동일 사용자의 다른 객체의 이름과 중복X (예)SYSTEM이 만든 테이블명들은 다 달라야 함

--
--<서브 쿼리를 이용하여 다른 테이블로부터 복사하여 테이블 생성 방법>
--서브 쿼리문으로 부서 테이블의 구조와 데이터 복사 -> 새로운 테이블 생성
--create table 테이블명(컬럼명 명시O) : 지정한 컬럼수와 데이터 타입이 서브쿼리문의 검색된 컬럼과 일치
--create table 테이블명(컬럼명 명시X) : 서브쿼리의 컬럼명이 그대로 복사
--
--무결성 제약조건 : ★★ not NULL 조건만 복사,
--               기본키(=PK), 외래키(=FK)와 같은 무결성제약조건은 복사X
--               디폴트 옵션에서 정의한 값은 복사
--
--서브쿼리의 출력 결과가 테이블의 초기 데이터로 삽입됨
--(예) CREATE TABLE AS SELECT문
--CREATE TABLE 테이블명(컬럼명 명시 o)의 예
--문제, 서브쿼리문으로 부서 테이블의 구조와 데이터 복사하기(**제약조건은 복사안됨 -NOT NULL 조건만 복사)


SELECT DNO
FROM DEPARTMENT;


CREATE TABLE DEPT1(DEPT_ID) --컬럼수 1개
AS
SELECT DNO --컬럼수 1개
FROM DEPARTMENT;

SELECT * FROM DEPT1;
--RUN~ 에서 DEPT1의 테이블 구조 확인
DESC DEPT1;

/*
 * 2. CREATE TABLE 테이블명(컬럼명 명시X)의 예
 * 문제, 20번 부서의 소속 사원에 대한 정보를 포함한 DEPT2 테이블 생성하기
 * 서브쿼리문 내에 '산술식'에 대해 별칭 지정해야함(별칭 없으면 오류)
 */
DROP TABLE DEPT2;
CREATE TABLE DEPT2
AS select ENO, ENAME, SALARY * 12 AS "연봉" FROM EMPLOYEE WHERE DNO = '20';

SELECT * FROM DEPT2;

/*
 * 서브쿼리의 데이터는 복사하지 않고 테이블 구조만 복사 방법
 * 서브쿼리의 WHERE절을 항상 거짓이 되는 조건 지정 :
 * 조건에 맞는 데이터가 없으므로 구조만 복사됨
 */

CREATE TABLE DEPT3
AS SELECT * FROM DEPARTMENT
WHERE DNO = 0;
--RUN~에서 DEPT3의 테이블 구조 확인 => 데이터 타입만 복사(이때 제약조건은 복사 안됨)
--------------------------------------------------------------------------------

/*
 * 2. 테이블 구조를 변경하는 ALTER TABLE문
 * 2.1 컬럼 추가(=열 추가) : 추가된 열은 가장 마지막 위치에 생성
 * 
 * 문제, 사원테이블 DEPT2에 날짜 타입을 가진 BIRTH 열 추가
 */

ALTER TABLE DEPT2
ADD BIRTH DATE;

--이 테이블에 기존에 추가한 데이터가 있다면 추가한 열의 값은 NULL로 자동 입력됨
SELECT * FROM DEPT2;

/*
 * 문제, 사원테이블 DEPT2에 문자타입의 EMAIL 열 추가
 * (이때, 기존에 추가한 데이터(행)가 있다면 추가할 열(EMAIL)의 값은
 * 'TEST@TEST.COM'입력
 * ALTER TABLE table_name
 * ADD column_name type [DEFAULT default_value] [NOT NULL]
 */

ALTER TABLE DEPT2
ADD EMAIL VARCHAR2(50) DEFAULT 'TEST@TEST.COM' NOT NULL;

SELECT * FROM DEPT2;

/*
 * 2.2 열 데이터 타입 변경
 */
ALTER TABLE 테이블명
MODIFY 컬럼명 데이터타입 [DEFAULT 값]

/*
 * 기존 컬럼에 데이터가 없는 경우 : 컬럼 타입이나 크기 변경이 자유
 * (아직 INSERT한 ROW(레코드)가 없으므로 자유롭게 변경가능함)
 * 
 * 있는 경우 : 타입변경은 CHAR와 VARCHAR2만 허용하고
 * 변경할 컬럼의 크기가 저장된 데이터의 크기보다 같거나 클 경우에만 변경 가능함
 * 숫자 타입은 폭 또는 전체자릿수 늘릴 수 있음(예) NUMBER,
 * NUMBER(3) = NUMBER(전체자릿수3, 0) : 소수1째자리에서 반올림하여 일의자리(0)까지 표시
 * NUMBER(5,3) = NUMBER(전체자릿수5, 소수2째자리) : 소수 3째자리에서 반올림 123.42
 * 
 * 
 * 문제, 테이블 DEPT2에서 사원이름의 컬럼크기를 변경
 */
ALTER TABLE DEPT2
MODIFY ENAME VARCHAR2(30);

/*
 * 문제 테이블 DEPT2에서 EMAIL의 컬럼크기를 변경 50 -> 40으로 작게 변경
 */

ALTER TABLE DEPT2
MODIFY EMAIL VARCHAR2(40);

/*
 * 문제, 테이블 DEPT2에서 EMAIL의 컬럼 타입을 변경
 */

ALTER TABLE DEPT2
MODIFY EMAIL CHAR(30);

ALTER TABLE DEPT2
MODIFY EMAIL NUMBER(30);
/*
 * 오류, 타입변경은 CHAR와 VARCHAR2만 가능
 * 만약, CHAR(30) -> NUMBER(30)로 변경해야하는 경우 : 해당 컬럼의 값을 모두 지우면 됨
 */

/*
 * 테이블 컬럼의 이름 변경
 */
ALTER TABLE 테이블명
RENAME COLUMN 기존컬럼명 TO 새컬럼명

ALTER TABLE DEPT2
RENAME COLUMN ENAME TO ENAME2;

SELECT * FROM DEPT2;

/*
 * 테이블 DEPT2에서 ENAME에 컬럼 기본값을 '기본'으로 지정
 */

ALTER TABLE DEPT2
MODIFY ENAME2 VARCHAR2(20) DEFAULT '기본' NOT NULL;

/*
 * 2.3 열삭제(=컬럼 삭제) : 2개 이상 컬럼이 존재하는 테이블에서만 열 삭제 가능
 * 
 * 문제, 테이블 DEPT2에서 사원 이름 제거
 */

ALTER TABLE DEPT2
DROP COLUMN ENAME2;

SELECT * FROM DEPT2;

ALTER TABLE DEPT2
ADD ENAME2 VARCHAR2(10);

DESC DEPT2;

/*
 * 2.4 SET UNUSED : 시스템의 요구가 적을 때 컬럼을 제거할 수 있도록 하나 이상의 컬럼을 UNUSED
 * 실제로 제거되지는 않음
 * 그래서 DROP 명령 실행으로 컬럼 제거하는것 보다 응답시간이 빨라짐
 * 
 * 데이터가 존재하는 경우에는 삭제된 것처럼 처리되기 때문에 SELECT절로 조회가 불가능함
 * DESC 문으로도 표시되지 않음
 * 
 * ALTER TABLE 테이블명
 * SET UNUSED(컬럼명)
 * 
 * 문제, 테이블 DEPT2에서 연봉을 UNUSED 상태로 만들기
 */

ALTER TABLE DEPT2
SET UNUSED("연봉");

SELECT * FROM DEPT2;
/*
 * SET UNUSED 사용하는 이유?
 * 1. 사용자에게 조회되지 않게 하기 위해
 * 2. UNUSED로 미사용 상태로 표시한 후 나중에 한꺼번에 DROP으로 제거하기 위해
 * 운영중에 컬럼을 삭제하는 것은 시간이 오래걸릴 수 있으므로 UNUSED로 표시해두고
 * 나중에 한꺼번에 DROP으로 제거
 */

/*
 * 문제, UNUSED로 표시된 모든 컬럼을 한번에 제거
 */

ALTER TABLE DEPT2
DROP UNUSED COLUMNS; --S : 복수

SELECT * FROM DEPT2;

/*
 * 제거 후 다시 같은 이름의 컬럼 추가 가능
 */
ALTER TABLE DEPT2
DROP COLUMN "연봉";

ALTER TABLE DEPT2
ADD "연봉" NUMBER DEFAULT 0;

ALTER TABLE DEPT2
ADD "연봉" NUMBER; 

SELECT * FROM DEPT2;

SELECT ENO, BIRTH, EMAIL, ENAME2, NVL("연봉",0)
FROM DEPT2;

/*
 * ------------------------------------------------------------------
 * 테이블 명 변경
 * 1. RENAME 이전테이블명 TO 새테이블명
 */
RENAME DEPT2 TO EMP;

/*
 * 2. ALTER TABLE 이전테이블명 RENAME TO 새테이블명;
 */
ALTER TABLE EMP RENAME TO EMP2;

/*
 * 테이블 삭제
 */
DROP TABLE 테이블명;
/*
 * 삭제 순서 중요
 * 삭제할 테이블의 기본키(PK : UNIQUE + NOT NULL)나 고유키를 다른 테이블에서 참조하고 있는 경우에는 삭제가 불가능함
 * 
 */
DROP TABLE EMPLOYEE
DROP TABLE DEPARTMENT
--부서 테이블을 삭제할때 사원 테이블의 '참조키 제약조건까지 함께 제거'
DROP TABLE DEPARTMENT CASCADE CONSTRAINTS;

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMPLOYEE');

WHERE TABLE_NAME IN ('EMPLOYEE');
WHERE LOWER(TABLE_NAME) IN ('employee');
WHERE TABLE_NAME IN (UPPER('employee'));
/*
 * TABLE_NAME : 대문자로 표시됨
 * CONSTRAINT_TYPE : P(기본키) C(외래키)
 */

/*
 * 5. 테이블 내용 삭제(=테이블의 모든 데이터만 삭제)
 */
TRUNCATE TABLE 테이블명;
/*
 * 테이블 구조는 유지, 테이블에 생성된 제약조건과 연관된 INDEX, VIEW, 동의어는 유지됨
 * 
 */

SELECT * FROM EMP2;
--테스트를 위해 "연봉" 제거 후 SALARY 추가
ALTER TABLE EMP2
DROP COLUMN "연봉";

ALTER TABLE EMP2
ADD SALARY NUMBER(7,2);

INSERT INTO EMP2 VALUES(1,'2022-07-19', 'HELL@SCREAMM', 'KIM', 2800);

SELECT * FROM EMP2;
TRUNCATE TABLE EMP2;
SELECT * FROM EMP2;
--제약조건 확인
SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2');
--C : NOT NULL, 제약조건 유지됨

/*
 * 6. 데이터 사전 : 사용자와 DB자원을 효율적으로 관리하기 위해 다양한 정보를 저장하는 시스템 테이블 집합
 * 사용자가 테이블을 생성하거나 사용자를 변경하는 등의 작업을 할 때
 * 'DB 서버'에 의해 자동 갱신되는 테이블
 * 사용자가 직접수정X, 삭제X -> '읽기 전용 뷰'로 사용자에게 정보만 제공함
 * (즉, SELECT문만 허용)
 */

/*
 * 객체 : 테이블, 시퀀스, 인덱스, 뷰 등
 * USER_데이터 사전 : 'USER_로 시작~S(복수)'로 끝남
 * 현재 자신의 계정이 소유한 객체 조회 가능
 * 사용자와 가장 밀접하게 관련된 VIEW로
 * 자신이 생성한 테이블, 뷰, 인덱스, 동의어 등의 객체나 해당 사용자에게 권한 정보 제공
 * (1) USER_TABLES : 사용자가 소유한 '테이블'에 대한 정보 조회
 */
SELECT * FROM USER_TABLES;

SELECT * FROM USER_SEQUENCES;

SELECT INDEX_NAME FROM USER_INDEXES;

SELECT VIEW_NAME FROM USER_VIEWS;

/*
 * USER_CONSTRAINTS : 자기 계정의 제약 조건 확인
 */

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMPLOYEE', 'DEPARTMENT');--주의 대문자로 검색

/*
 * 6.2 ALL_데이터 사전
 * 자신의 게정으로 접근할 수 있는 객체와 다른 계정에 접근 가능한 권한을 가진 모든 객체 조회 가능
 * 
 * owner : 조회 중인 객체가 누구의 소유인지 확인
 */

--ALL_TABLES 권한 있는 테이블 목록 확인
/*
 * OWNER : 조회 중인 객체가 누구의 소유인지 확인
 * 사용자 : SYSTEM 일 때 - 결과 500 ROW (SYS와 SYSTEM과 사용자(HR)(교육용) 포함된 상태로 결과가 나옴)
 * 		: HR	 일 때 - 결과 79  ROW (사용자(HR)과 SYS와 SYSTEM 포함한 다른 사용자들 결과로 나옴)
 */
SELECT OWNER, TABLE_NAME
FROM ALL_TABLES;

SELECT OWNER, TABLE_NAME
FROM ALL_TABLES
WHERE OWNER IN('SYSTEM') AND TABLE_NAME IN ('EMPLOYEE', 'DEPARTMENT');

SELECT OWNER, TABLE_NAME
FROM ALL_TABLES
WHERE OWNER IN ('HR');

--(2).ALL_CONSTRAINTS : 권한 있는 제약 조건 확인

SELECT * FROM ALL_CONSTRAINTS;

/*
 * 6.3 DVA_데이터 사전 : 데이터베이스의 모든 객체 조회 가능(DBA_는 시스템 접근 권한)
 * 시스템 관리와 관련된 VIEW, DBA나 시스템 권한을 가진 사용자만 접근 가능
 * SYSTEM 계정으로 접속하여 DBA_데이터 사전을 보는데,
 * 이 때 SYSTEM이 DBA_데이터 사전을 볼 수 있는 권한을 가졌으면 조회가 가능함
 */
SELECT * FROM DBA_TABLES
WHERE OWNER IN ('HR');
--결과 나옴(이유: HR은 DBA_데이터사전을 조회할 권한이 있어서 접근 가능)

/*
 * SYSTEM 접속을 끊고 HR 계정으로 접속
 */
SELECT * FROM DBA_TABLES
WHERE OWNER IN ('HR'); 
--결과 안 나옴(이유: HR은 DBA_데이터사전을 조회할 권한이 없어서 접근 불가능)

/*
 * -------------------------------------------------
 */
CREATE TABLE DEPT(DNO NUMBER(2),
DNAME VARCHAR2(14),
LOC VARCHAR2(13));

CREATE TABLE EMP(
ENO NUMBER(4),
ENAME VARCHAR2(10),
DNO NUMBER(2)
);

ALTER TABLE EMP
MODIFY ENAME VARCHAR(25);

CREATE TABLE EMPLOYEE2(EMP_ID,NAME,SAL,DEPT_ID)
AS SELECT ENO, ENAME, SALARY, DNO FROM EMPLOYEE;

--4-2
alter table employee2
rename column eno to emp_ID;

DROP TABLE EMP;

ALTER TABLE EMPLOYEE2 RENAME TO EMP;

ALTER TABLE DEPT
DROP COLUMN DNAME;

ALTER TABLE DEPT
SET UNUSED(LOC);

ALTER TABLE DEPT
DROP UNUSED COLUMNS;


-------------------------------------------------------------------------------------------------------
/*
 * 제약 조건 변경하기
 * 2.1 제약 조건 추가 : alter table 테이블명 + add constraint 제약조건 이름 + 제약조건
 * 단, 'Not null' 조건은 위의 방법으로 추가하지 못함
 * 				alter table 테이블명 + modify 로 null 상태로 변경 가능
 * 'default 정의할때'도 alter table 테이블명 + modify
 * 
 */

drop table dept_copy;
create table dept_copy
as
select * from department;

drop table emp_copy;
create table emp_copy
as
select * from employee;

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP_COPY', 'DEPT_COPY');

alter table dept_copy add constraint dnpt_copy_pk primary key(dno);

alter table emp_copy add constraint emp_copy_dno_fk foreign key(dno) references dept_copy(dno);

select * from dept_copy;
alter table dept_copy modify dno default 50;

ALTER TABLE EMP_COPY MODIFY ENAME CONSTRAINT EMP_COPY_ENAME_NN NOT NULL;

--DEFAULT 정의 추가하기
ALTER TABLE EMP_COPY MODIFY SALARY CONSTRAINT EMP_COPY_SALARY_D DEFAULT 500;
--ORA-02253: constraint specification not allowed here
--CONSTRAINT 제약조건명 입력하면 안됨(이유 : 제약조건이 아니라 정의 이므로)

ALTER TABLE EMP_COPY MODIFY SALARY DEFAULT 500;

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP_COPY', 'DEPT_COPY');

--체크 제약 조건
ALTER TABLE EMP_COPY
ADD CONSTRAINT EMP_COPY_CHECK CHECK(SALARY > 1000);
--ORA-02293: cannot validate (SYSTEM.EMP_COPY_CHECK) - check constraint violated
--이미 들어간 데이터와 충돌이 일어나서 오류가 발생
SELECT * FROM EMP_COPY
ORDER BY SALARY;

ALTER TABLE EMP_COPY
ADD CONSTRAINT EMP_COPY_SALARY_CHECK CHECK(500 <= SALARY AND SALARY < 10000);

ALTER TABLE DEPT_COPY
ADD CONSTRAINT DEPT_COPY_DNO_CHECK CHECK(DNO IN(10, 20, 30, 40, 50));

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP_COPY', 'DEPT_COPY');

-------------------------------------------------------------------------------------
/*
 * 제약조건 제거
 * 외래키(참조키) 제약조건 에 지정되어 있는 부모 테이블의 기본키 제약조건을 제거하려면
 * 자식 테이블의 참조 무결성 제약조건을 먼저 제거 하거나
 * CASCADE 옵션 사용
 */

ALTER TABLE EMP_COPY
DROP CONSTRAINT EMP_COPY_DNO_FK;

ALTER TABLE DEPT_COPY
DROP PRIMARY KEY;
--ORA-02441: Cannot drop nonexistent primary key
ALTER TABLE DEPT_COPY
DROP PRIMARY KEY CASCADE;

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP_COPY', 'DEPT_COPY');

--NOT NULL 제약조건 제거

ALTER TABLE EMP_COPY
DROP CONSTRAINT EMP_COPY_ENAME_NN;

------------------------------------------------------------------------------
/*
 * 제약조건 활성화 및 비활성화
 * ALTER TABLE 테이블명 + DISABLE CONSTRAINT 제약조건명 [CASCADE]
 */




--<10장 데이터 무결성과 제약조건-혼자 해보기>
--1.employee테이블의 구조만 복사하여 emp_sample 테이블 생성
--사원 테이블의 사원번호 컬럼에 테이블 레벨로 primary key 제약조건을 지정하되
--제약조건명은 my_emp_pk로 지정
DROP TABLE EMP_SAMPLE;

CREATE TABLE EMP_SAMPLE
AS SELECT * FROM EMPLOYEE
WHERE 1=0;

ALTER TABLE EMP_SAMPLE
ADD CONSTRAINT MY_EMP_PK PRIMARY KEY(ENO);

--2.부서테이블의 부서번호 컬럼에 테이블 레벨로 primary key 제약조건 지정하되
--제약조건명은 my_dept_pk로 지정

CREATE TABLE DNO_SAMPLE
AS SELECT * FROM DEPARTMENT;

ALTER TABLE DNO_SAMPLE
ADD CONSTRAINT MY_DEPT_PK PRIMARY KEY(DNO);

--3.사원테이블의 부서번호 컬럼에 존재하지 않는 부서의 사원이 배정되지 않도록
--외래키(=참조키) 제약조건(=참조 무결성)을 지정하되
--제약 조건 이름은 my_emp_dept_fk로 지정

ALTER TABLE EMP_SAMPLE
ADD CONSTRAINT MY_EMP_DEPT_FK FOREIGN KEY(DNO) REFERENCES DNO_SAMPLE;


--4.사원 테이블의 커미션 컬럼에 0보다 큰 값만 입력할 수 있도록 제약조건 지정

DELETE FROM EMP_SAMPLE;

ALTER TABLE EMP_SAMPLE
MODIFY COMMISSION CHECK(COMMISSION > 0);








