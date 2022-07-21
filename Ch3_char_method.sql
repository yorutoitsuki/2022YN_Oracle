--<북스 4장, 다양한 함수>
/*
 * 문자함수
 */

select 'Apple', 
Upper('Apple'), 
lower('Apple'), 
initcap('aPPLE') 
from dual; --가상 테이블

select eno, ename, dno
from employ
where ename = upper('scott');

select eno, ename, dno
from employ
where lower(ename) = 'scott';

--2.문자 길이를 반환하는 함수
--영문, 수, 특수문자(1Byte) 또는 한글의 길이(2Byte)
--length() : 문자 수
select length('Apple'), length('사과'), lengthb('사과')
from dual;
--lengthB() : korean 2 Bytes - '인코딩 방식'에 따라 달라짐(UTF-8)
select lengthb('Apple'), lengthb('사과')
from dual;


--3. 문자 조작 함수
--concat('문자열1','문자열2') : '두 문자열'을 하나의 문자열로 연결(결합)
--            반드시 2개 문자열만 연결 가능
--매개변수 = 인수 = 인자 = argument
--in JAVA, "Apple".concat("ringo")
select 'Apple', '사과', concat('Apple','사과') as "함수사용",
--in JAVA "Apple"+"ringo"+"Apirl"
'Apple' || '사과' || 'ringo' as "|| used"
from dual;

--substr(기존 문자열, 시작index, 추출할 갯수) :
select substr('Apple mania',6,6),
substr('Apple mania', -11, 5)
--시작 index가 음수이면 문자열의 마지막으로 기준점 변경, 뒤에서 셈.
from dual;

--문제1. 이름이 n으로 끝나는 사원 정보 표시
select * from EMPLOY
where substr(ename,-1,1) = 'N';

select * from EMPLOY
where ename like '%N';

--문제2. 87년도에 입사한 사원 정보 검색

select * from EMPLOY
where hiredate like '87%';

select * from employ
where to_char(hiredate,'yyyy') like '1987';

select * from EMPLOY
where substr(hiredate,1,2) = '87';

select * from employ
where substr(to_char(hiredate,'yyyy'),1,4) = '1987';

select * from employ
where substr(to_char(hiredate,'yyyy'),3,2) = '87';

select * from employ
where substr(to_char(hiredate,'yyyy'),-2,2) = '87';

--문제3. 급여가 50으로 끝나는 사원의 사원이름과 급여 출력

select ename, salary from employ
--where substr(salary,-2,2) = '50';
--salary는 실수 number타입 이지만 문자로 자동형변환
where substr(salary,-2,2) = 50; --'50' = 50 => 50 = 50

--자동 형변환되어 비교된다는 사실을 모르면
select ename, salary from employ
where substr(To_char(salary),-2,2) = '50';--to_char(수나 날짜)를 문자로 형변환 해야함

--substrB(기본 문자열, 시작 Index, 추추할 바이트 수)
select substr('사과매니아',1,2), --사과
substrB('사과매니아',1,3), --사
substrB('사과매니아',4,3), --과
substrB('사과매니아',1,6)--사과
from dual

--in(index)str(string)
--(대상 문자열, 찾을 문자열, 시작 index, 몇 번째 발견)
--대상문자열 내에 찾고자 하는 문자열이 어느 '위치'에 있는지
--'시작 index, 몇 번째 발견' 생략하면 모두 1로 간주
--예) instr('대상문자열','찾을 문자') == instr('대상문자열','찾을 문자',1,1)
--찾는 문자가 없으면 0을 결과로 돌려줌,(자바에서는 -1을 리턴)
--자바에서는 "test,case".index("case") == 5

select instr('apple','p'), instr('apple','p',1,1),
		instrB('apple','p'), instrB('apple','p',1,1),
		instr('apple','p',1,2)--'apple'내에서 1부터 시작해서 두 번째 발견하는 'p'를 찾아 index번호 리턴
from dual;


select instr('apple','p',2,2)
from dual;
select instr('apple','p',3,1)
from dual;
select instr('apple','p',3,2)
from dual;
select instr('apple','pl',1,1)
from dual;

--'바나나'에서 '나'문자가 1부터 시작해서 1번째 발견되는 '나' 위치?
select instr('바나나','나'), instr('바나나','나',1,1),
		instrB('바나나','나'), instrB('바나나','나',1,1)
from dual;

--이름의 세번째 글자가 'R'인 사원의 정보 검색
select ename from employ
where instr(ename,'R',3,1) = 3;

