/*
 * 1. 시퀀스 생성
 * 시퀀스 : 테이블 내의 유일한 숫자를 자동 생성
 * 오라클에서는 데이터가 중복된 값을 가질 수 있으나
 * '개체 무결성'을 위해 항상 유일한 값을 갖도록 하는 '기본키'를 두고 있음
 * 시퀀스는 기본키가 유일한 값을 반드시 갖도록 자동생성하여 사용자가 직접 생성하는 부담감을 줄임
 */

CREATE SEQUENCE 시퀀스명--시작숫자의 기본값은 증가할 때 MINVALUE, 감소할때 MAXVALUE
[START WITH 시퀀스 시작숫자]--증감숫자가 양수면 증가, 응수면 감소(기본값 : 1)
[MINVALUE 최솟값| NOMINVALUE(기본값)]	--NOMINVALUE(기본값) : 증가일 때 1, 감소일때 -10의 26승 까지
									--MINVALUE 최솟값 : 최솟값 설정, 시작숫자과 같거나 작아야함 MAXVALUE보다는 작아야함
[MAXVALUE 최댓값| NOMAXVALUE(기본값)]	--NOMAXVALUE(기본값) : 증가일 때 10의 27승 까지, 감소일 때 -1 까지
									--MAXVALUE 최댓값 : 최댓값 설정, 시작숫자와 같거나 커야하고 MINVALUE보다는 커야함
[CYCLE | NOCYCLE(기본값)] --CYCLE : 최대값 까지 증가 후 최소값으로 다시 시작
						--NOCYCLE : 최대값 까지 증가 후 그다음 시퀀스를 발급 받으려면 에러 발생
[CACHE N | NOCACHE] --CACHE N : 메모리 상에 시퀀스 값을 미리 할당(기본값은 20)
					--NO CACHE : 메모리 상에 시퀀스 값을 미리 할당하지 않음
[ORDER | NOORDER(기본값)]		--ORDER : 병렬서버를 사용할 경우 요청 순서에 따라 정확하게 시퀀스를 생성하기를 원할때
;							--NOORDER : 단일서버일 경우 이 옵션과 관계없이 정확히 요청 순서에 따라 시퀀스가 생성

/*
 * sequence 시퀀스 생성
 */
CREATE SEQUENCE SAMPLE_TEST;

DROP SEQUENCE SAMPLE_TEST2;

CREATE SEQUENCE SAMPLE_TEST2
START WITH -999999999999999999999999990 --9가 26번
INCREMENT BY -10;

SELECT SAMPLE_TEST2.NEXTVAL, SAMPLE_TEST2.CURRVAL FROM DUAL;
SELECT SAMPLE_TEST2.NEXTVAL, SAMPLE_TEST2.CURRVAL FROM DUAL;

SELECT *
FROM USER_SEQUENCES
WHERE SEQUENCE_NAME IN UPPER('SAMPLE_TEST');

/*
 * (2)	SEQUENCE -2 생성
 */
CREATE SEQUENCE SAMPLE_SEQ
START WITH 10
INCREMENT BY 3
MAXVALUE 20
CYCLE
NOCACHE;

SELECT SAMPLE_SEQ.NEXTVAL, SAMPLE_SEQ.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ.NEXTVAL, SAMPLE_SEQ.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ.NEXTVAL, SAMPLE_SEQ.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ.NEXTVAL, SAMPLE_SEQ.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ.NEXTVAL, SAMPLE_SEQ.CURRVAL FROM DUAL;

CREATE SEQUENCE SAMPLE_SEQ2
START WITH 10
INCREMENT BY 3
NOCYCLE
NOCACHE;

DROP SEQUENCE SAMPLE_SEQ2;

