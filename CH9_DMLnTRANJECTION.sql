


/*
 * 북스 9장. 데이터 조작과 트랜젝션
 * 데이터 조작어 (DML : DATA MANIPULATION LANGUAGE)
 * 1. INSERT : 데이터 입력
 * 2. UPDATE : 데이터 수정
 * 3. DELETE : 데이터 삭제
 * 위 작업 후 반드시 COMMIT;(영구적으로 데이터 저장)
 */

/*
 * TCL(TRANSACTION CONTROL LANGUAGE):트랜잭션 처리어(COMMIT, ROLLBACK, SAVEPOINT)
 */
----------------------------------------------------------------------------------------------------------------------
/*
 * 1. INSERT : 데이터 입력하여 테이블에 내용 추가
 * 문자(CHAR, VARCHAR2)와 날짜(DATE)는 ''를 사용
 */

--실습을 위해 기존 부서테이블의 구조만 복사하여 DEPT_COPY 테이블 생성
--이때, 제약조건은 복사안됨, NOT NULL 제약조건만 복사
CREATE TABLE DEPT_COPY
AS SELECT * FROM DEPARTMENT
WHERE 0 = 1;
DROP TABLE DEPT_COPY;

SELECT * FROM DEPT_COPY;

DESC DEPT_COPY;

INSERT INTO DEPT_COPY VALUES(10, 'ACCOUNTING', '뉴욕');
INSERT INTO DEPT_COPY(DNO,LOC, DNAME) VALUES(20, '달라스', 'RESEARCH');

COMMIT;
/*
 * RUN SQL 또는 SQL DEVLOPER를 사용할 때는 반드시 COMMIT; 해줘야함
 */

/*
 * 1.1 NULL값을 갖는 ROW 삽입
 * 문자나 날짜 타입은 NULL 대신 '' 사용 가능
 * 제약조건이 복사되지 않음, 아래 3개 다 같은 형식임
 */
INSERT INTO DEPT_COPY(DNO, DNAME) VALUES(30, 'SALES');--NULL값을 하여 LOC에 NULL이 저장됨
INSERT INTO DEPT_COPY VALUES(40, 'OPERATIONS', NULL);
INSERT INTO DEPT_COPY VALUES(50, 'COMPUTION', '');

SELECT * FROM DEPT_COPY;

--실습을 위해 기존 사원테이블의 구조만 복사하여 EMP_COPY 테이블 생성

CREATE TABLE EMP_COPY
AS SELECT ENO, ENAME, JOB, HIREDATE, DNO
FROM EMPLOYEE
WHERE 0 = 1;

SELECT * FROM EMP_COPY;

INSERT INTO EMP_COPY VALUES(7000,'캔디', 'MANAGER', '2021/12/20', 10);
INSERT INTO EMP_COPY VALUES(7010,'톰', 'MANAGER', TO_DATE('2021,06,01','YYYY,MM,DD'), 20);
--SYSDATE : 시스템으로부터 현재 날짜 데이터를 반환하는 함수(주의 : ()없음, -> MYSQL에서는 NOW())
INSERT INTO EMP_COPY VALUES(7020,'제리', 'SALESMAN', SYSDATE, 30);

SELECT * FROM EMP_COPY;

/*
 * 1.2 다른 테이블에서 데이터 복사하기
 * INSERT INTO + 다른 테이블의 서브쿼리 결과 데이터 복사
 * 단, 컬럼수 = 서브쿼리결과의 컬럼수
 * 
 * 예) 서브 쿼리로 다중 행 입력하기
 */
DROP TABLE DEPT_COPY;

CREATE TABLE DEPT_COPY
AS SELECT * FROM DEPARTMENT
WHERE 0 = 1;

SELECT * FROM DEPT_COPY;

INSERT INTO DEPT_COPY --DEPT_COPY의 컬럼 수와 데이터 타입이 DEPARTMENT의 칼럼수와 데이터 타입과 1:1로 같아야 함 
SELECT * FROM DEPARTMENT;

SELECT * FROM DEPT_COPY
ORDER BY DNO;
--DNO가 PK가 아니므로 같은 DNO가 공존

--------------------------------------------------------------------------------------------------------------------

/*
 * 2.UPDATE : 테이블의 데이터 수정
 * WHERE절 생략 : 테이블의 모든 행이 수정됨
 */
UPDATE DEPT_COPY
SET DNAME = 'PROGRAMING'
WHERE DNO = 10;

SELECT * FROM DEPT_COPY
ORDER BY DNO;

--컬럼의 값 여러개를 한번에 수정하기
UPDATE DEPT_COPY
SET DNAME = 'ACCOUNTING', LOC = '서울'
WHERE DNO = 10;