select ename from employ
where ename like '__R%';

select ename from EMPLOY
where substr(ename,3,1) = 'R';

--LPAD (left padding)
--컬럼이나 대상 문자열을 명시된 자릿수에서 오른쪽 정렬로 나타내고
--남는곳에 특정 기호로 채움

select salary, lpad(salary, 10, ' ')
from employ;

--RPAD
select salary, rpad(salary, 10, ' ')
from employ;

--LTRIM('    문자열') : 문자열의 '왼쪽' 공백 제거
--RTRIM('문자열    ') : 문자열의 '오른쪽' 공백 제거
-- TRIM('  문자열  ') : 문자열의 '양쪽' 공백 제거

select '   사과 매니아   '||'입니다',
LTRIM('   사과 매니아   ')||'입니다',
RTRIM('   사과 매니아   ')||'입니다',
TRIM('   사과 매니아   ')||'입니다'
from dual;

--TRIM('특정문자 1개만' from 컬럼이나 '대상문자열')
--컬럼이나 '대상 문자열' 에서 '특정 문자'가 '첫 번째 글자' 이거나
--'마지막 글자'이면 잘라내고
--남은 문자열만 결과로 반환한다.

select TRIM('apple' from 'apple maniac')
from dual; --trim set should have only one character

select TRIM('a' from 'apple maniac')
from dual;

select TRIM('c' from 'apple maniac')
from dual;

select TRIM('p' from 'apple maniac')
from dual;--non-availabe to delete at front and rear


/*
 * <숫자함수>
 * 1. round(대상, 화면에 표시되는 자릿수) : 반올림
 * 단, 자릿수 생략하면 0으로 간주
 * -2(百), -1(十), 0(一), 1 2 3
 * 
 */
select 98.7654,
round(98.7654),
round(98.7654,0),
round(98.7654,2), -- 소수 2째 자리 까지 표시, 3번째자리에서 반올림
round(98.7654,-1) -- 십의 자리까지 표시, 일의 자리에서 반올림
from dual;

--2.trunc(대상, 화면에 표시되는 자릿수) : '화면에 표시되는 자릿수'까지 남기고 나머지 버림
--단, 자릿수 생략하면 0으로 간주
select 98.7654,
trunc(98.7654),
trunc(98.7654,0),
trunc(98.7654,2), -- 소수 2째 자리 까지 표시
trunc(98.7654,-1) -- 십의 자리까지 표시
from dual;

--3. mod(수1, 수2) : 수1을 수2로 나눈 나머지
select MOD(10,3)
from dual;

--사원이름, 급여, 급여를 500으로 나눈 나머지 출력
select ename, salary, mod(salary,500) as "S%500"
from EMPLOY
order by 3,2;

/*
 * 1. sysdate : 시스템으로 부터 오늘의 날짜와 시간을 반환 (mysql => now())
 */
select distinct sysdate from EMPLOY;
select sysdate from dual;

--date + 숫자 = 날짜에서 수 만큼 '이후 날짜'
--date - 숫자 = 날짜에서 수 만큼 '이전 날짜'
--date - date = 일수
--date + 수/24 = 날짜 + 시간

select sysdate-1 as "Yesterday",
sysdate as "Today",
sysdate + 1 as "Tomorrow"
from dual;

--문제 사원들의 현재까지의 근무일수 구하기(단, 실수이면 반올림)

select '2022/06/14' - '2022/06/13' as "Punched"
from dual;--문자로 인식되어 연산이 아니됨
--to_date()를 이용하여 문자를 날짜로 형변환 해야함

select to_date('2022/06/14') - to_date('2022/06/13') as "Punched"
from dual;

select sysdate - hiredate as "Days"
from EMPLOY;

select round(sysdate - hiredate,0) as "Days",
trunc(sysdate - hiredate,0) as "Days"
from EMPLOY;

select hiredate, trunc(hiredate,'month') --days(set 01), times(set 00:00:00)
from employ;

select sysdate,
trunc(sysdate, 'year'), --년 까지 표시하고 잘림
trunc(sysdate, 'month'), --월 까지 표시하고 잘림
trunc(sysdate, 'day'), -- 요일 초기화(해당 날짜에서 그 주의 지나간 일요일로 초기화)
trunc(sysdate),		   -- 시간이 짤림
trunc(sysdate,'dd'),   -- 시간이 짤림
trunc(sysdate, 'hh24'), --'시까지 표시'하고 분과 초 잘림
trunc(sysdate,'mi') --'분까지 표시'하고 초 잘림
from dual;