SELECT SAMPLE_SEQ2.NEXTVAL, SAMPLE_SEQ2.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ2.NEXTVAL, SAMPLE_SEQ2.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ2.NEXTVAL, SAMPLE_SEQ2.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ2.NEXTVAL, SAMPLE_SEQ2.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ2.NEXTVAL, SAMPLE_SEQ2.CURRVAL FROM DUAL;
/*
 * 1.1 NEXTVAL -> CURRVAL(사용 순서 주의)
 * NEXTVAL : 다음값(새로운 값 생성)다음에
 * CURRVAL : 시퀀스의 현재값 알아냄
 */

SELECT SAMPLE_SEQ2.NEXTVAL FROM DUAL;
SELECT SAMPLE_SEQ2.CURRVAL FROM DUAL;
--ORA-08002: sequence SAMPLE_SEQ2.CURRVAL is not yet defined in this session

SELECT SAMPLE_SEQ2.NEXTVAL, SAMPLE_SEQ2.CURRVAL FROM DUAL;
SELECT SAMPLE_SEQ2.CURRVAL, SAMPLE_SEQ2.NEXTVAL FROM DUAL;
--즉, 순서 관계없이 먼저 SAMPLE_SEQ2.NEXTVAL 다음 값 생성 -> 그 다음 SAMPLE_SEQ2.CURRVAL 실행

/*
 * 1.2 시퀀스를 기본키에 접목하기(295P)
 * 부서 테이블의 기본키인 부서번호는 반드시 유일한 값을 가져야 함
 * 유일한 값을 자동 생성해주는 시퀀스를 통해 순차적으로 증가하는 컬럼값 자동 생성
 */

--실습용 DEPT12테이블 생성
DROP TABLE DEPT12;
CREATE TABLE DEPT12
AS 
SELECT * FROM DEPARTMENT
WHERE 1= 0;
--테이블 구조만 복사(단, 제약조건은 복사 안됨)

--DNO에 기본키 제약조건 추가
ALTER TABLE DEPT12 ADD PRIMARY KEY(DNO);

DROP SEQUENCE DNO_SEQ;
CREATE SEQUENCE DNO_SEQ
START WITH 10
INCREMENT BY 10 NOCYCLE; --NOCYCLE이 기본값 10,20,30,...80,90 (정지)

SELECT * FROM DEPT12;
DELETE FROM DEPT12;
insert into DEPT12 values(DNO_SEQ.NEXTVAL,'ACCOUNTING','NEW YORK');
insert into DEPT12 values(DNO_SEQ.NEXTVAL,'RESEARCH','DALLAS');
insert into DEPT12 values(DNO_SEQ.NEXTVAL,'SALES','CHICAGO');
insert into DEPT12 values(DNO_SEQ.NEXTVAL,'OPERATIONS','BOSTON');


--2. 시퀀스 수정 및 제거
/*
 * 수정시 주의할 사항 2가지
 * 1. start with 시작숫자는 수정 불가
 * 이유, 이미 사용중인 시퀀스의 시작값을 변경할 수 엇ㅂ으므로
 * 시작번호를 다른 번호로 다시 시작하려면 이전 시퀀스를 drop으로 삭제 후 다시 생성
 * 
 * 2. 증가(최소값) : 현재 들어있는 값보다 높은 최소값으로 설정할 수 없다
 * 	  감소(최대값) : 현재 들어있는 값보다 낮은 최대값으로 설정할 수 없다.
 * 	  (예) 최대값 10000 시작하여 10씩 감소할떄
 * 			->최대값 5000으로 변경하면 5000보다 큰 이미 추가된 값들이 무결성을 해침
 */

ALTER SEQUENCE 시퀀스 명 --시퀀스도 DDL(데이터 정의 어)문 이므로 ALTER문으로 수정 가능
--[START WITH 시퀀스 시작숫자]--시퀀스 수정시 사용 불가함. CREATE SEQUENCE에서만 사용
[MINVALUE 최솟값| NOMINVALUE(기본값)]	--NOMINVALUE(기본값) : 증가일 때 1, 감소일때 -10의 26승 까지
									--MINVALUE 최솟값 : 최솟값 설정, 시작숫자과 같거나 작아야함 MAXVALUE보다는 작아야함
