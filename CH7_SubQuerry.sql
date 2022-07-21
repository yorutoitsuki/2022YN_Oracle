/*
 * 문제 SCOTT보다 급여를 많이 받는 사원의 사원명과 급여조회
 */

select ename, salary
from EMPLOYEE
where 
(select salary 
from EMPLOYEE
where ename = 'SCOTT') < salary;

/*
 * 단일 행 서브쿼리 : 내부서브 쿼리문의 결과가 1개의 행일때
 * 다중 행 서브쿼리 : 내부서크 쿼리문의 결과개 1개 이상의 행일때
 * 문제 scott과 동일한 부서에서 근무하는 사원이름, 부서번호 조회
 */

select ename, dno
from EMPLOYEE
where(select dno from EMPLOYEE where ename = 'SCOTT') = dno
and ename != 'SCOTT';

select ename, dno
from EMPLOYEE
where dno in (select dno from EMPLOYEE where ename = 'SCOTT');

/*
 * 회사 전체에서 최소 급여를 받는 사원의 이름, 담당업무, 급여조회
 */

select ename, job, salary
from EMPLOYEE
where salary in (select MIN(salary) from EMPLOYEE);

/*
 * 다중행 서브쿼리
 * IN 연산자 : 메인쿼리의 비교조건에서 서브쿼리의 출력결과가 '하나라도 일치하면'
 * 메인 쿼리의 where절이 true
 * 단일 또는 다중행 서브쿼리 둘다 사용가능함
 */

/*
 * 부서별 최소 급여를 받는 사원의 부서번호, 사원번호, 이름, 최소 급여
 */

select dno, eno, ename, salary
from EMPLOYEE
where salary in (select min(salary) from EMPLOYEE group by dno)
order by dno;

/*
 * 위 쿼리문 변경
 */

select dno, eno, ename, salary
from EMPLOYEE
where (dno, salary) in (select dno, min(salary) from EMPLOYEE group by dno)
order by dno;

/*
 * 
 */

select dno, min(salary)
from EMPLOYEE
group by dno;

--join 1
select e1.dno, e1.eno, e1.ename, salary
from EMPLOYEE e1, 
	(select dno, min(salary) as "minSalary"
	from EMPLOYEE
	group by dno) e2
where e1.dno = e2.dno
--and salary = min(salary) --검색조건 오류, min함수에 의해서
and e1.salary = "minSalary";

--join 2
select e1.dno, e1.eno, e1.ename, salary
from EMPLOYEE e1 join
	(select dno, min(salary) as "minSalary"
	from EMPLOYEE
	group by dno) e2
on e1.dno = e2.dno
where e1.salary = "minSalary";

--join3
select dno, eno, ename, salary
from EMPLOYEE e1 natural join
	(select dno, min(salary) as "minSalary"
	from EMPLOYEE
	group by dno) e2
where e1.salary = "minSalary";

select dno, eno, ename, salary
from EMPLOYEE e1 join
	(select dno, min(salary) as "minSalary"
	from EMPLOYEE
	group by dno) e2
using (dno)
where e1.salary = "minSalary";

/*
 * ------------------------------------------------------------------
 * 방법1 의 쿼리에서 min(salary)도 출력 할려면?
 */
select dno, eno, ename, salary, min(salary)
from EMPLOYEE
group by dno, eno, ename, salary
order by dno;

select dno, eno, ename, salary, min(salary) as "Minimum"
from EMPLOYEE
where salary in(950, 800, 1300)
group by dno, eno, ename, salary
order by dno;

select dno, eno, ename, salary, min(salary) as "Minimum"
from EMPLOYEE
where salary in(select min(salary) from EMPLOYEE group by dno)
group by dno, eno, ename, salary
order by dno;

/*
 * ANY연산자 : 서브쿼리가 반환하는 각각의 값과 비교
 * where 컬럼명 = any(서브쿼리의 결과1, 결과2....) =>결과들 중 아무거나와 같다
 * where 컬럼명 in (서브쿼리의 결과1, 결과2....) =>결과들 중 아무거나와 같다
 * 
 * 정리 : A조건 or B 조건
 * 합집합 : 각각 만족하는 조건의 결과를 다 합침
 * 
 * where 컬럼명 < any(서브쿼리의 결과1, 결과2....) =>결과들 중 최대값 보다 작다
 * where 컬럼명 > any(서브쿼리의 결과1, 결과2....) =>결과들 중 최솟값 보다 크다
 */

select dno, eno, ename, salary
from EMPLOYEE
where (dno, salary) in (select dno, min(salary) from EMPLOYEE group by dno)
order by dno;

select dno, eno, ename, salary
from EMPLOYEE
where (salary) =any (select min(salary) from EMPLOYEE group by dno)
order by dno;