SELECT
TO_CHAR(SYSDATE ,'yyyy/mm/dd'), --오늘 날짜  
TO_CHAR(SYSDATE + 1 ,'yyyy/mm/dd'), --내일 날짜  
TO_CHAR(SYSDATE -1 ,'yyyy/mm/dd'), --어제 날짜  
TO_CHAR(TRUNC(SYSDATE,'dd') ,'yyyy/mm/dd hh24:mi:ss'), -- 오늘 정각 날짜
TO_CHAR(TRUNC(SYSDATE,'dd') + 1,'yyyy/mm/dd hh24:mi:ss'), -- 내일 정각 날짜
TO_CHAR(SYSDATE + 1/24/60/60 ,'yyyy/mm/dd hh24:mi:ss'), -- 1초 뒤 시간
TO_CHAR(SYSDATE + 1/24/60 ,'yyyy/mm/dd hh24:mi:ss'), -- 1분 뒤 시간
TO_CHAR(SYSDATE + 1/24 ,'yyyy/mm/dd hh24:mi:ss'), -- 1일 뒤 시간
TO_CHAR(TRUNC(SYSDATE,'mm') ,'yyyy/mm/dd'), --이번 달 시작날짜
TO_CHAR(LAST_DAY(SYSDATE) ,'yyyy/mm/dd'), --이번 달 마지막 날
TO_CHAR(trunc(ADD_MONTHS(SYSDATE, + 1),'mm') ,'yyyy/mm/dd'), --다음 달 시작날짜
TO_CHAR(ADD_MONTHS(SYSDATE, 1) ,'yyyy/mm/dd hh24:mi:ss'), -- 다음달 오늘 날자
TO_CHAR(TRUNC(SYSDATE, 'yyyy') ,'yyyy/mm/dd'), --올해 시작 일
TO_CHAR(TRUNC(ADD_MONTHS(SYSDATE, -12), 'dd'),'yyyy/mm/dd'), --작년 현재 일
TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')) - TO_DATE('19930315'), -- 두 날짜 사이 일수 계산
MONTHS_BETWEEN(SYSDATE, '19930315'), -- 두 날짜 사이의 월수 계산
TRUNC(MONTHS_BETWEEN(SYSDATE, '19930315')/12,0) --두 날짜 사이의 년수 계산
FROM DUAL; 

--2.monthS_between(날짜1, 날짜2) : 날짜1과 날짜 2 사이에 개월 수 구하기
-- 날짜1 - 날짜2 = 일수
/*
 * to_char(수나 날짜, '형식') 문자로 변형
 * to_date()다시 date 형식으로 변경
 */
select ename, sysdate, hiredate,
sysdate - hiredate as "근무일수",

to_date(to_char(sysdate,'yyyy-mm-dd')),
to_date(to_char(hiredate,'yyyy-mm-dd')),
--[방법-1]모든 시간이 0으로 초기화 되어 => 결과가 정수
to_date(to_char(sysdate,'yyyy-mm-dd')) - to_date(to_char(hiredate,'yyyy-mm-dd')) as "days1",
--[방법-2]모든 시간이 0으로 초기화 되어 => 결과가 정수
to_date(to_char(sysdate,'yyyy-mm-dd'),'yyyy-mm-dd') as "비교1",
to_date(to_char(hiredate,'yyyy-mm-dd')) as "비교2",
to_date(to_char(hiredate,'yyyy-mm-dd')) - to_date(to_char(sysdate,'yyyy-mm-dd')) as "days2",
months_between(sysdate,hiredate) as "month",
trunc(months_between(sysdate, hiredate),0) as "근무 개월 수",
months_between(hiredate,sysdate) as "month",
trunc(months_between(hiredate, sysdate),0) as "근무 개월 수"
from employ;


--2. monthS_between(날짜1, 날짜2) : 날짜1과 날짜2 사이에 개월 수 구하기
--※ 날짜1-날짜2=일수
select ename, sysdate, hiredate, 
sysdate-hiredate as "근무일수",
--오늘날짜-입사일자=근무일수(결과가 실수?시간이 포함)
--그래서, to_char(수나 날짜, '형식') 문자로 변형 => 다시 date로 변형(모든 시간이 0으로 초기화)
--형식 생략해도 결과 같음
to_date(to_char(sysdate)),--고로 형식 생략
to_date(to_char(hiredate,'yyyy-mm-dd')),
--[방법-1:권장]모든 시간이 0으로 초기화되어 => 결과가 정수
to_date(to_char(sysdate)) - to_date(to_char(hiredate)) as "days1",
--[방법-2]모든 시간이 0으로 초기화되어 => 결과가 정수
to_date(to_char(sysdate, 'yyyy-mm-dd'),'yyyy-mm-dd') as 비교1,--2022-06-21 00:00:00.0 => 사용함
to_date(to_char(sysdate),'yyyy-mm-dd') as 비교2,--0022-06-21 00:00:00.0 => 따라서, 사용안함
to_date(to_char(hiredate),'yyyy-mm-dd') - to_date(to_char(sysdate),'yyyy-mm-dd') as "days2",