[MAXVALUE 최댓값| NOMAXVALUE(기본값)]	--NOMAXVALUE(기본값) : 증가일 때 10의 27승 까지, 감소일 때 -1 까지
									--MAXVALUE 최댓값 : 최댓값 설정, 시작숫자와 같거나 커야하고 MINVALUE보다는 커야함
[CYCLE | NOCYCLE(기본값)] --CYCLE : 최대값 까지 증가 후 최소값으로 다시 시작
						--NOCYCLE : 최대값 까지 증가 후 그다음 시퀀스를 발급 받으려면 에러 발생
[CACHE N | NOCACHE] --CACHE N : 메모리 상에 시퀀스 값을 미리 할당(기본값은 20)
					--NO CACHE : 메모리 상에 시퀀스 값을 미리 할당하지 않음
[ORDER | NOORDER(기본값)]		--ORDER : 병렬서버를 사용할 경우 요청 순서에 따라 정확하게 시퀀스를 생성하기를 원할때
;

SELECT SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY, CYCLE_FLAG, CACHE_SIZE
FROM USER_SEQUENCES--     1        10E+27          10			N			20     
WHERE SEQUENCE_NAME IN ('DNO_SEQ');--대문자

--최대값을 50으로 수정

ALTER SEQUENCE DNO_SEQ
MAXVALUE 50;

SELECT * FROM DEPT12;
INSERT INTO DEPT12 VALUES(DNO_SEQ.NEXTVAL, 'COMPUTING','SEOUL');
INSERT INTO DEPT12 VALUES(DNO_SEQ.NEXTVAL, 'COMPUTING','DAEGU');

--방법 1
ALTER SEQUENCE DNO_SEQ
MAXVALUE 60;

INSERT INTO DEPT12 VALUES(DNO_SEQ.NEXTVAL, 'COMPUTING','DAEGU');

--방법 2
DROP SEQUENCE DNO_SEQ;

INSERT INTO DEPT12 VALUES(70, 'COMPUTING','BUSAN');

CREATE SEQUENCE DNO_SEQ;

INSERT INTO DEPT12 VALUES(DNO_SEQ.NEXTVAL, 'COMPUTING','DAEJAN');

SELECT * FROM DEPT12;

DELETE FROM DEPT12 WHERE LOC = 'DAEJAN';

CREATE SEQUENCE DNO_SEQ
START WITH 80
INCREMENT BY 10;

INSERT INTO DEPT12 VALUES(DNO_SEQ.NEXTVAL, 'COMPUTING','DAEJAN');

SELECT * FROM DEPT12;


---------------------------------------------------------------------------------------------------------------------
/*
 * 3. 인덱스 : DB 테이블에 대한 검색 속도를 향상시켜주는 자료구조
 * 			특정 컬럼에 인덱스를 생성하면 해당 컬럼의 데이터들을 정렬하여 별도의 메모리 공간에 테이터의 물리적 주소와 함께 저장됨
 */

					<INDEX>								<TABLE>
				DATA	LOCATION					LOCATION	DATA
				김		1							1			김
				김		3							2			이
				김		1000						3			김
													4			박
				이		2									
													
				박		4									
													
													1000		김
/*
 * 사용자의 필요에 의해서 직접 생성할 수 있지만
 * 데이터무결성을 확인하기 위해서 수시로 데이터를 검색하는 용도로 사용되는
 * 기본키나 유니크키 는 인덱스 자동생성 됨
 * 
 * USER_INDEXES 나 USER_IND_COLUMNS (컬럼이름까지 검색가능) 데이터 사전에서 INDEX 객체 확인 가능
 * 
 * INDEX 생성 : CREATE INDEX 인덱스명 ON 테이블명(컬럼1, 컬럼2, 컬럼3...);
 * INDEX 삭제 : DROP INDEX 인덱스명;
 */

