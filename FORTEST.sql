--[SQL 활용] 정리

--<DDL:데이터 정의어>
--1. 테이블 생성
[테이블명 test]
----------------------------------------
필드(=컬럼명) Type           null      key   
----------------------------------------
id         varchar2(20)   no           
password   varchar2(30)   no            
name       varchar2(25)   no            
성별        char(2)        yes           
birth      date           yes          
age        number(4)      yes       
----------------------------------------

drop table test;

CREATE TABLE TEST(
ID VARCHAR2(20) NOT NULL,
password varchar2(20) not null,
NAME VARCHAR2(25) NOT NULL,
성별 CHAR(2),
BIRTH DATE,
AGE NUMBER(4));


--2. 컬럼 이름(=열 이름) 변경 : 성별 -> gender 

ALTER TABLE TEST
RENAME COLUMN 성별 TO GENDER;

--3. 컬럼 이름(=열 이름) 추가:address varchar2(60) 추가

ALTER TABLE TEST
ADD ADDRESS VARCHAR2(60);

--4. birth 열 제거

ALTER TABLE TEST
DROP COLUMN BIRTH;

/*
 * [컬럼의 길이 변경(줄일 때) 주의사항]
 * 컬럼의 길이를 줄일 경우 이미 insert된 해당 컬럼의 값 중 변경할 길이보다 큰 값이 있으면 오류가 발생한다.
 * ORA-01441: cannot decrease column length because some value is too big 
 * 
 * 이럴 때는 해당 컬럼의 길이를 조회하여 변경할 길이보다 큰 값이 있는지 확인한 후 값을 변경해야 한다.
 * 
 * select id, age -- select *
 * from test
 * where length(age) > 3;
 */

--5. 열 수정 : 아직 insert한 row(=레코드)가 없으므로 컬럼 크기를 줄일 수 있다.
--age : number(3), null:NO, Default값:0

ALTER TABLE TEST
MODIFY AGE NUMBER(3) DEFAULT 0 NOT NULL;

--(2) GENDER : CHAR(1), DEFAULT : 'M'
ALTER TABLE TEST
MODIFY GENDER CHAR(1) DEFAULT 'M';

--6. id에 '기본키 제약조건' 추가

ALTER TABLE TEST
MODIFY ID PRIMARY KEY;

--7. 테이블 구조 확인

DESC TEST;

--8. 테이블의 제약조건 확인(테이블명, 제약조건명, 제약조건타입)

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN('TEST');

-------------------------------------------------------------------------------------------------------------------

--<DML:데이터 조작어(insert, update, delete) -> TCL:트랜잭션 처리어(commit, rollback, savepoint)
--9. insert : 데이터 입력

--10. update : '광역시' -> '시'로 데이터 변경

--10번 변경문제. update : '광역시' -> '시'로 데이터 변경
--(단, 서브쿼리 사용하여 해결하기)

--11. delete : 나이가 20미만인 데이터 삭제
--미만 <20, 이하 <=20, 초과 >20, 이상>=20

--12. 데이터 입력한 후 영구저장(트랜잭션 완료) : RUN SQL~에서 실행
----->결과 확인 : 이클립스에서 결과 확인
--삽입할 데이터 : jun5 *5555 전상호  M 28 NULL

--13. 데이터 삭제한 후 이전 상태로 복귀(트랜잭션 취소) : RUN SQL~에서 실행
----->결과 확인 : 이클립스에서 결과 확인

--데이터 사전(8장-6. 데이터 사전 참조)
--14. 사용자가 소유한 테이블 이름 조회

--15. 테이블 구조 확인
----SQL PLUS명령어는 이클립스에서 실행안됨(RUN SQL~에서 실행)

--16. index 생성(index 명 : name_idx)
--인덱스:검색 속도를 향상시키기 위해 사용
--     사용자의 필요에 의해서 직접 생성할 수도 있지만
--     데이터 무결성을 확인하기 위해서 수시로 데이터를 검색하는 용도로 사용되는 
--     '기본키나 유일키는 인덱스 자동 생성'


