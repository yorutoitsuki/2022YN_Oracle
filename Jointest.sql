/*
 * 문제 3개의 테이블 조인하기
 * 
 * 사원이름, 소속된 부서번호, 소속된 부서명, 급여, 급여등급 조회
 * 4가지 join방법 활용
 * 
 * 최종, 조인한 결과 테이블과 급여정보 테이블 join하기
 */

select ename, d.dno, dname, salary, grade
from department d join 
(select ename, dno, salary, grade
from EMPLOY join salgrade
on salary between losal and hisal) j
on d.dno = j.dno;

select e.ename, e.dno, dname, e.salary, grade
from EMPLOY e,department d, salgrade
where salary between losal and hisal
and e.dno = d.dno;

select ename, dno, dname, salary, grade
from department d join 
(select ename, dno, salary, grade
from EMPLOY join salgrade
on salary between losal and hisal)
using (dno);

select ename, dno, dname, salary, grade
from salgrade,
(select ename, dno, dname, salary
from EMPLOY natural join department)
where salary between losal and hisal;

--<6장. 테이블 조인하기-혼자해보기>--------------------------------------
/*
 * 1.EQUI 조인을 사용하여 SCOTT사원의 부서번호와 부서이름을 출력하시오.
 */
select ename, e.dno, dname
from EMPLOY e, DEPARTMENT d
where e.dno = d.dno
and ename = 'SCOTT';
/*
 * 2.(INNER) JOIN과 ON 연산자를 사용하여 사원이름과 함께 그 사원이 소속된 부서이름과 지역명을 
 * 출력하시오.
 */
select ename, dname, loc
from EMPLOY e join DEPARTMENT d
on e.dno = d.dno;
/*
 * 3.(INNER) JOIN과 USING 연산자를 사용하여 10번 부서에 속하는 모든 담당 업무의 고유 목록
 * (한 번씩만 표시)을 부서의 지역명을 포함하여 출력하시오.
 */
select distinct job, loc, dno
from EMPLOY join department
using (dno)
where dno = 10;
/*
 * 4.NATURAL JOIN을 사용하여 '커미션을 받는 모든 사원'의 이름, 부서이름, 지역명을 출력하시오.
 */
select ename, dname, loc, commission
from EMPLOY natural join department
where commission is not null;
/*
 * 5.EQUI 조인과 WildCard를 사용하여 '이름에 A가 포함'된 모든 사원의 이름과 부서이름을 출력하시오.
 */
select ename, dname
from EMPLOY e, DEPARTMENT d
where e.dno = d.dno
and ename like '%A%';
/*
 * 6.NATURAL JOIN을 사용하여 NEW YORK에 근무하는 모든 사원의 이름, 업무, 부서번호, 부서이름을 
 * 출력하시오.
 */
select ename, job, dno, dname, loc
from EMPLOY natural join department
where loc = 'NEW YORK';
/*
 * 7.SELF JOIN을 사용하여 사원의 이름 및 사원번호를 관리자 이름 및 관리자 번호와 함께 출력하시오.
 */
select e1.ename, e1.eno, e1.manager, e2.ename as "superviser"
from EMPLOY e1 join employ e2
on e1.manager = e2.eno;
/*
 * 8.'7번 문제'+ OUTER JOIN, SELF JOIN을 사용하여 '관리자가 없는 사원'을 포함하여 사원번호를
 * 기준으로 내림차순 정렬하여 출력하시오.
 */
select e1.dno, e1.ename, e1.eno, e1.manager, e2.ename as "superviser"
from EMPLOY e1 left outer join employ e2
on e1.manager = e2.eno
order by e1.dno desc;
/*
 * 9.SELF JOIN을 사용하여 지정한 사원의 이름('SCOTT'), 부서번호, 지정한 사원과 동일한 부서에서 
 * 근무하는 사원이름을 출력하시오.
 * 단, 각 열의 별칭은 이름, 부서번호, 동료로 하시오.
 */
select e1.ename as "name", e1.dno as "dNumber", e2.ename as "Company"
from EMPLOY e1 join employ e2
on (select dno from EMPLOY where ename = 'SCOTT') = e1.dno
where e1.ename = 'SCOTT';
/*
 * 10.SELF JOIN을 사용하여 WARD 사원보다 늦게 입사한 사원의 이름과 입사일을 출력하시오.
 * (입사일을 기준으로 오름차순 정렬)
 */

select ename, hiredate
from EMPLOY
where (select hiredate from EMPLOY where ename = 'WARD') < hiredate
order by hiredate;

select distinct e2.ename, e2.hiredate
from EMPLOY e1, employ e2
where (select hiredate from EMPLOY where ename = 'WARD') < e2.hiredate
order by hiredate;

select e1.ename, e1.hiredate, e2.ename, e2.hiredate
from EMPLOY e1 join employ e2
on e1.ename = 'WARD'
where e1.hiredate < e2.hiredate
order by e2.hiredate;

select e2.ename, e2.hiredate
from EMPLOY e1, employ e2
where e1.hiredate < e2.hiredate
and e1.ename = 'WARD';
/*
 * 11.SELF JOIN을 사용하여 관리자보다 먼저 입사한 모든 사원의 이름 및 입사일을 
 * 관리자 이름 및 입사일과 함께 출력하시오.(사원의 입사일을 기준으로 정렬)
 */
select e2.ename as "이름", e2.hiredate as "입사일", e1.ename as "관리자", e1.hiredate as "관리자 입사일"
from EMPLOY e1, EMPLOY e2
where e2.manager = e1.eno
and e2.hiredate < e1.hiredate
order by e2.hiredate;









