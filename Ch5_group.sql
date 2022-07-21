/*
 * 주의 : count(*) 함수를 제외한 모든 그룹함수들은 null값을 무시
 * 
 * 참고 : 오라클 실행 순서
 * from -> where -> group by -> having -> selcet 컬럼 별칭 -> order by
 * 
 * 따라서 where 절에서 '컬럼명의 별칭' 인식 못 함(즉, where + '컬럼명의 별칭' 사용불가)
 * 
 * 단, 아래 sql문은 where절에 별칭 사용가능
 * select * from(select salary as "급여" from employ)
 * where "급여" > 1000;
 * 
 */

select salary as "급여" from EMPLOY;

select * from (select salary as "급여" from EMPLOY)
where "급여" > 1000;

select sum(salary + commission) as "총액", trunc(avg(salary)) as "평균", max(salary) as "최고 급여",
min(salary) as "최저 급여"
from EMPLOY;

select max(hiredate) as "최근 사원",
min(hiredate) as "오래전 사원"
from EMPLOY;

select sum(commission) as "커미션 총액"
from EMPLOY;

select count(*) as "전체사원수"
from EMPLOY;

select count(*) as "전체사원수"
from EMPLOY
where commission is not null;

select count(commission) as "전체사원수"
from EMPLOY;

--직업(job)이 어떤 종류?
select distinct job
from EMPLOY;

select count(job), count(ALL job)
from EMPLOY;

select count(commission), count(ALL commission), count(*)
from EMPLOY;

select count(distinct job), count(ALL job)
from EMPLOY;

/*
 * 그룹함수와 단순 컬럼
 */

select max(salary)
from EMPLOY;--ERROR!


select (avg(salary)) --dno(부서 번호)가 없으면 결과는 무의미해짐
from EMPLOY
group by dno;

select dno, avg(salary)
from EMPLOY
group by dno
order by dno;

select dno, avg(salary)
from EMPLOY
group by dno, job
order by dno;

select dno, sum(salary)
from EMPLOY
group by dno
having sum(salary) >= 10000
order by dno;


select job, count(job), sum(salary + NVL(commission,0)) as "총 급여"
from EMPLOY
where job ^= 'MANAGER'
--jot not like 'MANAGER'
group by job
having sum(salary)>=5000
order by 3;

select job, count(job), sum(salary + NVL(commission,0)) as "총 급여"
from EMPLOY
where job not like 'MANAGER'
group by job
having sum(salary)>=5000
order by 3;

/*
 * 교재에 없는 내용
 * rank() : 순위 구하기
 * 문제 급여 상위 3개 조회
 * 
 */


/*
 * 문제1 급여 상위 3개 조회
 * (만약 급여가 같다면 커미션이 높은 순으로 조회, 커미션이 같다면 사원명을 알파벳 순으로 조회)
 */

delete from EMPLOY where salary is null;

select ename, salary, commission
from EMPLOY;

select ename, salary, commission
from EMPLOY
order by salary desc, commission desc, ename;

select ename, salary, commission,
RANK() OVER(ORDER BY SALARY DESC) AS "급여 순위 -1",
DENSE_RANK() OVER(ORDER BY SALARY DESC) AS "급여 순위 -2"
from EMPLOY;

select ename, salary, commission,
RANK() OVER(ORDER BY SALARY DESC) AS "급여 순위 -1",
DENSE_RANK() OVER(ORDER BY SALARY DESC) AS "급여 순위 -2",
RANK() OVER(ORDER BY SALARY DESC, COMMISSION DESC, ENAME) AS "급여 순위 -3"
from EMPLOY;

--부서 그룹별 '부서 안에서 각 순위 구하기' PARTITION BY + 그룹 컬럼명
SELECT DNO, ENAME, RANK() OVER (PARTITION BY DNO ORDER BY SALARY DESC, COMMISSION DESC, ENAME)
FROM EMPLOY

--UNION ALL 사용(나중에 SQL 활용 시험 정리 할때 설명)
--UNION ALL : 중복 허용
--UNION : 중복 제거
--사원 테이블에서 '연봉 상위 3명'의 이름, 급여조회(단, 급여가 같으면 사원 이름으로 오름차순 정렬)

SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 10;
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 20;
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 30;
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 40;

SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 10
UNION ALL
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 20
UNION ALL
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 30
UNION ALL
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 40

ORDER BY SALARY DESC, ENAME;

SELECT * 
FROM(SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 10
UNION ALL
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 20
UNION ALL
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 30
UNION ALL
SELECT ENAME, SALARY FROM EMPLOY WHERE DNO = 40

ORDER BY SALARY DESC, ENAME)
WHERE ROWNUM <=3;

select *
from (
	select ename, salary, commission,
	RANK() OVER(ORDER BY SALARY DESC, COMMISSION DESC, ENAME) AS "급여 순위"
	from EMPLOY)
where "급여 순위" <= 3;

/*
 * 문제 2 그룹별 최소값, 최대값 구하기-----------------------------
 * 부서 그룹별 최소값, 최대값 구하기
 */

select MIN(salary), MAX(salary)
from EMPLOY;

select dno, ename, MIN(salary), MAX(salary)
from EMPLOY
group by dno, ename;

