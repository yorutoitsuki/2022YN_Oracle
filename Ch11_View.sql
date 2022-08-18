/*
 * 북스 11장, 뷰
 * 1. 뷰? 하나 이상의 테이블이나 다른 뷰를 이용하여 생성되는 '가상테이블'
 * 즉 실질적으로 데이터를 저장하지 않고 데이터 사전에 뷰를 정의할 때 기술한 '쿼리문만 저장'
 * 
 * 뷰를 정의하기 위해 사용된 테이블 : 기본테이블
 * 뷰는 별도의 기억 공간이 존재하지 않기 때문에 뷰에 대한 수정 결과는
 * 뷰를 정의한 기본 테이블에 적용
 * 
 * 반대로 기본테이블의 데이터가 변경되면 뷰에 반영
 * 
 * 뷰를 정의한 기본테이블의 무결성 제약조건 역시 상속
 * 뷰의 정의 조회하려면 : user_views 데이터 사전
 * 
 * 뷰는 복잡한 쿼리르 단순화 시킬 수 있다.
 * 뷰는 사용자에게 필요한 정보만 접근하도록 접근을 제한할 수 있다.
 * 
 * 1.1 뷰 생성
 * 대괄호([])의 항목은 필요하지 않을 경우 생략이 가능하다
 */

create [or replace][FORCE|NOFORCE(기본값)]
view View_Name[(column_Name 1, column_Name 2, ...)](: 기본 테이블의 컬럼명과 다르게 지정할 경우, 기본테이블과 순서와 개수를 맞춰야함)
AS Sub_Querry
[with check option [constraint 제약조건명]]
[with READ ONLY];--서브쿼리select문만 사용가능, DML(=데이터 조작어) 불가


--or replace : 해당 구문을 사용하면 뷰를 수정할 때 drop없이 수정이 가능하다

--FORCE : 뷰를 생성할 때 쿼리문의 테이블, 컬럼, 함수 등이 존재하지 않아도 생성이 가능하다.
--		  즉, 기본 테이블의 존재유무에 상관 없이 뷰 생성

--NOFORCE : 뷰를 생성할 때 쿼리문의 테이블, 컬럼, 함수 등이 존재하지 않으면 생성이 불가능하다.
--		  	즉, 기본 테이블이 존재하는 경우에만 뷰 생성 가능

--with check option : where 절의 조건에 해당하는 데이터만 저장(insert), 변경(update)가능

--with READ ONLY : select문만 사용가능, DML(=데이터 조작어:변경 - insert,update,delete)불가

/*
 * 1.2 뷰의 종류
 * [1] 단순 뷰 : 하나의 기본테이블로 생성한 뷰
 * 				DML 명령문의 처리 결과는 기본테이블에 반영
 * 				(insert, delete, update)
 * 				단순 뷰는 단일 테이블에 필요한 컬럼을 나열한 것으로
 * 				join, 함수, group by, union 등을 사용하지 않는다.
 * 				단순 뷰는 select + DML을 자유롭게 사용가능하다
 * [2] 복합 뷰 : 2개 이상의 기본테이블로 생성한 뷰
 * 				distinct, 그룹함수, rownum을 포함할 수 없다.
 * 				복합 뷰는 join, 함수, group by, union 등을 사용하여 뷰를 생성한다.
 * 				함수 등을 사용할 경우 '컬럼 별칭'은 꼭 부여해야 한다. (예:AS hiredate)
 * 				복합 뷰는 select는 사용 가능하지만 insert, update, delete는 상황에 따라서
 * 				불가능 할 가능성이 있음
 * 실습을 위해 새로운 테이블 2개 생성
 */

CREATE TABLE EMP11
AS SELECT * FROM EMPLOYEE;

CREATE TABLE DEPT11
AS SELECT * FROM DEPARTMENT;

CREATE OR REPLACE VIEW V_EMP_JOB(사원번호, 사원명, 부서번호, 담당엄무)
AS SELECT ENO, ENAME, DNO, JOB FROM EMP11
WHERE JOB LIKE 'SALESMAN';

SELECT * FROM V_EMP_JOB;

DROP VIEW V_EMP_JOB;

