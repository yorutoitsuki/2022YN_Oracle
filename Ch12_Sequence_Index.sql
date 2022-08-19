/*
 * 1. 시퀀스 생성
 * 시퀀스 : 테이블 내의 유일한 숫자를 자동 생성
 * 오라클에서는 데이터가 중복된 값을 가질 수 있으나
 * '개체 무결성'을 위해 항상 유일한 값을 갖도록 하는 '기본키'를 두고 있음
 * 시퀀스는 기본키가 유일한 값을 반드시 갖도록 자동생성하여 사용자가 직접 생성하는 부담감을 줄임
 */

CREATE SEQUENCE 시퀀스명--시작숫자의 기본값은 증가할 때 MINVALUE, 감소할때 MAXVALUE
[START WITH 시퀀스 시작숫자]--증감숫자가 양수면 증가, 응수면 감소(기본값 : 1)
[MINVALUE 최솟값| NOMINVALUE(기본값)]	--NOMINVALUE(기본값) : 증가일 때 1, 감소일때 -10의 26승 까지
									--MINVALUE 최솟값 : 최솟값 설정, 시작숫자과 같거나 작아야함 MAXVALUE보다는 작아야함
[MAXVALUE 최댓값| NOMAXVALUE(기본값)]	--NOMAXVALUE(기본값) : 증가일 때 10의 27승 까지, 감소일 때 -1 까지
									--MAXVALUE 최댓값 : 최댓값 설정, 시작숫자와 같거나 커야하고 MINVALUE보다는 커야함
[CYCLE | NOCYCLE(기본값)] --CYCLE : 최대값 까지 증가 후 최소값으로 다시 시작
						--NOCYCLE : 최대값 까지 증가 후 그다음 시퀀스를 발급 받으려면 에러 발생
[CACHE N | NOCACHE] --CACHE N : 메모리 상에 시퀀스 값을 미리 할당(기본값은 20)
					--NO CACHE : 메모리 상에 시퀀스 값을 미리 할당하지 않음
[ORDER | NOORDER(기본값)]		--ORDER : 병렬서버를 사용할 경우 요청 순서에 따라 정확하게 시퀀스를 생성하기를 원할때
;							--NOORDER : 단일서버일 경우 이 옵션과 관계없이 정확히 요청 순서에 따라 시퀀스가 생성

/*
 * sequence 시퀀스 생성
 */
CREATE SEQUENCE SAMPLE_TEST;

CREATE SEQUENCE SAMPLE_TEST2
START WITH -99999999999999999999;
INCREMENT BY -10;

SELECT *
FROM USER_SEQUENCES
WHERE SEQUENCE_NAME IN UPPER('SAMPLE_TEST');

/*
 * 1.2 시퀀스를 기본키에 접목하기(295P)
 * 부서 테이블의 기본키인 부서번호는 반드시 유일한 값을 가져야 함
 * 유일한 값을 자동 생성해주는 시퀀스를 통해 순차적으로 증가하는 컬럼값 자동 생성
 */

--실습용 DEPT12테이블 생성
DROP TABLE DEPT12;
CREATE TABLE DEPT12
AS 
SELECT * FROM DEPARTMENT
WHERE 1= 0;
--테이블 구조만 복사(단, 제약조건은 복사 안됨)

--DNO에 기본키 제약조건 추가
ALTER TABLE DEPT12 ADD PRIMARY KEY(DNO);

CREATE SEQUENCE DON_SEQ
START WITH 10
INCREMENT BY 10 NOCYCLE; --NOCYCLE이 기본값 10,20,30,...80,90 (정지)

SELECT * FROM DEPT12

insert into DEPT12 values(DON_SEQ.NEXTVAL,'ACCOUNTING','NEW YORK');
insert into DEPT12 values(DON_SEQ.NEXTVAL,'RESEARCH','DALLAS');
insert into DEPT12 values(DON_SEQ.NEXTVAL,'SALES','CHICAGO');
insert into DEPT12 values(DON_SEQ.NEXTVAL,'OPERATIONS','BOSTON');





























































