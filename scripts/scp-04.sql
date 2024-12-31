/*
 * Exclusão Lógica
 * 
 * 1) Alternativa: Criar 2 colunas `deleted_at` (timestamp) e `deleted_status` (boolean)
 *    para indicar que o registro foi logicamente excluído. Contudo, devido à natureza
 *    da tabela (matrículas), observamos que aproximadamente 90% dos registros
 *    teriam a coluna `deleted_at` vazia (NULL), o que apresenta alguns desafios:
 *   
 *    a) Desperdício de Espaço:
 *       Embora valores NULL não ocupem espaço significativo diretamente, 
 *       eles ainda requerem algum armazenamento adicional para gerenciar o estado do campo.
 *       Em tabelas grandes, isso pode aumentar o tamanho da tabela desnecessariamente.
 * 
 *    b) Impacto nos Índices:
 *       Índices geralmente ignoram valores NULL, o que significa que consultas que 
 *       filtram especificamente por NULL ou verificam a presença de valores não são 
 *       otimizadas pelos índices padrão.
 * 
 *    c) Uso de Índices Parciais:
 *       Criar índices parciais (e.g., `WHERE coluna IS NOT NULL`) pode mitigar esse problema,
 *       mas tais índices seriam úteis apenas para os 10% dos registros que possuem valores.
 * 
 * 2) Alternativa: Criar 2 tabelas, mantendo uma espécie de "arquivo" dos registros
 *    logicamente excluídos.
 * 
 *    a) Facilidade de Implementação:
 *       O ORM das aplicações poderia executar automaticamente o comando DELETE,
 *       e uma trigger no banco de dados moveria os registros excluídos para uma 
 *       tabela de arquivo (e.g., `enrollment_archived`).
 * 
 *    b) Consulta a Registros Excluídos:
 *       Buscar registros excluídos se torna mais simples, pois esses registros
 *       estariam em uma tabela separada, o que facilita a organização e manutenção.
 * 
 *    Exemplo abaixo:      
 * 
 */


CREATE TABLE enrollment_archived (
    id BIGINT not null,
	enrollment_uuid UUID DEFAULT uuid_generate_v4(),
    institution_id INTEGER,
    person_id INTEGER not null,
    enrollment_date DATE not null,
    status VARCHAR(20) not null,
    delete_at timestamp not null
);

 -- Insere o registro na tabela enrollment_archived com a data/hora de exclusão
CREATE OR REPLACE FUNCTION tf_archive_enrollment()
RETURNS TRIGGER AS $$
BEGIN
    -- Insere o registro na tabela enrollment_archived com a data/hora de exclusão
    INSERT INTO enrollment_archived (
        id,
        enrollment_uuid,
        institution_id,
        person_id,
        enrollment_date,
        status,
        delete_at
    )
    VALUES (
        OLD.id,
        OLD.enrollment_uuid,
        OLD.institution_id,
        OLD.person_id,
        OLD.enrollment_date,
        OLD.status,
        NOW()
    );

    -- Permite que o registro seja excluído da tabela original
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger que chama a função ao excluir um registro da tabela enrollment
CREATE TRIGGER tr_archive_enrollment
BEFORE DELETE ON enrollment
FOR EACH ROW
EXECUTE FUNCTION tf_archive_enrollment();