select dno, ename,
MIN(salary) over(partition by dno),  MAX(salary) over(partition by dno)
from EMPLOY
group by dno, ename, salary
order by dno;

select dno, ename, salary,
MIN(salary) keep(dense_rank first order by salary asc) over(partition by dno) as "부서별 최소 급여",
MAX(salary) keep(dense_rank last order by salary asc) over(partition by dno) as "부서별 최대 급여"
from EMPLOY
order by dno;

--문제3 그룹별 최솟값, 최대값 구하기 + 전체 급여 순위 구하기()
select dno, ename, salary,
MIN(salary) keep(dense_rank first order by salary asc) over(partition by dno) as "부서별 최소 급여",
MAX(salary) keep(dense_rank last order by salary asc) over(partition by dno) as "부서별 최대 급여",
RANK() OVER(partition by dno ORDER BY SALARY DESC) AS "급여 순위"
from EMPLOY
order by dno;

--문제 4, 문제3에서 각 그룹의 1등만 표시
select *
from (select dno, ename, salary,
MIN(salary) keep(dense_rank first order by salary asc) over(partition by dno) as "부서별 최소 급여",
MAX(salary) keep(dense_rank last order by salary asc) over(partition by dno) as "부서별 최대 급여",
RANK() OVER(partition by dno ORDER BY SALARY DESC) AS "급여 순위"
from EMPLOY)
where "급여 순위" = 1
order by dno;

/*
 * 그룹 함수는 2번까지만 중첩해서 사용가능
 * [문제] 부서 별 급여평균의 최고값을 출력
 */

select dno, avg(salary) from employ
group by dno;

select max(avg(salary))
from employ
group by don;

select dno, avg(salary) from employ
where (select max(salary) from EMPLOY) = salary
group by dno;


select max(salary), min(salary), sum(salary), round(avg(salary),0)
from EMPLOY;

select job,  max(salary), min(salary), sum(salary), round(avg(salary),0)
from EMPLOY
group by job;

select job, count(*)
from EMPLOY
group by job;

select job, count(MANAGER)
from EMPLOY
where job = 'MANAGER'
group by job;

select max(salary) - min(salary) as "차이"
from EMPLOY;



select job, min(salary)
from EMPLOY
where MANAGER is not null
group by job
having min(salary) >= 2000
order by min(salary) desc;

--7

select dno, count(*) as "인원 수", round(avg(nvl(salary,0)),2) as "봉급"
from EMPLOY
group by dno;

select dno, count(*) as "인원 수", round(avg((salary)),2) as "봉급"
from EMPLOY
group by dno;

/*
 * salary의 null의 여부를 모른채 조회
 */
insert into EMPLOY values(7002,'JANG','CLERK',7902,'2022/05/30',NULL,NULL,20);
--나누기 6이 안됨, 없는 사람 취급
/*
 * null값 급여를 받는 사원도 함께 포함시켜 평균을 계산 하려면
 * 반드시 null처리 함수 사용하여 구체적인 값으로 변경
 */
/*
 * 추가 문제, 커미션을 받는 사원들 만의 커미션 평균 과
 * 전체 사원의 커미션 평균 구하기
 */
select avg(commission)
from employ;

select round(avg(nvl(commission,0)),2)
from employ;

select decode(dno,10,'ACCOUNTING',
				20, 'RESEARCH',
				30, 'SALES',
				40, 'OPERATIONS') AS "DNO",
		decode(dno,10,'NEW YORK',
				20, 'DALLAS',
				30, 'CHICAGO',
				40, 'BOSTON') AS "LOCAL",
		COUNT(*) as "인원 수",
		ROUND(AVG(SALARY)) as "봉급"
FROM EMPLOY
GROUP BY DNO;

select * from DEPARTMENT;

select eno, ename, DEPARTMENT.dno, dname
from EMPLOY, DEPARTMENT
where EMPLOY.dno = DEPARTMENT.dno;

select eno, ename, e.dno, dname
from EMPLOY e, DEPARTMENT d
where e.dno = d.dno;

select e.dno, dname, loc,COUNT(*) as "인원 수",ROUND(AVG(SALARY)) as "봉급"
from EMPLOY e, DEPARTMENT d
where e.dno = d.dno
group by e.dno, dname, loc;

select e.dno, dname, loc,COUNT(*) as "인원 수",ROUND(AVG(SALARY)) as "봉급"
from EMPLOY e join DEPARTMENT d
on e.dno = d.dno
group by e.dno, dname, loc
order by e.dno;


--natural join
select eno, ename, dno, dname
from EMPLOY natural join department
order by dno;
--조인 조건 없어도 알아서 같은 컬럼끼리 조인

select dno, dname, loc,COUNT(*) as "인원 수",ROUND(AVG(SALARY)) as "봉급"
from EMPLOY join department
using (dno)
group by dno, dname, loc
order by dno;

SELECT JOB, DNO,count(*), DECODE(DNO,10,SUM(SALARY),0) AS "부서 10",
				DECODE(DNO,20,SUM(SALARY),0) AS "부서 20",
				DECODE(DNO,30,SUM(SALARY),0) AS "부서 30",
				SUM(SALARY)
FROM EMPLOY
GROUP BY JOB, DNO
ORDER BY DNO;





