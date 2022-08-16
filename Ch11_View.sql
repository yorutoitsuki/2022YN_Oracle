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
 * 
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








