monthS_between(sysdate, hiredate) as "근무개월수",--실수(양수)
TRUNC(monthS_between(sysdate, hiredate),0) as "근무개월수",--정수(소수점 뒤 버림) 48.78 => 48
ROUND(monthS_between(sysdate, hiredate),0) as "근무개월수",--정수(반올림) 48.78 => 49
--★주의 : 날짜의 위치 
monthS_between(hiredate, sysdate) as "근무개월수",--실수(음수)
TRUNC(monthS_between(hiredate, sysdate)) as "근무개월수",--정수(소수점 뒤 버림)
ROUND(monthS_between(hiredate, sysdate)) as "근무개월수"--정수(반올림)
from employ;

--to_char(날짜, '형식')에 맞게 원하는 부분만 출력할 수 있다.
--입사일자를
select ename, hiredate,
to_char(hiredate, 'yyyy') as "년도만",
to_char(hiredate, 'mm') as "달만",
to_char(hiredate, 'dd') as "일만",
to_char(hiredate, 'd') as "요일만",--1:일~7:토
to_char(hirddate,'day') as "요일"
--오늘날짜를
to_char(sysdate, 'hh24') as "시간만-24시간 기준",
to_char(sysdate, 'hh') as "시간만-12시간 기준",
to_char(sysdate, 'mi') as "분만",
to_char(sysdate, 'ss') as "초만"
from employ;



select decode(to_char(sysdate, 'd'),1,'일요일',2,'월요일'
,3,'화요일',4,'수요일',5,'목요일',6,'금요일',7,'토요일') as "요일만"--1:일~7:토
from dual;

select sysdate,
to_char(sysdate,'yyyy-mm-dd'),--		2022-
to_char(sysdate,'yyyy/mm/dd'),--		2022/
to_char(sysdate,'yyyy/mm-dd')
from dual;

--정리 : to_date('날짜 문자', '형식')에 관계없이 '년-월-일 00:00:00:00'
select
to_date(to_char(sysdate,'yyyy-mm-dd')),--2022-
to_date(to_char(sysdate,'yyyy/mm/dd')),
to_date(to_char(sysdate,'yyyy-mm-dd'),'yyyy/mm/dd'),
to_date(to_char(sysdate,'yyyy/mm/dd'),'yyyy-mm-dd')
from dual;

select
to_date(to_char(sysdate)),--2022-
to_date(to_char(sysdate,'yyyy/mm/dd')),
to_date(to_char(sysdate,'yyyy-mm-dd'),'yyyy/mm/dd'),
to_date(to_char(sysdate,'yyyy/mm/dd'),'yyyy-mm-dd')
from dual;

--3. add_months(날짜, 더할 개월수) : 특정 개월수를 더한 날짜
select ename, hiredate,
add_months(hiredate, 3), add_months(hiredate, -3)
from employ
order by hiredate;

--4. next_day(날짜, '수요일') : 해당 날짜를 기준으로 최초로 도래하는 요일에 해당하는 날짜 반환
select sysdate,
next_day('2022/06/14','수요일'),
next_day(sysdate,'토요일'),
next_day(sysdate,7) --일요일(1), 월요일(2), 화요일(3), ...토요일(7)
from dual;

--5. last_day(날짜) : 해당 날짜가 속한 달의 마지막 날짜를 반환
--대부분 달의 경우, 마지막 날이 정해져 있지만 2월은 윤년 때문에 날짜가 변동됨

select sysdate, last_day(sysdate),
substr(to_char(last_day(sysdate),'yyyy/mm/dd'),9,2) as "Last_day"
from dual;



select substr(hiredate,1,2) as "Year",
substr(hiredate,4,2) as "month"
from employ;

select *
from EMPLOY
where substr(hiredate,4,2) = '04';

select hiredate,
substr(to_char(hiredate,'yyyy-mm-dd'),1,4) as "year",
substr(to_char(hiredate,'yyyy-mm-dd'),6,2) as "month"
from EMPLOY;

