/*
 *  북스 6장 테이블 조인하기
 * 1. 조인
 * 1.1 카티시안 곱(= 곱집합) : (구방식 ,)(현방식 cross join) - 조인 조건이 없음
 */
select * from EMPLOY; --컬럼수 : 8, 행수 : 14
select * from DEPARTMENT --컬럼수 : 3, 행수 : 4

select * from EMPLOY, DEPARTMENT;
/*
 * 조인 결과 : 컬럼수(11) = 사원테이블의 컬럼수 + 부서테이블의 컬럼수(3)
 * 				행수(56) = 사원테이블의 행수(14) * 부서테이블의 컬럼수(4)
 */

select eno --eno 컬럼만, 56개 전체 행수
from EMPLOY, DEPARTMENT;

select eno --eno 컬럼만, 56개 전체 행수
from EMPLOY cross join DEPARTMENT;

select * --컬럼수 11, 행수 : eno가 7369인 것만
from EMPLOY, DEPARTMENT
where eno = 7369; --Join 조건 아님

/*
 * 1.2 조인의 유형
 * 오라클 8i 이전 조인 : equi 조인(=등가 조인), non-equi 조인(= 비등가 조인), outer 조인
 * 오라클 9i 이후 조인 : cross join, natural join, join~using, outer join
 * (오라클 9i 부터 ANSI 표준 SQL 조인 : 현재 부부분의 상용 데이터베이스 시스템에서 사용
 * 									다른 DBMS와 호환이 가능하기 때문에 ANSI 표준 조인을 사용할것)
 */

/*
 * 아래 4가지 비교 inner join
 * 해결할 문제 '사원 번호가 7788'인 사원이 소속된 '사원번호, 사원이름, 소속부서번호, 소속부서이름' 얻기
 * 먼저, '사원번호, 사원이름, 소속부서번호, 소속부서이름'의 컬럼들이 어느 테이블에 있는지 부터 파악
 *'사원번호, 사원이름, 소속부서번호' => 사원테이블에 있음
 *'소속부서번호, 소속부서이름' => 부서테이블에 있음
 */

/*
 * '소속부서번호'가 양 테이블에 존재하므로 등가 조인이 가능함
 * 2. equi 조인(=등가조인 = 동일조인) : 동일한 이름과 유형(= 데이터 타입)를 가진 컬럼으로 조인
 * 단, [방법 -1], ~where 과 [방법 -2] join ~ on은 데이터 타입만 같아도 조인이 됨
 */
--------------------------------------------------------------------------------------------------
/*
 * 방법 -1, ~where 동일한 이름과 데이터 유형을 가진 컬럼으로 조인 + 임의의 조건을 지정하거나 조인할 컬럼을 지정
 * 조인결과는 중복된 컬럼 제거 x ->따라서, 테이블에 '별칭 사용'해서 어느 테이블의 컬럼인지 구분해야 함
 */
--------------------------------------------------------------------------------------------------
select
from 테이블1 별칭1, 테이블2 별칭2, --별칭 사용(별ㅊㅇ : 해당 sql명령문 내에서만 유효)
where 조인 조건(주의: 테이블의 별칭 사용 가능)
and 검색 조건
/*
 * 문제점 : 원하지 않는 결과가 나올 수 있다.(이유? and -> or의 우선순위 때문에)
 * 문제점 해결법 : and 검색조건에서 괄호()를 이용하여 우선순위 변경
 * 예)부서 번호로 조인한 후 부서번호가 10이거나 30인 정보 조회
 * where e.dno = d.dno AND d.dno = 10 or d.dno = 30--문제발생(원하지 않는 결과 나옴)
 * where e.dno = d.dno AND (d.dno = 10 or d.dno = 30)--해결법 : 괄호()를 이용하여 우선순위 변경
 */

/*
 * 장점 이 방법은 outer join 하기 편하다
 * (단, 한쪽에만 사용가능, 왼쪽 또는 오른쪽 외부 조인만 가능. 양쪽에 (+)사용 불가
 * 즉, full 외부조인은 불가)
 */

--별칭 사용 안할 경우
select * 
from EMPLOY, DEPARTMENT
where EMPLOY.dno = DEPARTMENT.dno
order by eno;

--별칭 사용 할 경우
select * 
from EMPLOY e, DEPARTMENT d
where e.dno(+) = d.dno
--두 테이블에서 같은 dno끼리 조인(그 결과 부서테이블의 40은 표시안됨
--40부서의 정보를 함께 표시하기 위해서는 (+) 붙여서 외부조인 함)

select * 
from EMPLOY e, DEPARTMENT d
where e.dno(+) = d.dno
/*
 * 외부조인하기 편리하나 full outer join 안됨
 * full outer join은 join~on으로 해결 가능함
 */
--------------------------------------------------------------------------------------------------
/*
 * 방법2, (inner)join ~ on
 */

select 컬럼명1, 컬럼명2
from 테이블1 별칭1,(inner)join 테이블2 별칭2
on 조인 조건 (테이블의 별칭 사용 가능)
where (검색조건)


