--<북스 2장. 데이터 조회하기
--이름이 SCOTT 사원의 정보 출력

select * 
from employ
where ename = 'SCOTT';

select * from EMPLOY
where ename = upper('scott');

select * from EMPLOY
where hiredate <= '1981-1-1';
--sql: 문자는 무조건 '', 자바는 '문자1개', "문자 여러개"

--논리연산자 not, and, or
select * from employ
where DNO = 10 and job = 'MANAGER';

select * from employ
where DNO = 10 or job = 'MANAGER';

select * from employ
where not dno = 10; /*!=, <>, ^= 같지 않음을 표현하는 방법*/

select * from EMPLOY
where dno != 10;

select * from employ
where salary = 1100;

select * from EMPLOY
where salary = 1300;

select * from EMPLOY
where salary between 1000 and 1500;

select * from EMPLOY
where salary < 1000 or salary > 1500;


select * from EMPLOY
where salary not between 1000 and 1500;

--'1982'년에 입사한 사원 정보 출력
select * from EMPLOY
where hiredate between '1982-1-1' and '1982-12-31';

select * from EMPLOY
where hiredate between '82-01-01' and '82-12-31';

--커미션이 300이거나 500이거나 1400인 사원 정보 검색
--커미션이 null인 사원은 제외됨(null은 비교연산자로 비교 불가능함)
select * from EMPLOY
where commision = 300 or commision = 500 or commision = 1400;

select * from EMPLOY
where not (commision = 300 or commision = 500 or commision = 1400);

select * from EMPLOY
where commision in(300, 500, 1400);


select * from EMPLOY
where commision not in(300, 500, 1400);

select * from EMPLOY
where ename like 'F%';

--이름에 'M'이 포함된 사원정보 출력
select * from EMPLOY
where ename like '%M%';

select * from EMPLOY
where ename like '%M';

select * from employ
where ename like '_A%';

select * from employ
where ename like '__A%';

select * from employ
where ename not like '%A%';

--commision을 받지 못하는 사원 정보 검색
select * from EMPLOY
where commision is null;

--commision을 받는 사원 정보 검색

select * from EMPLOY
where commision is not null;

select * from EMPLOY
order by salary;

select * from EMPLOY
order by salary asc, commision desc;

select * from EMPLOY
--order by salary asc,commision desc, ename asc;
--order by salary,commision desc, ename;
order by 6,7 desc, 2;--인덱스 번호, sql은 1부터 시작

select * from EMPLOY
order by 5;

select eno, ename, hiredate from EMPLOY
order by hiredate; -- oder by 3;

/*
 *2장 혼자 해보기(65~72p)
 */

--1.덧셈 연산자를 이용하여 모든 사원에 대해서 300의 급여인상을 계산한 후 
--사원의 이름, 급여, 인상된 급여 출력
select ename, salary, salary + 300 as "Improved"
from employ;


--2.사원의 이름,급여,연간 총수입을 총 수입이 많은 것부터 작은 순으로 출력
--연간 총수입=월급*12+상여금100
select ename, salary, (salary*12 + 100) as "Years"
from employ
order by 3;

--3.'급여가 2000을 넘는' 사원의 이름과 급여를 '급여가 많은 것부터 작은 순'으로 출력
select ename, salary
from EMPLOY
where salary > 2000
order by salary desc;

--4.사원번호가 7788인 사원의 이름과 부서번호를 출력
select ename, dno from employ
where eno = 7788;

--5.급여가 2000에서 3000 사이에 포함되지 않는 사원의 이름과 급여 출력
select ename, salary from employ
where salary not (between 2000 and 3000);

--5-2. 급여가 2000에서 3000 사이에 포함되는 사원의 이름과 급여 출력
select ename, salary from employ
where salary between 2000 and 3000;

--6.1981년 2월 20일부터 1981년 5월 1일 사이에 입사한 사원의 이름, 담당업무, 입사일 출력
--오라클의 기본날짜 형식은 'YY/MM/DD'
select ename, job, hiredate from employ
where hiredate between '81/02/20' and '81/05/01';

--7.부서번호가 20 및 30에 속한 사원의 이름과 부서번호를 출력하되 
--이름을 기준으로 영문자순으로 출력
select ename, dno from EMPLOY
where dno in (20,30)
order by ename;


--8.'사원의 급여가 2000에서 3000사이에 포함'되고 '부서번호가 20 또는 30'인 사원의 이름, 급여와 부서번호를 출력하되 
--이름순(오름차순)으로 출력
select ename, salary, dno from employ
where salary between 2000 and 3000 and dno in(20, 30)
order by ename asc;

--9. 1981년도에 입사한 사원의 이름과 입사일 출력(like연산자와 와일드카드(% _) 사용)
select ename, hiredate from employ
where hiredate like '81/%/%';

--[method 2] --TO_CHAR(number or date,'type')
--
select ename, hiredate from employ
where to_char(hiredate,'yyyy') like '1981';

--[method 3]
select ename, hiredate from employ
where to_char(hiredate,'yyyy-mm-dd') like '1981%';

select hiredate, to_char(hiredate,'yyyy/mm/dd'), to_char(hiredate,'yyyy')
from employ;


--10.관리자(=상사)가 없는 사원의 이름과 담당업무
select ename, job from employ
where manager is null;

--11.'커미션을 받을 수 있는 자격'이 되는 사원의 이름, 급여, 커미션을 출력하되
--급여 및 커미션을 기준으로 내림차순 정렬
select ename, salary, commision from EMPLOY
where commision is not null
order by salary desc, commision desc;

select ename, salary, commision from EMPLOY
where job = 'SALESMAN'
order by salary desc, commision desc;

--12.이름의 세번째 문자가 R인 사원의 이름 표시
select ename from employ
where ename like '__R%'


--13.이름에 A와 E를 모두 포함하고 있는 사원이름 표시

select ename from employ
where ename like '%A%' and ename like '%E%';

--14.'담당 업무가 사무원(CLERK) 또는 영업사원(SALESMAN)'이면서 
--'급여가 1600,950,1300 모두 아닌' 사원이름, 담당업무, 급여 출력
select ename, job, salary from EMPLOY
where job in ('CLERK', 'SALESMAN') and salary not in (1600, 950, 1300);


--15.'커미션이 500이상'인 사원이름과 급여, 커미션 출력

select ename, salary, commision from EMPLOY
where commision >= 500;






