/*
 * INDEX 생성 전략
 * 생성된 인덱스를 가장 효율적으로 사용하려면 데이터의 분포도는 최대한으로
 * 그리고 조건절에 호출 빈도는 자주 사용되는 컬럼을 INDEX로 생성하는것이 좋다
 * INDEX는 특정 컬럼을 기준으로 생성하고 기준이 된 컬럼으로 '정렬된 INDEX 테이블'이 생성됨
 * 이 기준 컬럼은 최대한 중복이 되지 않는 것이 좋다.
 * 가장 최선은 PK로 INDEX 생성
 * 
 * 1. 조건절에 자주 등장하는 컬럼
 * 2. 항상 비교연산자(=)로 비교되는 컬럼
 * 3. 중복되는 데이터가 최소한인 컬럼
 * 4. ORDER BY절에 자주 사용되는 컬럼
 * 5. JOIN 조건으로 자주 사용되는 컬럼
 */
													
--두 테이블에 자동으로 생성된 INDEX 살피기									
SELECT INDEX_NAME, TABLE_NAME
FROM USER_IND_COLUMNS --COLUMN_NAME 검색 가능
WHERE TABLE_NAME IN ('EMPLOYEE', 'DEPARTMENT');

SELECT INDEX_NAME, TABLE_NAME
FROM USER_INDEXES --COLUMN_NAME 검색 불가능
WHERE TABLE_NAME IN ('EMPLOYEE', 'DEPARTMENT');

--사용자가 직접 INDEX 생성
CREATE INDEX IDX_EMPLOYEE_ENAME
ON EMPLOYEE(ENAME);
--확인
SELECT INDEX_NAME, TABLE_NAME
FROM USER_IND_COLUMNS --COLUMN_NAME 검색 가능
WHERE TABLE_NAME IN ('EMPLOYEE', 'DEPARTMENT');

--하나의 테이블에 INDEX가 많으면 DB 성능에 좋지 않은 영향을 미칠 수 있다. -> INDEX 제거
DROP INDEX IDX_EMPLOYEE_ENAME;
--확인
SELECT INDEX_NAME, TABLE_NAME
FROM USER_IND_COLUMNS --COLUMN_NAME 검색 가능
WHERE TABLE_NAME IN ('EMPLOYEE', 'DEPARTMENT');

/*
 * 299P
 * 인덱스 내부구조는 B-Tree(Balanced Tree = 균형트리)으로 구성되어 있음
 * 컬럼에 인덱스를 설정하면 이를 B-Tree로 생성됨
 * 인덱스 생성을 위한 시간도 필요하고 인덱스를 위한 추가공간도 필요
 * 
 * 인덱스 생성 후에 새로운 행을 추가하거나 삭제할 경우
 * 인덱스로 사용된 컬럼값도 함께 변경 -> 내부구조(B-Tree)도 함께 변경
 * 오라클 서버가 이 작업을 자동으로 발생하므로 인덱스가 있는 경우의 DML 작업이 훨씬 무거워짐
 * 계획성 없이 너무 많은 인덱스를 지정하면 오히려 성능이 저하됨
 * 
 * 300P 표 정리
 * index 사용해야 하는 경우
 * 테이블의 행 수가 많을때
 * where문에 해당 컬럼이 많이 사용될 때
 * 검색 결과가 전테 데이터의 2%~4% 정도일때
 * join에 자주 사용되는 컬럼이나 null을 포함하는 컬럼이 많을 때
 * 
 * index 사용하지 말아야 하는 경우
 * 테이블의 행 수 적을때
 * 검색 결과가 전테 데이터의 10%~15% 이상
 * where문에 해당 컬럼이 자주 사용되지 않을 때
 * 테이블에 DML 작업이 많은 경우, 즉 입력/수정/삭제 등이 자주 일어날 떄
 * 
 */
 
/*
 * --------------------------------------------------------------------------
 * 교제 이외 내용
 * 실습용
 */

create table emp12;
as select * from employee; --제약 조건은 복사 안됨












