/*
 * 정리 where (dno, salary) =any (select dno, min(salary) from EMPLOYEE group by dno)
 * 							IN (select dno, min(salary) from EMPLOYEE group by dno)
 * 
 * 정리 :	 WHERE salary != any(1300, 800, 950)
 * 		 WHERE salary <> any(1300, 800, 950)
 * 		 WHERE salary ^= any(1300, 800, 950)
 * 		 WHERE salary not in(1300, 800, 950)
 * 
 * 정리 :	 where salary < any(1300, 800, 950) 서브쿼리 결과들 중 최대값(1300)보다 작으면 true
 * 		 where salary > any(1300, 800, 950) 서브쿼리 결과들 중 최솟값(800)보다 크면 true
 */

select eno, ename, salary
from EMPLOYEE
where salary < any(1300, 800, 950)
order by 1;

--salary < 1300의 범위가 나머지 범위를 다 포함

select eno, ename, salary
from EMPLOYEE
where salary > any(1300, 800, 950)
order by 1;

--salary > 800의 범위가 나머지 범위를 다 포함
/*
 * 직급이 salesman이 아니면서 급여가 임의의 salesman보다 낮은 사원의 정보(이름, 직급, 급여)출력
 */
select ename, job, salary
from EMPLOYEE
where job != 'SALESMAN'
and salary < any(select distinct salary from EMPLOYEE where job = 'SALESMAN')
order by salary;

select ename, job, salary
from EMPLOYEE
where job != 'SALESMAN'
and salary < (select max(salary) from EMPLOYEE where job = 'SALESMAN')
order by salary;

--------------------------------------------------------------------------------------------------------------
/*
 * ALL 연산자 : 서브 쿼리에서 반환되는 모든 값을 비교
 * 정리 : A조건 and B조건
 * 교집합 : 모든 조건을 동시에 만족하는 것
 * 
 * 정리 :	 where salary < any(1300, 800, 950) 서브쿼리 결과들 중 최대값(1300)보다 작으면 true
 * 		 where salary > any(1300, 800, 950) 서브쿼리 결과들 중 최솟값(800)보다 크면 true
 * 
 * 정리 :	 where salary < ALL(1300, 800, 950) 서브쿼리 결과들 중 최솟값(800)보다 작으면 true
 * 		 where salary > ALL(1300, 800, 950) 서브쿼리 결과들 중 최댓값(1300)보다 크면 true
 */

/*
 * 직급이 salesman이 아니면서 급여가 모든 salesman보다 낮은 사원의 정보(이름, 직급, 급여)출력
 */
select ename, job, salary
from EMPLOYEE
where job != 'SALESMAN'
and salary < ALL(select distinct salary from EMPLOYEE where job = 'SALESMAN')
order by salary;

select ename, job, salary
from EMPLOYEE
where job != 'SALESMAN'
and salary < (select min(salary) from EMPLOYEE where job = 'SALESMAN')
order by salary;
----------------------------------------
/*
 * 4) exists 연산자
 */
select 
from
where exists ()

/*
 * 서브 쿼리에서 구해진 데이터가 1개라도 존재하면 true -> 메인 쿼리 실행
 * 						1개라도 존재하지 않으면 false -> 메인 쿼리 실행X
 */

select 
from
where not exists ()

/*
 * 서브 쿼리에서 구해진 데이터가 1개라도 존재하면 true -> 메인 쿼리 실행
 * 						1개라도 존재하지 않으면 false -> 메인 쿼리 실행X
 */
/*
 * 문제 사원테이블에서 직업이 'PRESIDENT'가 있으면 모든 사원이름을 출력, 없으면 출력 안함
 */
select ENAME
from EMPLOYEE
where exists(select job from EMPLOYEE where job = 'PRESIDENT');

/*
 * 위 문제를 테스트 하기 위해 지업이 president인 사원 삭제
 */

delete from EMPLOYEE
where job = 'PRESIDENT';

INSERT INTO EMPLOYEE VALUES
(7839,'KING','PRESIDENT', NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);

select ENAME
from EMPLOYEE
where job = 'SALESMAN' AND exists(select job from EMPLOYEE where job = 'PRESIDENT');


--조건에 OR
select ENAME
from EMPLOYEE
where job = 'SALESMAN' OR exists(select job from EMPLOYEE where job = 'PRESIDENT');

/*
 * 과제1 사원테이블과 부서테이블에서 동시에 없는 부서번호, 부서이름 조회
 * EMPLOYEE의 dno가 department의 dno를 references를 아는 전제 하에서
 * 즉, EMPLOYEE의 dno가 참조하는 dno는 반드시 department의 dno로 존재한다는
 * 사실을 아는 전제하에서 문제 해결함
 */

select dno, dname
from department
where dno not in (select distinct dno from EMPLOYEE);

select dno, dname
from department
where dno not in (select distinct dno from EMPLOYEE join department using (dno));

select d.dno, dname
from EMPLOYEE e right outer join department d
on e.dno = d.dno
where d.dno not in (select distinct dno from EMPLOYEE join department using (dno));

select d.dno, dname
from EMPLOYEE e right outer join department d
on e.dno = d.dno
where d.dno not in (select distinct dno from EMPLOYEE);