select * from EMPLOY
where instr(hiredate,'4',1) = 5;

select * from EMPLOY
where substr(to_char(hiredate,'mm'),1,2) = '04';

select * from employ
where substr(to_char(hiredate,'yyyy/mm/dd'),6,2) = '04';

select ename, hiredate, to_char(hiredate, 'day') as "요일"
from EMPLOY
where to_char(hiredate, 'day') = '수요일';

select ename, hiredate, to_char(hiredate, 'day') as "요일"
from EMPLOY
where to_char(hiredate, 'd') = 4;

--6. 날짜 또는 시간 차이 계산 방법
--(1)날짜 차이 : 종료일자(YYYY-MM-DD) - 시작일자(YYYY-MM-DD)
--(2)시간 차이 : 종료일시(YYYY-MM-DD HH:MI:SS) - 시작일시(YYYY-MM-DD HH:MI:SS)
--            (예) 2022-06-21 02:20:27 - 2022-06-19 02:20:27 = 2*24 = 48시간
--(3)분 차이 : 종료일시(YYYY-MM-DD HH:MI:SS) - 시작일시(YYYY-MM-DD HH:MI:SS)
--            (예) 2022-06-21 02:20:27 - 2022-06-19 02:20:27 = 2*24*60 = 2880분
--(3)분 차이 : 종료일시(YYYY-MM-DD HH:MI:SS) - 시작일시(YYYY-MM-DD HH:MI:SS)
--            (예) 2022-06-21 02:20:27 - 2022-06-19 02:20:27 = 2*24*60*60 = 172800초
--'종료일자' - '시작일자' 빼면 차이값이 '일기준'의 수치값으로 변환된다.

--(2-1)시간 차이 - 예
select to_date('15:00','hh24:mi') - to_date('13:00','hh24:mi') as "일",
(to_date('15:00','hh24:mi') - to_date('13:00','hh24:mi'))*24 as "시간"
from dual;

select to_date('2022-06-21 15:00','yyyy-mm-dd hh24:mi') - to_date('2022-06-19 13:00','yyyy-mm-dd hh24:mi') as "일",
(to_date('2022-06-21 15:00','yyyy-mm-dd hh24:mi') - to_date('2022-06-19 13:00','yyyy-mm-dd hh24:mi'))*24 as "시간",
round((to_date('2022-06-21 15:00','yyyy-mm-dd hh24:mi') - to_date('2022-06-19 13:00','yyyy-mm-dd hh24:mi'))*24) as "시간(정수)"
from dual;

--(2-2)분 차이 - 예
select round((to_date('15:00:58','hh24:mi:ss') - to_date('13:00:40','hh24:mi:ss'))*24,2)
from dual;
select round((to_date('15:00:58','hh24:mi:ss') - to_date('13:00:40','hh24:mi:ss'))*24*60,2)
from dual;--120.3분
select round((to_date('15:00:58','hh24:mi:ss') - to_date('13:00:40','hh24:mi:ss'))*24*60,0)
from dual;--소수 첫째자리에서 반올림하여 정수로 표현

--위 결과를 분으로 변환(소수점 버림)
select trunc((to_date('15:00:58','hh24:mi:ss') - to_date('13:00:40','hh24:mi:ss'))*24*60,0)
from dual;

--(2-3)초 차이 -예
select trunc((to_date('15:00:58','hh24:mi:ss') - to_date('13:00:40','hh24:mi:ss'))*24*60*60,0)
from dual;




select (to_date('15:00:58','hh24:mi:ss') - to_date('13:00:40','hh24:mi:ss'))*24
from dual;
--'종료일자'-'시작일자' 빼면 차이 값이 '일 기준'의 수치값으로 변환된다.
select '20220621'-'20220620' --문자 - 문자 => number로 자동형변환(20220621-20220620 = 1)
--고로 날짜 연산이 아님
from dual;

--날짜 차이 계산
--해결법 : to_char(수나 문자, '형식')에 맞게 날짜로 형변환
--to_date(문자, '형식') : '문자' -> '날짜'로 변환
select to_date('2022-06-21','yyyy-mm-dd') - to_date('2022-06-19','yyyy-mm-dd')
from dual;

select to_date('2022-06-21') - to_date('2022-06-19')
from dual;

select 20220621, to_date(20220621,'yyyy-mm-dd')
from dual;



/*
 * 형변화 함수 124p
 * 
 * 		to_char() ->		<- to_char(날짜)
 * 숫자					문자					날짜
 * 		<-to_number(문자)		to_date(문자) ->
 */