--결과는 같음, department 테이블에만 표시될 내용이 더 있을 뿐임
select * 
from EMPLOY e right outer join DEPARTMENT d
on e.dno = d.dno;

select * 
from EMPLOY e full outer join DEPARTMENT d
on e.dno = d.dno;

--해결할 문제 '사원 번호가 7788'인 사원이 소속된 '사원번호, 사원이름, 소속부서번호, 소속부서이름' 얻기

select eno, ename, e.dno, dname
from EMPLOY e, DEPARTMENT d
where e.dno = d.dno and eno = '7788';

select eno, ename, e.dno, dname
from EMPLOY e join DEPARTMENT d
on e.dno = d.dno
where eno = '7788';

--------------------------------------------------------------------------------------------------

/*
 * 방법1과 방법 2는 문법적 특징이 동일하다
 * 조인 결과 : 중복된 컬럼 제거를 하지 않음, 테이블의 별칭 필요
 * 컬럼명이 다르고 데이터 타입만 같아도 join 가능
 * 
 * 방법3, 컬럼명이 다르면 cross join 결과가 나옴
 * 방법4
 */
--------------------------------------------------------------------------------------------------
/*
 * natural JOIN
 * oracle sql에서만 지원
 * 조인결과로 중복된 컬럼 제거됨
 * 
 * 자연스럽게 동일한 이름과 데이터유형을 가진 컬럼으로 조인(단 1개만 있을때 사용하는 것을 권장)
 * 동일한 이름과 데이터 유형을 가진 컬럼이 없으면 cross join 됨
 * 동일한 이름과 데이터 유형을 가진 컬럼으로 자연스럽게 조인되나 문제가 발생할 수 있다.
 * 문제가 발생하는 이유? (예)
 * employd의 dno와 department의 dno : 동일한 이름(dno)과 데이터 유형(number(2))
 * 									두 테이블에서 dno는 '부서번호'로 의미도 같다.
 * 				만약, employ의 manager_id(각 사원의 '상사'를 의미하는 번호)가 있고
 * 					department의 manager_id(각 사원의 '부장'을 의미하는번호)가 있고
 * 					둘 다 동일한 이름과 데이터 유형을 가졌지만 manager_id의 의미가 다르면
 * 					natural join 한 후 원하지 않는 결과가 나올 수 있다.
 */

select eno, ename, dno, dname --dno는 중복 제거했으므로 e.dno, d.dno 별칭 사용 안함
from EMPLOY natural join DEPARTMENT
--on e.dno = d.dno
where eno = '7788';

select eno, ename, e.dno, dname
from EMPLOY e join DEPARTMENT d
on e.dno = d.dno
where eno = '7788';


--------------------------------------------------------------------------------------------------
/*
 * join ~ using(반드시 '동일한 데이터 유형인 컬럼명'만 가능) 다르면 오류 발생
 * oracle sql에서만 지원
 * 조인결과, 중복된 칼럼 제거함
 * 
 * natural join은 같은 데이터 유형과 이름을 가진 컬럼을
 * 모두 join하지만
 * using 은 같은 데이터 유형과 이름을 가진 컬럼들 중에서도 특정 컬럼만 따로 선택할 수 있다.
 * 
 * 조인결과는 중복된 칼럼 제거 -> 제거한 결과에 FULL outer join~using(id)하면
 * 하나의 id로 항목 값들이 합쳐져서 표시
 * 동일한 이름과 유형을 가진 칼럼으로 조인(조인 시 1개 이상 사용할 때 편리함 : 가독성이 좋아짐)
 */

select eno, ename, dno, dname
from EMPLOY join DEPARTMENT
using (dno)
where eno = '7788';

/*
 * 만약, manager가 department에 있다고 가정 후 아래 결과 유추
 * 
 */

select eno, ename, dno, dname, employ.manager -- 반드시 테이블 이름이나 별칭 사용하여 구분해야 함
from EMPLOY join DEPARTMENT
using (dno)--dno만 중복제거(manager는 중복제거 안함)
where eno = '7788';

--USING을 사용하면 여러개의 컬럼을 기술할 수 있다.
--※ 이 때 기술된 여러 컬럼의 값은 하나의 값으로 묶어서 판단해야 한다.
--[예] 실습을 위해 테이블 생성 후 데이터 추가
create table emp_test(
eno number primary key,
dno_id number,
loc_id char(2)
);

insert into emp_test values(1, 10, 'A1');
insert into emp_test values(2, 10, 'A2');
insert into emp_test values(3, 20, 'A1');

create table dept_test(
dno_id number primary key,
dname varchar2(20),
loc_id char(2)
);

insert into dept_test values(10, '회계', 'A1');
insert into dept_test values(20, '경영', 'A1');
insert into dept_test values(30, '영업', 'A2');