CREATE OR REPLACE VIEW V_EMP_JOB2
AS SELECT ENO, ENAME, DNO, JOB FROM EMP11
WHERE JOB LIKE 'SALESMAN';

SELECT * FROM V_EMP_JOB2;

CREATE OR REPLACE VIEW V_EMP_JOB2
AS SELECT ENO, ENAME, DNO, JOB FROM EMP11
WHERE JOB LIKE 'MANAGER';


--[2] 복합 뷰 (예)
create or replace view V_EMP_DEPT_COMPLEX
AS
SELECT *
FROM EMP11 NATURAL JOIN DEPT11
ORDER BY DNO ASC;

SELECT * FROM V_EMP_DEPT_COMPLEX;

CREATE OR REPLACE VIEW V_EMP_DEPT_COMPLEX
AS
SELECT *
FROM EMP11 RIGHT OUTER JOIN DEPT11
USING (DNO)
ORDER BY DNO ASC;

SELECT * FROM V_EMP_DEPT_COMPLEX;

/*
 * 1.3 뷰의 필요성
 * 뷰를 사용하는 이유는 '보안'과 '사용의 편의성' 때문
 * [1] 보안 : 전체 데이터가 아닌 '일부만 접근' 하도록 뷰를 정의 하면
 * 			일반 사용자에게 해당 뷰만 접근 가능하도록 허용하여
 * 			중요한 데이터가 외부게 공개되는 것을 막을 수 있음
 * 			(PRIVATE, GETTER 와 비슷함)
 * (예) 사원 테이블의 급여나 커미션은 개인적인 정보이므로 다른 사원들의 접근 제한해야함
 * 
 * 즉, 뷰는 복잡한 쿼리를 단순화 시킬 수 있다.
 * 뷰는 사용자에게 필요한 정보만 접근하도록 접근을 제한할 수 있다.
 * 
 * 예 : 사언 테이블에서 '급여나 커미션을 제외'한 나머지 컬럼으로 구성된 뷰 생성
 * 
 */
SELECT * FROM EMP11;

CREATE OR REPLACE VIEW V_EMP_SAMPLE
AS
SELECT ENO, ENAME, JOB, HIREDATE, MANAGER, DNO
FROM EMP11;

SELECT * FROM V_EMP_SAMPLE;

/*
 * [2] 사용의 편의성 : '정보 접근을 편리' 하게 하기 위해 '뷰를 통해'
 * 					사용자에게 '필요한 정보만 선택적으로 제공'
 * '사원이 속한 부서에 대한 정보'를 함께 보려면 사원테이블과 부서테이블을 조인해야함
 * 하지만 이를 뷰로 정의해두면 '뷰를 마치 테이블처럼 사용'하여 원하는 정보를 편리하게 얻을 수 있음
 */

CREATE OR REPLACE VIEW V_EMP_DEPT_COMPLEX2
AS
SELECT ENO, ENAME,DNO,DNAME,LOC
FROM EMP11 NATURAL JOIN DEPT11
ORDER BY DNO ASC;

SELECT * FROM V_EMP_DEPT_COMPLEX2;
--뷰를 통해 복잡한 조인문을 사용하지 않ㄱ ㅗ정보를 편리하게 얻을 수 있음

/*
 * 1.4 뷰의 처리 과정
 */

SELECT VIEW_NAME, TEXT FROM USER_VIEWS;

/*
 * USER_VIEWS 데이터 사전에 사용자가 생성한 '모든 뷰에 대한 정의'를 저장
 * 뷰는 SELECT 문에 이름을 붙인 것
 * [1] 뷰의 질의를 하면 오라클 서버는 USER_VIEWS에서 뷰를 찾아 서브쿼리문을 실행
 * [2] '서브쿼리문'은 기본테이블을 통해 실행됨
 * 
 * 뷰는 SELECT 문으로 기본테이블을 조회하고
 * DML(INSERT, UPDATE, DELETE)문으로 기본테이블 변경 가능
 * (단, 그룹함수를 가상컬럼으로 갖는 뷰는 DML 사용 못함)
 */
SELECT * FROM EMP11;
SELECT * FROM V_EMP_JOB;

