/*
 * Particionamento
 * 
 * Maneira de escolher o particionamento de uma tabela como a enrollment dependerá do uso esperado dos dados e 
 * das consultas mais comuns que serão realizdas. Algumas colunas se destacam como candidatas naturais para particionamento:
 * 
 * a) enrollment_date, suas consultas frequentemente se baseiam em datas, como relatórios mensais ou anuais, 
 *     particionar por intervalo de datas normalmente se trabalha sempre com dados mais atuais do ano anterior ou do ano atual,
 *     dessa forma auxiliaria em muitas querys que fazem referência a coluna
 * 
 * Abaixo exemplo de como ficaria a tabela.
 * 
 * */

drop table enrollment

-- Alteração da tabela para ser particionada
CREATE TABLE enrollment (
    id BIGSERIAL not null,
    enrollment_uuid UUID DEFAULT uuid_generate_v4(),
    course_id INTEGER,
    person_id INTEGER not null,
    enrollment_date DATE not null,
    status VARCHAR(20) not null,
    PRIMARY KEY (id, enrollment_date),
    FOREIGN KEY (course_id) REFERENCES course(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
) PARTITION BY RANGE (enrollment_date);

-- Criação de partições específicas (poderá ser automatizada)
CREATE TABLE enrollment_2025 PARTITION OF enrollment
FOR VALUES FROM ('2025-01-01') TO ('2025-12-31');

CREATE TABLE enrollment_2024 PARTITION OF enrollment
FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');

CREATE TABLE enrollment_2023 PARTITION OF enrollment
FOR VALUES FROM ('2023-01-01') TO ('2023-12-31');

-- Partição padrão para capturar datas fora dos intervalos definidos
CREATE TABLE enrollment_default PARTITION OF enrollment
DEFAULT;