select d.dno, dname
from EMPLOYEE e right outer join department d
on e.dno = d.dno
where d.dno != ALL (select distinct dno from EMPLOYEE);

select d.dno, dname
from department d
where not exists (select dno from EMPLOYEE e --별칭 사용 안해도 됨
			where d.dno = e.dno);
			
/*
 * MINUS 이용
 */

select dno, dname
from department

minus

select dno, dname
from EMPLOYEE join department
using (dno);


--<7장.서브쿼리-혼자해보기>----------------------------------
--1.사원번호가 7788인 사원과 '담당업무가 같은' 사원을 표시(사원이름과 담당업무)
select ename, job
from EMPLOYEE
where job = (select job from EMPLOYEE where eno = '7788')
and dno != '7788';

--2.사원번호가 7499인 사원보다 급여가 많은 사원을 표시(사원이름과 담당업무)
select ename, job, salary
from EMPLOYEE
where salary > (select salary from EMPLOYEE where eno = '7788');

--3.최소급여를 받는 사원의 이름, 담당 업무 및 급여 표시(그룹함수 사용)
select ename, job, salary
from EMPLOYEE
where salary = (select min(salary) from EMPLOYEE);
--4.'직급별' 평균 급여가 가장 적은 담당 업무를 찾아 '직급(job)'과 '평균 급여' 표시
--단, 평균의 최소급여는 반올림하여 소수1째자리까지 표시
select job, round(avg(salary),1)
from EMPLOYEE
group by job
having avg(salary) = (select min(round(avg(salary),1)) from EMPLOYEE group by job)
--5.각 부서의 최소 급여를 받는 사원의 이름, 급여, 부서 번호 표시
select ename, salary, dno
from EMPLOYEE
where salary in (select min(salary) from EMPLOYEE group by dno)
--6.'담당 업무가 분석가(ANALYST)인 사원보다 급여가 적으면서 업무가 분석가가 아닌' 
--사원들을 표시(사원번호, 이름, 담당 업구, 급여)
select eno, ename, job, salary
from EMPLOYEE
where job != 'ALALYST'
and salary < all(select salary from EMPLOYEE where job = 'ANALYST');

--★★7.부하직원이 없는 사원이름 표시(먼저 '문제 8. 부하직원이 있는 사원이름 표시'부터 풀기)

select ename
from EMPLOYEE
where eno not in (select manager from EMPLOYEE where manager is not null);

--★★8.부하직원이 있는 사원이름 표시

select ename
from EMPLOYEE
where eno in (select manager from EMPLOYEE where manager is not null);

--9.BLAKE와 동일한 부서에 속한 사원이름과 입사일을 표시(단,BLAKE는 제외)

select ename, hiredate
from EMPLOYEE
where dno = (select dno from EMPLOYEE
			where ename = 'BLAKE')
and ename != 'BLAKE';

--10.급여가 평균 급여보다 많은 사원들의 사원번호와 이름 표시(결과는 급여에 대해 오름차순 정렬)

select eno, ename
from EMPLOYEE
where salary > (select avg(salary) from EMPLOYEE);

--11.이름에 K가 포함된 사원과 같은 부서에서 일하는 사원의 사원번호와 이름 표시

select eno, ename
from EMPLOYEE
where dno in (select dno from EMPLOYEE where ename like '%K%');

--12.부서위치가 DALLAS인 사원이름과 부서번호 및 담당 업무 표시

select ename, dno, job
from EMPLOYEE
where dno = (select dno from department where loc = 'DALLAS');

--[과제-1]
--[12번 변경문제]. 부서위치가 DALLAS인 사원이름, 부서번호, 담당 업무, + '부서위치' 표시 

select ename, dno, job, loc
from EMPLOYEE join department
using (dno)
where dno = (select dno from department where loc = 'DALLAS');

--13.KING에게 보고하는 사원이름과 급여 표시

select ename, salary
from EMPLOYEE
where manager = (select eno from EMPLOYEE where ename = 'KING');

--14.RESEARCH 부서의 사원에 대한 부서번호, 사원이름, 담당 업무 표시

select dno, ename, job
from EMPLOYEE
where dno = (select dno from department where dname = 'RESEARCH');

--15.평균 급여보다 많은 급여를 받고 이름에 M이 포함된 사원과 같은 부서에서 근무하는 
--사원번호,이름,급여 표시

select eno, ename, salary
from EMPLOYEE
where dno in (select distinct dno from EMPLOYEE where ename like '%M%')
and salary > (select avg(salary) from EMPLOYEE);
--16.평균 급여가 가장 적은 업무와 그 평균급여 표시

select job, avg(salary)
from EMPLOYEE
group by job
having avg(salary) = (select min(avg(salary)) from EMPLOYEE group by job);

--17.담당 업무가 MANAGER인 사원이 소속된 부서와 동일한 부서의 사원이름 표시

select ename
from EMPLOYEE
where eno in (select manager from EMPLOYEE)