/*
 * to_char(숫자나 날짜,'형식') : 수나 날짜를 형식에 맞게 문자로 변환
 * 
 * 날짜와 관련된 형식
 * yyyy : 연도 4자리, yy : 연도 2자리
 * mm : 월 2자리 수로, mon : 월을 '알파벳'으로(jan,feb,mar,apr)
 * dd : 일 2자리 수로 변환, D:요일을 숫자로 표현(일 = 1)
 * day : 요일 표현(월요일) DY : 요일을 약어로 표현(월)
 * 
 * 시간과 관련된 형식
 * AM 또는 PM : 오전 AM, 오후 PM 시각 표시
 * A.M. 또는 P.M. : 오전 AM, 오후 PM 시각 표시
 * 4가지 다 같은 결과 (12시 이전은 오전출력됨, 12시 이후는 오후 출력됨)
 * HH 또는 HH12 : 시간(1~12시로 표현)
 * hh24 : 24시간으로 표현(0~23)
 *        
 * MI
 * SS
 */



select ename, hiredate,
to_char(hiredate, 'yy-mm') as "2자리 년도만",
to_char(hiredate, 'yyyy/mm/dd day dy') as "날짜와 요일",
to_char(hiredate, 'yyyy') as "년도만",
to_char(hiredate, 'mm') as "달만",
to_char(hiredate, 'dd') as "일만",
to_char(hiredate, 'd') as "요일만",--1:일~7:토
to_char(hirddate,'day') as "요일"
--오늘날짜를
select
to_char(sysdate, 'YYYY/MM/DD DAY,HH'),
to_char(sysdate, 'YYYY/MM/DD DAY,AM HH'), --am 또는 pm + hh
to_char(sysdate, 'YYYY/MM/DD DAY,P.M. HH'),
to_char(sysdate, 'YYYY/MM/DD DAY,P.M. HH24'),
to_char(sysdate, 'hh24') as "시간만-24시간 기준",
to_char(sysdate, 'hh') as "시간만-12시간 기준",
to_char(sysdate, 'mi') as "분만",
to_char(sysdate, 'ss') as "초만"
from dual;

/*
 * 숫자와 관련된 형식
 * 0 : 자릿수를 나타내며 자릿수가 맞지 않을 경우 '0으로 채움'
 * 9 : 자릿수를 나타내며 자릿수가 맞지 않을 경우 '채우지 않음'
 * L : 각 지역별 통화기호를 앞에 표시(예)대한미국 원 (단, 달러는 직접 앞에 $ 붙여야함)
 * . : 소숫점 표시
 * , : 천 단위 자리 표시
 */
select
to_char(1234,'L000,000'),
to_char(1234,'L999,999'),
to_char(1234.5,'L000,000.00'),
to_char(1234.5,'L999,999.99')
from dual;

/*
 * 10진수 10인 수를 -> 16진수 문자로 변환
 * 이때 테스트 할 수 있는 수는 10진수 0~15
 */
select to_char(10,'x'),
to_char(11,'x'),
to_char(15,'x'),
to_char(0,'x'),
to_char(16,'xx')
from dual;

select
to_char(255,'x'),--## 자릿수가 부족하다는 뜻
to_char(255,'xx')
from dual;

/*
 * 16진수 문자(0~F) -> 10진수로 변환
 */
select
to_number('A','X'),
to_number('ff','Xx')
from dual;

/*
 * 대부분 사용하는 to_number()의 용도는 단순히
 * '10진수 형태의 문자'를 숫자로 변환하는데 사용됨
 */
select
to_number('0123'),
to_number('12.34'),
to_number('가')--error
from dual;
--to_number('10진수 형태의 문자','형식') : 10진수 문자를 수로 형변환
select
to_number('0123'),
to_number('0123.4')
from dual;
select
--to_number('10,100')--,
to_number('10,100','99999'),--10100
to_number('10,100','99,999')
from dual;

select 100000 - 50000
from dual;

select 100,000 - 50,000
from dual;

select '100000' - '50000'
from dual; --10진수 문자는 수로 자동형변환되어 연산됨

select '100000' - 50000
from dual;

select '100,000' - '50,000'
from dual;--순수한 10진수가 아님 error!
--[오류 해결법]
select to_number('100,000','999,999') - to_number('50,000','999,999')
from dual;
--천단위 구분쉼표 생략
select to_number('100,000','999999') - to_number('50,000','999999')
from dual;

