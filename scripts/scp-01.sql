/*
 * /*Vídeo em README do repositório*/
 * https://youtu.be/CSTZSZ7pbcw 
 *
 *
 * Existem três alternativas principais para implementar um ambiente multi-tenant 
 * com isolamento de dados em uma única base de dados:
 *
 * 1) **Uso de RLS (Row-Level Security) no PostgreSQL**  
 *    O RLS permite definir políticas de segurança no nível das linhas de uma tabela. 
 *    Ele restringe ou filtra automaticamente os dados que determinados usuários, 
 *    regras ou aplicações podem acessar, com base em critérios definidos diretamente no banco de dados.
 *
 *    **Vantagens:**
 *    a) As políticas de segurança são implementadas no banco de dados, 
 *       garantindo que acessos inadequados sejam bloqueados, mesmo em caso de 
 *       falhas no código da aplicação.
 *
 *    b) Elimina a necessidade de adicionar filtros manuais, como `WHERE tenant_id = ...`, 
 *       em todas as consultas. Isso reduz a complexidade do código e diminui a chance de erros.
 *
 *    c) O RLS delega a responsabilidade de aplicação das restrições ao banco de dados, 
 *       reduzindo a carga na camada da aplicação e facilitando o gerenciamento de um grande número de clientes.
 *
 * 2) **Multi-Esquema**  
 *    Um esquema é um namespace lógico dentro de um banco de dados, capaz de conter tabelas, 
 *    views, índices e outros objetos. Diferentes esquemas podem ter tabelas com os mesmos nomes sem conflitos.
 *    No contexto multi-tenant, cada tenant recebe seu próprio esquema, o que garante isolamento lógico dos dados.
 *
 *    **Desvantagem:**  
 *    A administração de múltiplos esquemas se torna desafiadora à medida que o número de tenants cresce, 
 *    aumentando a complexidade operacional.
 *
 * 3) **Ambiente distribuído com Citus PostgreSQL (escala horizontal)**  
 *    O Citus PostgreSQL é recomendado para aplicações multi-tenant devido à sua capacidade 
 *    de sharding (distribuição) eficiente e escalabilidade horizontal. Ele é projetado para 
 *    lidar com grandes volumes de dados e atender simultaneamente a várias aplicações ou clientes, 
 *    mantendo o desempenho e o isolamento.
 *
 * **Decisão:**  
 * Para o caso em questão, utilizaremos o RLS (Row-Level Security) devido às suas vantagens em termos de 
 * simplicidade e segurança. A implementação será realizada com as seguintes especificações:
 * - PostgreSQL 17
 * - Extensão `uuid-ossp`
 */



--drop table tenant

-- Criação do tentant no esquema public
-- 

CREATE TABLE tenant (
    id serial primary key,    
    tenant_uuid UUID DEFAULT uuid_generate_v4(),
    name VARCHAR(100) not null,
    description VARCHAR(255) not null
);

CREATE UNIQUE INDEX idx_tenant_001_unique_tenant_uuid ON tenant (tenant_uuid);

INSERT INTO tenant (name, description)
VALUES
    ('Tenant A', 'Descrição do Tenant A'),
    ('Tenant B', 'Descrição do Tenant B'),
    ('Tenant C', 'Descrição do Tenant C');


-- Ativar Row-Level Security na tabela
ALTER TABLE tenant ENABLE ROW LEVEL SECURITY;

-- Criar uma política de isolamento por tenant_id
-- Garantir que cada client dependendo da variavel de ambiente app.current_tenant consiga realizar leitura apenas de seus dados.
CREATE POLICY rls_001_tenant_isolation ON tenant
USING (tenant_uuid = current_setting('app.current_tenant')::UUID);

-- Forçar que RLS seja respeitado, inclusive por superusuários
ALTER TABLE tenant FORCE ROW LEVEL SECURITY;  


-- permissão para usuário 
GRANT SELECT, INSERT, UPDATE, DELETE ON tenant to tenant_a;
GRANT SELECT, INSERT, UPDATE, DELETE ON tenant TO tenant_b;


select * from tenant t 

--atrelando ao usuário ao variável de app current_tenant com uuid do tentant
--pode ser automatizado no momento da criação de um tenant 
ALTER ROLE tenant_a SET app.current_tenant = 'e0da5ece-186f-4bd4-b778-e2ca69f41841';
ALTER ROLE tenant_b SET app.current_tenant = 'c95a8ad1-c9c7-46ec-ae82-a2e78d5ff74a';

/*Vídeo em README do repositório*/