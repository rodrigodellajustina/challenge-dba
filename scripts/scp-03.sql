/*
 * Criação de índices para operaçoes 
 * 
 * */


/*Índice para busca de aniversariantes do dia */
--drop index  idx_person_002  

create index idx_person_002 on person (birth_date)
where birth_date is not null





/*Índice para junção entre instituição e tenant*/
-- drop index idx_institution_002
create index idx_institution_002 on institution (tenant_id) 

/*Índice para junção entre cursos e instituição*/
-- drop index idx_course_002
create index idx_course_002 on course (institution_id) 


/*Índice para junção entre matricula e course */
-- drop index idx_enrollment_002
create index idx_enrollment_002 on enrollment (course_id)

/*Índice para junção entre matricula e pessoas */
-- drop index idx_enrollment_003
create index idx_enrollment_003 on enrollment (person_id)

/*Índice para para filtragem de status */
-- drop index idx_enrollment_004
create index idx_enrollment_004 on enrollment (status)

/*Índice para filtragem de data de matricula */
create index idx_enrollment_005 on enrollment (enrollment_date)

/*Índice para filtragem course, pessoa, status*/
create index idx_enrollment_006 on enrollment (status, course_id, person_id)

/*Índice para pesquisa instituição, pessoa, status*/
create index idx_enrollment_007 on enrollment (status, course_id, person_id, enrollment_date)

--Índice GIN para pesquisa no JSONB da tabela person
CREATE INDEX idx_person_003
    ON person USING GIN (metadata jsonb_path_ops);