INSERT INTO V_EMP_JOB VALUES(8000,'HONG',30,'SALESMAN');
/*
 * 성공
 * 주의 : 뷰 정의에 포함되지 않는 컬럼 중에 '기본 테이블의 컬럼이 NOT NULL 제약조건이 지정되어 있는 경우'
 * INSERT문 사용이 불가능
 */
SELECT * FROM EMP11;--기본 테이블에 INSERT됨
INSERT INTO V_EMP_JOB VALUES(9000,'G.LEE',40,'MANAGER');
DELETE FROM V_EMP_JOB WHERE 사원명 = 'G.LEE';

SELECT * FROM V_EMP_JOB;

/*
 * 1.5 다양한 뷰
 * 함수 사용하여 뷰 생성 가능
 * 주의 : 그룹함수는 물리적인 컬럼이 존재하지 않고 결과를 가상컬럼처럼 사용함
 * 			가상컬럼은 기본테이블에서 컬럼명을 상속받을 수 없기 때문에 반드시 '별칭 사용'
 */

CREATE OR REPLACE VIEW V_EMP_SALARY
AS
SELECT DNO, SUM(SALARY) AS "HAP", AVG(SALARY) AS "AVG"
FROM EMP11
GROUP BY DNO;
--ORA-00998: must name this expression with a column alias
SELECT * FROM V_EMP_SALARY;

--단, 그룹함수를 가상컬럼으로 갖는 뷰는 DML 못함
/*
 * 단순 뷰에서 DML 명령어 사용이 불가능한 이유
 * 1.뷰 정의에 포함되지 않은 컬럼 중에 기본테이블의 컬럼이 NOT NULL 조건이 지정되어 있는 경우 INSERT문 사용 불가
 * 왜냐하면 뷰에 대한 INSERT문은 기본테이블의 뷰 정의에 포함되지 않은 컬럼에 NULL값을 입력하는 형태가 되기 때문이이다
 * 
 * 2.SALARY*12와 같이 산술 표현식으로 정의된 가상 컬럼이 뷰에 정의되면 INSERT나 UPDATE 불가능
 * 
 * 3.DISTINCT를 포함한 경우에도 DML 명령 사용이 불가능 하다.
 * 
 * 4. 그룹 함수나 그룹BY 절을 포함한 경우 DML 명령 사용이 불가능함
 */

/*
 * 1.6 뷰 제거
 * 뷰를 제거한다는 것은   USER_VIEWS 데이터 사전에 뷰이의 정의 제거
 */

DROP VIEW V_EMP_SALARY;

SELECT * FROM USER_VIEWS
WHERE VIEW_NAME IN('V_EMP_SALARY');

/*
 * -----------------------------------------------------------------------------------------
 */

/*
 * 다양한 뷰 옵션
 */

1.1 뷰 생성
 * 대괄호([])의 항목은 필요하지 않을 경우 생략이 가능하다
 */

create [or replace][FORCE|NOFORCE(기본값)]
view View_Name[(column_Name 1, column_Name 2, ...)](: 기본 테이블의 컬럼명과 다르게 지정할 경우, 기본테이블과 순서와 개수를 맞춰야함)
AS Sub_Querry
[with check option [constraint 제약조건명]]
[with READ ONLY];--서브쿼리select문만 사용가능, DML(=데이터 조작어) 불가


--or replace : 해당 구문을 사용하면 뷰를 수정할 때 drop없이 수정이 가능하다

--FORCE : 뷰를 생성할 때 쿼리문의 테이블, 컬럼, 함수 등이 존재하지 않아도 생성이 가능하다.
--		  즉, 기본 테이블의 존재유무에 상관 없이 뷰 생성

--NOFORCE : 뷰를 생성할 때 쿼리문의 테이블, 컬럼, 함수 등이 존재하지 않으면 생성이 불가능하다.
--		  	즉, 기본 테이블이 존재하는 경우에만 뷰 생성 가능

--with check option : where 절의 조건에 해당하는 데이터만 저장(insert), 변경(update)가능

--with READ ONLY : select문만 사용가능, DML(=데이터 조작어:변경 - insert,update,delete)불가

