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
 * 1.1 NOT NULL 제약조건
 */

