SELECT * FROM DEPT_COPY
ORDER BY DNO;

/*
 * UPDATE문의 SET절에서 서브쿼리를 기술하면
 * 서브쿼리를 수행 한 결과로 내용이 변경됨
 * 즉, 다른 테이블에 저장된 데이터로 해당 컬럼 값 변경 가능
 */

/*
 * 10번 부서의 지역명을 20번 부서의 지역으로 변경
 */

UPDATE DEPT_COPY
SET LOC = (SELECT LOC FROM DEPT_COPY WHERE DNO = 20)
WHERE DNO = 10;

SELECT * FROM DEPT_COPY;

--10번 부서의 부서명과 지역명을 30번 부서의 부서명과 지역명으로 변경

UPDATE DEPT_COPY
SET (DNAME, LOC) = (SELECT DNAME, LOC FROM DEPT_COPY WHERE DNO = 30)
WHERE DNO = 10;

SELECT * FROM DEPT_COPY;

---------------------------------------------------------------------------------------
/*
 * 3. DELETE 문 : 테이블의 데이터 삭제
 * WHERE절 생략 : 모든 데이터 삭제
 */

DELETE 
FROM DEPT_COPY
WHERE DNO = 10;

SELECT * FROM DEPT_COPY;

DELETE FROM DEPT_COPY;

COMMIT;


--실습을 위해 기존 사원테이블의 구조만 복사하여 EMP_COPY 테이블 생성
DROP TABLE EMP_COPY;

CREATE TABLE EMP_COPY
AS SELECT ENO, ENAME, JOB, HIREDATE, DNO
FROM EMPLOYEE
WHERE 0 = 1;

SELECT * FROM EMP_COPY;
SELECT * FROM DEPT_COPY;



/*
 * EMP_COPY 테이블에서 '영업부'에 근무하는 사원 모두 삭제
 */
DROP TABLE DEPT_COPY;
CREATE TABLE DEPT_COPY
AS SELECT * FROM DEPARTMENT;
SELECT * FROM DEPT_COPY;
SELECT * FROM EMP_COPY;

INSERT INTO EMP_COPY
AS SELECT ENO, ENAME, JOB, HIREDATE, DNO

DELETE FROM EMP_COPY
WHERE DNO = (SELECT DNO FROM DEPT_COPY WHERE DNAME = 'SALES');

SELECT * FROM EMP_COPY;

/*
 * 이클립스는 자동 COMMIT되어 있으므로 수동으로 COMMIT되도록 환경설정 후 테스트 하기
 */

/*
 * 4. 트랜잭션 관리
 * 오라클은 트랜잭션 기반으로 '데이터의 일관성을 보장함'
 * (예) 두 계좌
 * '출금계좌의 출금금액'과 '입금계좌의 입금 금액'이 동일해야 함
 * UPDATE				INSERT
 * 반드시 두 작업은 함께 처리 되거나, 함께 취소가 되어야 함
 * 출금처리는 되었는데 입금처리가 되지 않았다면 '데이터 일관성'을 유지 못 함
 */

/*
 * 트랜잭션 처리 요건 : ALL OR NOTHING 반드시 처리되든지 안되든지
 * 데이터의 일관성을 유지, 안정적으로 데이터 복구
 * 
 * COMMIT : '(DML)데이터 추가, 수정, 삭제' 등 실행됨과 동시에 트랜잭션이 진행됨
 * 성공적으로 변경된 내용을 영구 저장위해 반드시 COMMIT
 * 
 * ROLLBACK : 작업을 취소
 * 트랜잭션으로 인한 하나의 묶은 처리가 시작되기 이전 상태로 되돌림
 * 
 */
SELECT * FROM DEPT_COPY;

INSERT INTO DEPT_COPY VALUES(10, 'ACCOUNTING', '뉴욕');
INSERT INTO DEPT_COPY(DNO,LOC, DNAME) VALUES(20, '달라스', 'RESEARCH');




---------------------------------------------------------------------
/*
 * TEST IN 'RUN SQL CMD'
 */
SQL> DELETE FROM DEPT_COPY;

4 rows deleted.

SQL> SELECT * FROM DEPT_COPY;

no rows selected

SQL> ROLLBACK;

Rollback complete.

SQL> SELECT * FROM DEPT_COPY;
----------------------------------------------------------------------
/*
 * 정리 : INSERT, UPDATE, DELETE 후 COMMIT 하기 전 ROLLBACK 하면 모두 취소됨
 * SAVEPOINT : ROLLBACK을 위한 CHECKPOINT
 * 
 * RUN SQL~실행하기
 * (예) 10번 부서만 삭제 후
 */
DELETE FROM DEPT_COPY WHERE DNO = 10;