--17. view 생성(뷰 이름 : viewTest)
--뷰? 하나 이상의 테이블이나 다른 뷰를 이용하여 생성되는 가상테이블
--뷰는 복잡한 쿼리를 단순화 시킬수 있다.
--뷰는 사용자에게 필요한 정보만 접근하도록 접근을 제한할 수 있다.

--------------------------------------------------------------------------------------------
--18. test2 테이블 생성
[테이블명 test2]
-------------------------------------
필드       Type           null   key 
-------------------------------------
id        varchar2(20)   no     PK  
major     varchar2(20)   yes  
-------------------------------------

--test, test2 EQUI 조인(=등등조인=동일조인) : 데이터 타입이 같아야 함

/*
 * ▶ NATURAL 조인과 USING 절을 이용한 조인의 차이점
 * 조인되는 테이블간 공통된 컬럼이 2개 이상이라면 둘의 결과는 완전히 다를 수 있다.
 * 
 * select *
 * from employee 
 * join department USING(dno)--조인한 결과와
 * join test3 USING(manager_id);--조인.(manager_id의 이름, 타입, 의미는 같다.)
 * 
 * select *
 * from employee 
 * NATURAL join department;--자동으로 dno로 조인한 결과와
 * NATURAL join test3;--조인.
 * --(manager_id뿐만 아니라 '같은 이름과 같은 타입이 하나 더 존재'한다면 2개의 공통된 컬럼으로 조인이 되어)
 * -->둘의 결과는 완전히 다를 수 있다.
 * 
 * ※ 따라서, 같은 이름, 타입, 의미의 컬럼이 하나이면  NATURAL 조인을 사용하고
 * 2개 이상이면'가독성이 좋은 USING 절'을 이용한 방법을 권한다.
 */

--------------------------------------[18. join 간단 정리 끝]--------------------------------------

--19. 서브쿼리를 이용하여 major가 '컴퓨터 공학'인 사람의 이름 조회

--20. 집합연산자 : 각 쿼리의 '컬럼 개수'와 '데이터 타입'이 일치
--20.1 UNION : 각 쿼리의 결과의 합을 반환하는 '합집합'(중복제거)
--             쿼리의 결과를 합친 후 '중복을 제거'하는 작업이 추가로 적용되므로 쿼리의 속도 및 부하가 발생한다.
--             중복을 제거할 필요가 없으면 UNION ALL을 사용하는 것이 합리적이다.


--20.2 INTERSECT : 각 쿼리의 결과 중 '같은 결과만 반환'하는 '교집합'


--20.3 MINUS : 앞 쿼리의 결과 - 뒤 쿼리의 결과  ('차집합')(중복제거)
--             앞 쿼리의 결과 - 앞뒤 교집합의 결과

----------------------------------------------------------------------------------------------------

--UNION : 특징들을 예로 설명
--(예1) job별로 급여의 총합과 커미션의 총합 구하기


--(예1 변경-2) 모든 별칭 생략하면 '1번째 컬럼 자체'가 '컬럼명'으로 표시됨

--(예2) 사원 테이블과 부서 테이블을 결합하여 부서번호와 부서이름을 조회(중복 제거)

--[문제] 사원 테이블과 부서 테이블에 '동시에 없는 부서번호, 부서이름' 조회
--(employee의 dno가 department의 dno를 references를 아는 전제 하에서
--즉,'employee의 dno가 참조하는 dno는 반드시 department의 dno로 존재한다'는 사실을 아는 전제 하에서 문제 해결함) 

---------------------------------------------------------------------------------------------------                                         

-- UNION 사용 : 서로 다른 테이블을 사용한 쿼리의 결과가 합쳐서 조회
--            select문의 컬럼의 개수와 각 컬럼의 데이터 타입만 일치하면 된다.   







