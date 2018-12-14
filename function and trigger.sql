-- ----------- SCRIPT DE PREPARAÇÃO -----------
DROP SCHEMA IF EXISTS empresaschema CASCADE;
CREATE SCHEMA empresaschema;
SET search_path  = 'empresaschema';
-- departamento
CREATE TABLE empresaschema.departamento (
    dnome character varying(255) NOT NULL,
    dnumero integer PRIMARY KEY
);
-- funcionario
CREATE TABLE empresaschema.funcionario (
    funcionarioid SERIAL PRIMARY KEY,
    nome character varying(255) NOT NULL,
    cpf integer,
    datanasc date,
    sexo character(2),
    salario numeric(10,2) DEFAULT 0.0,
    dnr integer,
    FOREIGN KEY (dnr) REFERENCES departamento(dnumero) ON UPDATE CASCADE ON DELETE CASCADE
);
-- departamento
INSERT INTO empresaschema.departamento (dnome, dnumero) VALUES ('Pesquisa', 3);
INSERT INTO empresaschema.departamento (dnome, dnumero) VALUES ('Administracao',4);
INSERT INTO empresaschema.departamento (dnome, dnumero) VALUES ('Sede_administrativa',1);
INSERT INTO empresaschema.departamento (dnome, dnumero) VALUES ('Inovacao',7);
INSERT INTO empresaschema.departamento (dnome, dnumero) VALUES ('Computacao',5);
-- funcionario
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('James Borg', 888665555, '1957-11-10','M' , 55000, 1);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Jennifer Wallace', 987654321, '2001-06-20', 'F' , 43000, 4);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Franklin Wong', 333445555, '1955-12-08', 'M' , 40000, 5);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('John Smith', 123456789, '1999-01-09','M' , 30000, 5);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Ramesh Narayan', 666884444, '1962-09-15', 'M' , 38000, 5);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Joyce English', 453453453, '1972-07-31', 'F' , 25000, 5);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Ahmad Jabbar', 987987987, '2003-03-29', 'M' , 25000, 4);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Robert Scott', 943775543, '2017-04-21', 'M' , 58000, 1);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Alicia Zelaya', 999887777, '1968-01-19', 'F' , 25000, 4);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Vanessa Borg', 911887776, '1983-12-21', NULL , 10000, 4);
INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Asdrubal Asd', 91188711, '1985-01-18', 'M' , 5000, 4);
-----------------------------------------------
-- 7. Trigger para atributo derivado idade
   -- 7A. Altere a tabela funcionario para adicionar uma coluna idadefunc (integer)
   ALTER TABLE funcionario ADD  COLUMN idadefunc INTEGER;
   -- 7B. Crie uma função chamada "calculaIdade" que receba como parâmetro o cpf do funcionário e retorne um inteiro com a sua idade.
         -- Para calcular a idade utilize a seguinte consulta: select extract(year from age(datanasc)) from funcionario where cpf=<parametro>;
CREATE OR REPLACE FUNCTION calculaIdade (cpfIN integer)
RETURNS integer
AS $$
DECLARE
  idade integer := 0;
BEGIN
  idade:= (SELECT EXTRACT (year from age (datanasc))
  FROM funcionario WHERE cpf = $1);
  RETURN  idade;