/*
 * 참고 : java에서 "문자열"->수로 변환 할때는
 * int num1 = Integer.parseInt("0123");
 * int num2 = Integer.parseInt("가");--error
 * 
 * double num3 = Double.parseDouble("12.34");
 */

/*
 * 3.to_date(수나 '문자','형식') : 수나 '문자'를 날짜형으로 변환
 */

select ename, hiredate
from EMPLOY
where hiredate = 19810220; --error

select ename, hiredate, to_date(19810220,'yyyymmdd')
from EMPLOY
where hiredate = to_date(19810220,'yyyymmdd');

select ename, hiredate, to_date(19810220,'yyyy/mm/dd')
from EMPLOY
where hiredate = to_date(19810220,'yyyy/mm/dd');

select ename, hiredate, to_date(19810220,'yyyy#mm#dd')
from EMPLOY
where hiredate = to_date(19810220,'yyyy#mm#dd');

select ename, hiredate, to_date(19810220,'yyyy년mm월dd')
from EMPLOY
where hiredate = to_date(19810220,'yyyy년mm월dd');

/*
 * 일반함수 - 북스 130p~
 * 
 * null 은 연산과 비교를 하지 못함
 * 
 * null 처리하는 함수들
 * 1. NVL(값1, 값2) : 값1이 null이 아니면 값1에 저장된 값 그대로, 
 * 							null이면 값2로
 * 		주의 : 값1과 값2는 반드시 데이터 타입이 일치해야 함
 * 		NVL(hiredate, '2022/06/24') : 둘 다 date 타입으로 일치
 * 		NVL(job, 'MANAGER') : 둘 다 문자타입으로 일치
 * 
 * 2. NVL2(값1, 값2, 값3) : 
 * 		(값1, 값1이 null이 아니면 값2, 값1이 null이면 값3)
 * => 1과 차이점 : null이 아닐 때 대체할 값을 정할 수 있다.
 * 
 * 3. NULLIF(값1, 값2) 두 값이 같으면 null, 다르면 '첫번째 값'을 반환
 */
ALTER TABLE employ RENAME COLUMN commision TO commission;

select ename, salary, commission, salary*12+NVL(commission,0) as "연봉1",
to_char(salary*12+NVL(commission,0),'L999,999,999') as "연봉2",
to_char(salary*12+NVL2(commission,salary*12,salary*12),'L999,999,999') as "연봉3"
from EMPLOY;

select NULLIF('A','A'), NULLIF('A','B')
from dual;

/*
 * coalesce(인수, 인수, 인수....)
 * 
 * 사원 테이블에서 커미션이 null이 아니면 커미션을 출력,
 * 				커미션이 NULL이면 급여(-salary)가 null이 아니면 급여를 출력,
 * 				커미션과 급여 모두 null이면 0 출력
 */

select ename, salary, commission, coalesce(commission, salary,0)
from EMPLOY;

/*
 * java에서는
 * if(commission != null) commission 출력
 * else if(salary != null) salary 출력
 * else 0 출력
 */

/*
 * 사원테이블로 부터 부서 이름을 오름차순 정렬하여 출력
 * 방법 1 decode()함수 사용
 * switch~case문과 비슷함 
 * 
 * switch(dno){
 * case 10 : 'ACCOUNTING' 출력; break;
 * case 20 : 'RESEARCH' 출력; break;
 * case 30 : 'SALES' 출력; break;
 * case 40 : 'OPERATIONS' 출력; break;
 * }
 */

select *
from employ;

select ename, dno,
decode(dno, 10,'ACCOUNTING',
			20, 'RESEARCH',
			30, 'SALES',
			40, 'OPERATIONS',
			'기본') as dname
from EMPLOY
order by dno asc;

/*
 * 방법 2 case~end; 사용 (java에서 if ~ else if ~ ....else 문과 비슷)
 * 주의 : case~end 사이에 , 없음
 * decode()함수에서 사용하지 못하는 비교연산자 중 =(같다) 제외한 
 * 			나머지 비교연산자(>=, <=, <,>,!=)를 사용하고 싶을때
 */
select ename, dno,
CASE 
	when dno = 10 then 'ACCOUNTING'
	when dno = 20 then 'RESEARCH'
	when dno = 30 then 'SALES'
	when dno = 40 then 'OPERATIONS'
	else'기본' 
	end as dname
from EMPLOY
order by dno asc;
/*
 * 방법3 사원테이블과 부서테이블에는 둘다 부서번호가 있다.
 * 사원테이블에는 부서번호만 있고 부서테이블에는 부서번호와 부서이름이 있음
 */