--using join
select *
from emp_test join dept_test
using(dno_id, loc_id);
/*
 * 10A1, 20A1은 조인결과에 포함되나 10A2나 30A2는 조인결과에 포함되지 않음
 * 이에 따라 두 테이블에 공통요소인 10A1, 20A1만 조인된 출력 결과를 확인할 수 있다.
 */

/*
 * 여러 테이블 간 조인할 경우 natural join과 join~using을 이용한 조인 모두 사용 가능하나
 * 가독성이 높은 join~using을 이용하는 방법을 권한다.
 * 방법3 컬럼명이 다르면 cross join 결과가 나옴
 * 방법4 컬럼명이 다르면 join 안됨(오류 발생)
 */

/*
 * 3. non-equi 조인(=비등가조인) : 조인조건에서 =(같다)연산자 이외 의 연산자를 이용할때
 * 										!= < > >= <= between~and
 * 문제, 사원별로 '사원이름, 급여, 급여등급'출력
 * 1. 사원이름, 급여 => 사원테이블, 급여등급 => 급여등급 테이블
 * 사원테이블 출력
 */
select * from EMPLOY;
select * from salgrade;
/*
 * 두 테이블에는 동일한 이름과 타입을 가진 컬럼이 존재하지 않는다.
 * 따라서 비등가 조인
 * 
 */
select ename, salary, grade
from EMPLOY join SALGRADE --별칭 사용 안함(중복되는 컬럼 자체가 없음)
on salary between losal and hisal
order by grade;

select ename, dno, dname, salary
from EMPLOY join department
using (dno);



select ename, salary, grade
from EMPLOY, SALGRADE --별칭 사용 안함(중복되는 컬럼 자체가 없음)
where losal <= salary and salary <= hisal
order by grade;

/*
 * 문제 사원이름, 급여, 급여등급 출력 + 조건추가 : 급여가 1000미만이거나 2000초과
 */


select ename, salary, grade
from employ, salgrade
where salary between losal and hisal
and (salary > 2000 or salary < 1000)
order by grade;

/*
 * 문제, 3개의 테이블 조인하기
 * 사원이름, 소속된 부서번호, 소속된 부서명, 급여, 급여등급 조회
 */

select e.ename, e.dno, dname, salary, grade
from EMPLOY e, DEPARTMENT d, salgrade
where salary between losal and hisal
and e.dno = d.dno;


select ename, dno, dname, salary, grade
from 
(select e.ename, e.dno, dname, salary
from EMPLOY e, DEPARTMENT d
where e.dno = d.dno),
salgrade
where salary between losal and hisal

/*
 * ----------------------------------------------------------------------------------------------------------
 * self join : 하나의 테이블에 있는 컬럼끼리 연결해야 하는 조인이 필요한 경우
 */

select * from EMPLOY;

--사원 이름과 직속 상관 이름 조회
select e1.ename, e2.ename as "직속상관"
from EMPLOY e1 join EMPLOY e2
on e1.manager = e2.eno
order by 2;
--king의 직속상관은 null 이므로 등가조인에서 제외됨

/*
 * 문제 + 조건추가 : SCOTT란 사원의 매니저이름(직속상관)을 검색
 */

select e1.ename, e2.ename as "직속상관"
from EMPLOY e1 join EMPLOY e2
on e1.manager = e2.eno
where e1.ename = 'SCOTT';

/*
 * outer join (=외부조인)
 * equi join (=등가조인 =동일조인)의 조인조건에서 기술한 컬럼에 대해 두 테이블 중
 * 어느 한쪽 컬럼이라도 null이 저장되어 있으면 '=' 연산자의 비교 결과가 거짓이 된다.
 * 그래서 null값을 가진 행은 조인결과로 얻어지지 않음
 * (예) 바로위의 문제, king의 직속상관은 null이므로 등가조인에서 제외됨
 */

select e.ename || '의 직속상관은' || m.ename
from EMPLOY e join EMPLOY m
on e.manager = m.eno;--king의 manager는 null이라 등가조인에서 제외됨

--결과가 안나오는 이유? 처음부터 오인한 결과 테이블에 이름이 king이 없으니깐
select e.ename || '의 직속상관은' || m.ename
from EMPLOY e join EMPLOY m
on e.manager = m.eno
where ename = 'KING';

select e.ename || '의 직속상관은' || m.ename
from EMPLOY e join EMPLOY m
on e.manager = m.eno
where m.ename = 'KING';--직속상관 이름이 king인 사원

/*
 * 위 방법으로는 null값을 가진 사원 king의 정보를 표현할 수 없다.
 * 따라서 외부조인으로 해결
 * 한쪽만 (+) 붙일 수 있다(LEFT/RIGHT), 즉 full 불가능
 */

select e.ename || '의 직속상관은' || NVL(m.ename, '없다.')
from EMPLOY e, EMPLOY m
where e.manager = m.eno(+);

select e.ename || '의 직속상관은' || NVL(m.ename, '없다.')
from EMPLOY e left outer join EMPLOY m
on e.manager = m.eno
where e.ename = 'KING';