END;
$$ LANGUAGE PLPGSQL;
   -- 7C. Crie um comando SQL para testar a função calculaIdade
   SELECT calculaIdade(888665555);
   -- 7D. Crie um comando SQL para apagar a função calculaIdade
   DROP FUNCTION calculaidade (cpf integer);

   -- 7E. Crie um trigger chamada "atualizaIdade" que cada vez que for inserida uma nova tupla ou o campo datanasc
      -- for atualizado, calcule a idade desse funcionário a partida da sua data de nascimento (datanasc) e
      -- atualize o campo idadefunc deste funcionário com esse valor calculado.
      -- Ao atualizar o campo exiba uma mensagem com o nome do funcionário, sua data de nascimento e a idade calculada
      -- Utilize a função "calculaIdade" criada no item anterior.
      CREATE OR REPLACE FUNCTION atualizaIdade ()
      RETURNS TRIGGER
      AS $$
      DECLARE
        idade integer := 0;
      BEGIN
        idade:= calculaIdade(NEW.cpf);
        UPDATE funcionario SET idadefunc = idade WHERE cpf = NEW.cpf;
        RAISE NOTICE 'Funcionario: %, Data de Nascimento: %, Idade: %.', NEW.nome, NEW.datanasc, idade;
        RETURN  NEW;
      END;
      $$ LANGUAGE PLPGSQL;


   CREATE TRIGGER atualizaIdade AFTER INSERT OR UPDATE OF datanasc ON funcionario
	 FOR EACH ROW EXECUTE PROCEDURE atualizaIdade();
   -- 7F. Crie comandos SQL para testar o trigger atualizaIdade
   INSERT INTO empresaschema.funcionario (nome, cpf, datanasc,sexo, salario, dnr) VALUES ('Sandra', 068239891, '1999-11-18','F' , 100000, 1);
   UPDATE funcionario SET datanasc = '1997-05-06' WHERE nome = 'Sandra';
   -- 7G. Crie uma função "bdconsistenteatualizaIdade" que deixe o banco de dados consistente, calculando e atualizando a idade de todos os funcionários
   CREATE OR REPLACE FUNCTION bdconsistenteatualizaIdade()
   RETURNS VOID
   AS $$
   DECLARE

   BEGIN
      UPDATE funcionario f SET idadefunc = calculaIdade(f.cpf) WHERE CPF=f.cpf;
   END;
   $$LANGUAGE PLPGSQL;
   -- 7H. Execute a função bdconsistenteatualizaIdade para atualizar a idade de todos os funcionários
   SELECT bdconsistenteatualizaIdade();
   -- 7I. Crie um comando SQL para apagar o trigger atualizaIdade
   CREATE TRIGGER atualizaIdade ON funcionario CASCADE;
-- ----------------------------------------
-- 8. Trigger para atributo derivado total salário

   -- 8A. Altere a tabela departamento para adicionar um atributo chamado totalsal numeric(10,2) default 0.
   ALTER TABLE departamento ADD COLUMN totalsal NUMERIC(10,2) DEFAULT 0;
   -- 8B. Criar um trigger chamado "atualizatotalsal" que atualize departamento.totalsal
   -- toda vez que houver a modificação do salario de algum funcionario (inserção, atualização ou remoção).
  CREATE OR REPLACE FUNCTION atualizatotalsal ()
  RETURNS TRIGGER AS $$
  DECLARE
  	tsalario NUMERIC (10,2);
  BEGIN
  	tsalario := (SELECT SUM(salario) FROM funcionario  WHERE NEW.dnr = dnr);
	UPDATE departamento SET totalsal = tsalario WHERE NEW.dnr = dnumero;
	RAISE NOTICE 'Nome: %, Salario antigo: %, Salario Novo: %.', NEW.nome, OLD.salario, NEW.salario;
	 RETURN NEW;
  END;
  $$ LANGUAGE PLPGSQL;
  CREATE TRIGGER atualizatotalsal AFTER INSERT OR DELETE OR UPDATE OF salario ON funcionario
  FOR EACH ROW EXECUTE PROCEDURE atualizatotalsal();
   -- 8C. Crie comandos SQL para testar o trigger atualizaIdade
  UPDATE funcionario SET salario = 5000 WHERE  nome = 'Sandra';
   -- 8D. Para deixar o banco de dados consistente, crie uma função "bdconsistenteatualizatotalsal" que atualize o salario total de todos os departamentos a partir do salário dos funcionários que trabalham no departamento em questão.
CREATE FUNCTION bdconsistenteatualizatotalsal ()
RETURNS VOID AS $$
DECLARE
BEGIN
	UPDATE departamento  d SET totalsal = (SELECT sum(salario) FROM funcionario WHERE dnr = d.dnumero);

END;
$$ LANGUAGE PLPGSQL;

DROP FUNCTION bdconsistenteatualizatotalsal();
   -- 8E. Execute a procedure para atualizar os valores totais de salário da tabela departamento
   SELECT bdconsistenteatualizatotalsal();
   SELECT * from departamento order by dnumero asc;
   -- 8F. Crie um comando SQL para apagar o trigger atualizaIdade
DROP TRIGGER atualizatotalsal on funcionario;