select * from DEPARTMENT;

select * 
from EMPLOY e  JOIN DEPARTMENT
on e.dno = DEPARTMENT.dno
order by e.dno;

select ename, EMPLOY.dno, dname
from EMPLOY JOIN DEPARTMENT
on EMPLOY.dno = DEPARTMENT.dno
order by EMPLOY.dno;

select ename, EMPLOY.dno, dname
from EMPLOY, DEPARTMENT
where EMPLOY.dno = DEPARTMENT.dno
order by EMPLOY.dno;
---------------------------------------------------------------------
--[교제에 없는 내용]
/*
 * 자동 형변환
 * 
 */
select '100' + 200 from dual;
--300(문자 '100'이 숫자 100으로 자동 형변환)

--문자 2개 연결
select concat(100,'200') from dual;
--100200(숫자 100이 문자'100'으로 자동 형변환 되어 연결됨)

--문자 여러개 연결
select 100||200||'300'||'400' from dual;

select ename
from employ
where eno = '7369';
--eno가 number(4) 이므로 문자 '7369'를 number로 자동 현변환 후 비교

select ename
from employ
where eno = cast('7369' as number(4));--강제 형변환
--많이 사용하지는 않지만, cast 함수를 사용하면 타입이 맞지 않아 발생하는 에러를 방지할 수 있다.

/*
 * cast() : 데이터 형식 변환 함수
 * 			데이터 형식을 실시간으로 변환하는데 사용됨
 */

select avg(salary) as "평균 월급" from EMPLOY;
--결과가 실수

/*
 * 1.1 실수로 나온 결과를 '전체 자릿수 6자리 중 소수점 이하 2자리까지 표현(3째자리에서 반올림)'
 */

select cast(avg(salary)as number(6,2)) as "평균 월급"
from employ;

select round(avg(salary),2) as "평균 월급"
from employ;

--데이터 형식을 실시간으로 변환(예)
select  CAST(ENAME AS CHAR(20)),
		LENGTH(ENAME),
		LENGTH(CAST(ENAME AS CHAR(20)))
from EMPLOY;
--RUN SQL COMMAND LINE
--DESC EMPLOY
--결과 ENAME의 데이터 형식은 변하지 않음
--생성시 데이터형식으로 유지됨

/*
 * 1.2 실수로나온 결과를 '정수로 보기 위해서'
 */
select cast(avg(salary))as number(6)) as "평균 월급"
from employ;

select TRUNC(avg(salary),0)as number(6)) as "평균 월급"
from employ;

--2. 다양한 구분자를 날짜 형식으로 변경가능()
SELECT CAST('2022%06%27', AS DATE) FROM DUAL;

--3.쿼리의 결과를 보기 좋도록 처리할 때
SELECT SALARY + NVL(COMMISSION,0) AS "월급 + 커미션"
FROM EMPLOY;

SELECT CAST(NVL(SALARY,0)AS CHAR(7)) || '+'
||CAST(NVL(COMMISSION,0) AS CHAR(7)) || '=' AS "월급 + 커미션",
NVL(SALARY,0) + NVL(COMMISSION,0) AS "TOTAL"
FROM EMPLOY;

--테스트 : 사원번호 7369의 급여를 800으로 수정
UPDATE EMPLOY 
SET SALARY = 800
WHERE ENO = 7369;

SELECT SALARY
FROM EMPLOY
WHERE ENO = 7369;


select distinct job from employ;

select ename, job, salary,
	decode(job,
	'ANALYST', SALARY + 200,
	'SALESMAN', SALARY + 180,
	'MANAGER', SALARY + 150,
	'CLERK', SALARY + 100)
	AS "UPDATE"
from employ
order by job;

select * from employ;

select eno, ename, NVL2(manager, manager, 0) as "manager"
from employ;

SELECT TRUNC(SYSDATE - TO_DATE('2022/01/01')) 
FROM DUAL;

SELECT HIREDATE, TO_CHAR(HIREDATE,'YY/MM/DD/DY') 
FROM EMPLOY;

SELECT ENAME, ENO FROM EMPLOY
WHERE MOD(ENO,2) = 0;

SELECT SUBSTR(TO_CHAR(HIREDATE,'YYYY/MM/DD'),6,2) FROM EMPLOY;

SELECT * FROM EMPLOY
WHERE SUBSTR(TO_CHAR(HIREDATE,'YYYY/MM/DD'),6,2) = '04';