/*
 * 2.1 OR REPLACE
 * 
 * 2.2 FORCE
 * FORCE 옵션을 사용하면 쿼리문의 테이블, 컬럼, 함수 등이 존재하지 않을 경우(즉, 기본테이블이 존재 x)
 * 오류 발생없이 '뷰는 생성되지만 INVALID'상태 이기 때문에 휴븐 동작하지 않는다
 * (즉, USER_VIEWS 데이터 사전에는 등록되어 있지만 기본테이블이 존재하지 않으므로 실행안됨)
 * 오류가 없으면 정상적으로 뷰가 새성된다
 */

CREATE OR REPLACE FORCE VIEW V_EMP_NOTABLE
AS
SELECT ENO, ENAME, DON, JON
FROM EMP_NOTABLE
WHERE JOIB LIKE 'MANAGER';

SELECT VIEW_NAME, TEXT FROM USER_VIEWS
WHERE VIEW_NAME IN ('V_EMP_NOTABLE');

SELECT * FROM V_EMP_NOTABLE;
--USER_VIEWS 데이터 사전에는 등록되어 있지만 기본테이블이 존재하지 않으므로 실행안됨.

/*
 * 2.3 WITH CHECK OPTION
 * WHERE 절의 조건에 해당하는 데이터만 저장(INSERT), 변경(UPDATE)이 가능하다
 * 즉, 해당 뷰를 통해서 볼 수 있는 범위 내에서만 INSERT 또는 UPDATE 가능함
 */

--예)담당 업무가 'MANAGER'인 사원들을 조회하는 뷰 생성
CREATE OR REPLACE VIEW V_EMP_JOB_NOCHK
AS
SELECT ENO, ENAME, DNO, JOB
FROM EMP11
WHERE JOB LIKE 'MANAGER';

SELECT * FROM V_EMP_JOB_NOCHK;

INSERT INTO V_EMP_JOB_NOCHK VALUES(9100, 'KANG', 30, 'SALESMAN');
SELECT * FROM EMP11;--기본 테이블에는 추가 되었지만
SELECT * FROM V_EMP_JOB_NOCHK;--뷰에는 없음 => 혼돈 발생
/*
 * 따라서 미연에 방지 하기 위해
 * WITH CHECK OPTION 사용하여 기본 테이블에도 추가될 수 없도록 방지
 * 즉, WITH CHECK OPTION으로 뷰를 생성할 때 조건제시에 사용된 컬럼값을 변경하지 못하도록 함
 */

CREATE OR REPLACE VIEW V_EMP_JOB_NOCHK
AS
SELECT ENO, ENAME, DNO, JOB
FROM EMP11
WHERE JOB LIKE 'MANAGER' WITH CHECK OPTION; 

INSERT INTO V_EMP_JOB_NOCHK VALUES(9500, 'KIM', 30, 'SALESMAN');--실패, SALESMAN이라서, 기본테이블에도 추가 안됨
/*
 * WITH CHECK OPTION : 조건제시를 위해 사용한 컬럼값이 아닌 값에 대해서는 뷰를 통해서 추가/변경하지 못하도록 막음
 */
INSERT INTO V_EMP_JOB_NOCHK VALUES(9500, 'KIM', 30, 'MANAGER');--성공, 기본테이블에도 추가
SELECT * FROM EMP11;
SELECT * FROM V_EMP_JOB_NOCHK;

/*
 * 2.4 WITH READ ONLY
 * SELECT문만 사용가능, DML불가
 */
CREATE OR REPLACE VIEW V_EMP_JOB_READONLY
AS
SELECT ENO, ENAME, DNO, JOB
FROM EMP11
WHERE JOB LIKE 'MANAGER' WITH READ ONLY; 

INSERT INTO V_EMP_JOB_READONLY VALUES(9500, 'KIM', 30, 'MANAGER');


--Q1
CREATE VIEW V_EM_DNO
AS
SELECT ENO, ENAME, DNO
FROM EMPLOYEE
WHERE DNO = 20;
--Q2
CREATE OR REPLACE VIEW V_EM_DNO
AS
SELECT ENO, ENAME, DNO, SALARY
FROM EMPLOYEE
WHERE DNO = 20;
--Q3
DROP VIEW V_EM_DNO;











































