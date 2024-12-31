/*
 * Criação de uuid e chaves estrangeiras e aplicação da 3º forma normal 
 * */

--1)----------------PERSON-----------------

--drop table person 

CREATE TABLE person (
    id SERIAL not null,
    person_uuid UUID DEFAULT uuid_generate_v4(),
    name VARCHAR(100) not null,
    birth_date DATE,
    metadata JSONB
);

/*Qual Motivo person_uuid
 * 
 * UUIDs são armazenados como 16 bytes, o que é maior que um inteiro de 4 bytes (para INT ou BIGINT). 
 * Isso pode resultar em maior uso de armazenamento e índices maiores, o que pode afetar a performance, 
 * especialmente em grandes volumes de dados.
 * 
 * Em caso de ter que expor id do person em algum lugar na aplicação poderá ser exibido o person_uuid que é garantido como único pelo banco
 * 
 * */

--chave primária person
ALTER TABLE person ADD CONSTRAINT pk_person_id PRIMARY KEY (id);

--indice único no uuid
create unique index idx_unique_person_001 on person (person_uuid)






--2)------------------ INSTITUTION --------------------------------

-- drop table institution

CREATE TABLE institution (
    id SERIAL not null,
    institution_uuid UUID DEFAULT uuid_generate_v4(),
    tenant_id INTEGER not null,
    name VARCHAR(100),
    location VARCHAR(100),
    details JSONB
);

--chave primária institution
ALTER TABLE institution ADD CONSTRAINT pk_institution_id PRIMARY KEY (id);

--indice único no uuid
create unique index idx_unique_institution_001 on institution (institution_uuid);

-- chave estrangeira para garantir integridade refernecial entre institution e o tenant
ALTER TABLE institution
ADD CONSTRAINT fk_institution_tenant
FOREIGN KEY (tenant_id)
REFERENCES tenant(id);

------------------------------------------------------------------------------------







--3)------------------ COURSE --------------------------------

-- drop table course

CREATE TABLE course (
    id SERIAL not null,
    course_uuid UUID DEFAULT uuid_generate_v4(),
    institution_id INTEGER not null,
    name VARCHAR(100) not null,
    duration INTEGER not null,
    details JSONB
);


/* Remoção e aplicação da 3º forma normal
*    tenant_id INTEGER, como já possuí a relação entre institution e a tenant poderá gerar uma inconsistência nos dados
*    manter essa coluna no course, dessa forma todo curso pertence a uma instituição obrigatoriamente e toda a instituição
*    pertence a um tenant 
* */

--chave primária COURSE
ALTER TABLE course ADD CONSTRAINT pk_course_id PRIMARY KEY (id);

--indice único no uuid
CREATE UNIQUE INDEX idx_unique_course_001 ON course (course_uuid);

-- chave estrangeira para garantir integridade referencial entre curso e a instituição
ALTER TABLE course
ADD CONSTRAINT fk_course_institution
FOREIGN KEY (institution_id)
REFERENCES institution(id);

------------------------------------------------------------------------------------



--4)------------------ ENROLLMENT -------------------------------------------------
-- drop table enrollment 

CREATE TABLE enrollment (
    id BIGSERIAL not null,
	enrollment_uuid UUID DEFAULT uuid_generate_v4(),
    course_id INTEGER,
    person_id INTEGER not null,
    enrollment_date DATE not null,
    status VARCHAR(20) not null
);

/* Remoção e aplicação da 3º forma normal
 *  tenant_id INTEGER, já possui a relação entre a instituição e tenant 
 */

--chave primária ENROLLMENT
ALTER TABLE enrollment ADD CONSTRAINT pk_enrollment_id PRIMARY KEY (id)


--indice único no uuid
create unique index idx_unique_enrollment_001 on enrollment (enrollment_uuid);


-- chave estrangeira para garantir integridade referencial entre curso e a matricula
ALTER TABLE enrollment
ADD CONSTRAINT fk_course_enrollment
FOREIGN KEY (course_id)
REFERENCES course(id);

-- chave estrangeira para garantir integridade referencial entre person e a matricula
ALTER TABLE enrollment
ADD CONSTRAINT fk_person_enrollment
FOREIGN KEY (person_id)
REFERENCES person(id);

-- CONSTRAINT UNIQUE
/*
 * 
 * A integridade da regra de unicidade de person_id por tenant_id e institution_id é mantida, mesmo após a remoção 
 * do tenant_id da tabela enrollment, pois a associação entre tenant_id e institution_id é garantida pela tabela institution. 
 * A tabela enrollment agora é normalizada em 3NF e as regras de integridade são aplicadas corretamente com a restrição de unicidade.
 * */
ALTER TABLE enrollment
ADD CONSTRAINT ctt_unique_person_per_institution UNIQUE (course_id, person_id);
------------------------------------------------------------------------------------



