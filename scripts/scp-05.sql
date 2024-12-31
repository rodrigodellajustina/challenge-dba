/*
 * Atividade 5
 * 
 * Construa uma consulta que retorne o número de matrículas por curso em uma determinada 
 * instituição.Filtre por tenant_id e institution_id obrigatoriamente. 
 * Filtre também por uma busca qualquer -full search - no campo metadata da tabela person que 
 * contém informações adicionais no formato JSONB. 
 * Considere aqui também a exclusão lógica e exiba somente registros válidos.
 * 
 */


select 
	course.id            AS course_id,
	course.name          AS course_name,
	COUNT(enrollment.id) AS total_enrollments
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
	institution.id = :institution_id -- parametro de qual instituicao
	AND to_tsvector('portuguese', p.metadata:text) @@ to_tsquery('portuguese', :parameterQueryfts)
GROUP BY course.id, course.name
ORDER BY course.name;	


/*
 * No SQL acima, a busca pela tenant é desnecessária, pois:  
 * - O filtro pelo **tenant** já é realizado automaticamente por meio do **RLS (Row-Level Security)**, 
 *   assegurando que o usuário acesse apenas os registros vinculados ao seu **TENANT**.  
 * 
 * - Não há necessidade de exclusão lógica, uma vez que todos os registros excluídos são movidos 
 *    para a entidade  enrollment_archived. Assim, somente registros válidos permanecem 
 *    na tabela enrollment.  
 */

