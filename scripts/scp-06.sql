/*
 * Atividade 6
 * 
 * Construa uma consulta que retorne os alunos de um curso em uma tenant e institution específicos. 
 * Esta é uma consulta para atender a requisição que tem por objetivo alimentar uma listagem 
 * de alunos em determinado curso. Tenha em mente que poderá retornar um número grande de 
 * registros por se tratar de um curso EAD. Use boas práticas. Considere aqui também a exclusão lógica e 
 * exiba somente registros válidos.
 *  
 */


select * from person

select 
	person.id            AS person_id,
	person.name          AS person_name,
	person.birth_date    as person_birth_date,
	person.metadata      as person_metadata
from 
	enrollment 
join
	person on (enrollment.person_id = person.id)
join
	course on (enrollment.course_id = course.id)
join
    institution on (course.institution_id = institution.id)
join
	tenant  on (institution.tenant_id = tenant.id)
where
	institution.id = :institution_id -- parametro instituicao
    and course.id  = :course_id  -- parametro course
limit 100
offset ((:pagina - 1) * 100); -- a cada requisicao incrementa 0, 100, 200, 300
	


/*
 * No SQL acima, a busca pela tenant é desnecessária, pois:  
 * - O filtro pelo **tenant** já é realizado automaticamente por meio do **RLS (Row-Level Security)**, 
 *   assegurando que o usuário acesse apenas os registros vinculados ao seu **TENANT**.  
 * 
 * - Não há necessidade de exclusão lógica, uma vez que todos os registros excluídos são movidos 
 *    para a entidade  enrollment_archived. Assim, somente registros válidos permanecem 
 *    na tabela enrollment.  
 * 
 *  - Retorna de 100 em 100 registros a cada requisicao e incremento de pagina
 */

