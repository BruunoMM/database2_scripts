DROP TABLE NotasVenda CASCADE;
DROP TABLE ItensNota CASCADE;
DROP TABLE Mercadorias CASCADE;
DROP TABLE Cliente CASCADE;
DROP TABLE Funcionario CASCADE;
DROP TABLE CargosFunc CASCADE;
DROP TABLE Departamento CASCADE;
DROP TABLE Cargo CASCADE;
DROP TABLE NotasCompra CASCADE;
DROP TABLE ItensNotaCompra CASCADE;
DROP TABLE Empresas CASCADE;

DROP FUNCTION manda_email();
DROP FUNCTION atualiza_preco();
DROP FUNCTION verificapreco();
DROP FUNCTION verificaestoque();

--CRIAR TABELA MERCADORIAS

CREATE TABLE Mercadorias (
    	NumeroMercadoria integer primary key,
    	Descricao varchar(100),
    	QuantidadeEstoque integer
	);

--CRIAR TABELA CLIENTE
    
	CREATE TABLE Cliente (
    	Codigo integer primary key,
    	Nome varchar(80),
    	Telefone integer,
    	Logradouro varchar(40),
    	Numero integer,
    	Complemento varchar(20),
    	Cidade varchar(20),
    	Estado varchar(2),
    	NumeroContribuinte integer
	);


--CRIAR TABELA NOTASVENDA

	CREATE TABLE NotasVenda (
	Numero integer primary key,
	DataEmissao date,
	FormaPagamento varchar(50),
	CodigoCliente integer,
	CPFVendedor varchar(15),
	
    FOREIGN KEY (CodigoCliente) REFERENCES Cliente(Codigo)
	);

--CRIAR TABELA ITENSNOTA
    
	CREATE TABLE ItensNota (
    	Numero integer,
    	NumeroMercadoria integer,
    	Quantidade integer,
    	ValorUnitario float,
	primary key(Numero,NumeroMercadoria),
           FOREIGN KEY (NumeroMercadoria) REFERENCES Mercadorias(NumeroMercadoria)
	);


--CRIAR TABELA DEPARTAMENTO

CREATE TABLE Departamento(
CodigoDepartamento integer Primary key,
Nome varchar(100),
CPF_Chefe varchar(15)
);

--CRIAR TABELA FUNCIONARIO

CREATE TABLE Funcionario(
CPF varchar(15) Primary key,
Nome varchar(100),
Telefone integer,
Logradouro varchar(40),
Numero integer,
Complemento integer,
Cidade varchar(40),
Estado varchar(2),
CodigoDepartamento integer,
FOREIGN KEY (CodigoDepartamento) REFERENCES Departamento(CodigoDepartamento)
);


--CRIAR TABELA CARGO

CREATE TABLE Cargo(
Codigo integer Primary key,
Descricao varchar(100),
Salario_Base integer
);

--CRIAR TABELA CARGOSFUNC

CREATE TABLE CargosFunc(
CPF varchar(15),
CodigoCargo integer,
DataInicio Date,
DataFim Date,

Primary key(CPF, CodigoCargo),
FOREIGN KEY (CPF) REFERENCES Funcionario(CPF),
FOREIGN KEY (CodigoCargo) REFERENCES Cargo(Codigo)
);

--CRIAR TABELA EMPRESAS

CREATE TABLE Empresas(
id integer Primary key,
Nome varchar(100),
Endereco varchar(100)
);

--CRIAR TABELA NOTASCOMPRA

CREATE TABLE NotasCompra(
Numero integer Primary key,
dataEmissao Date,
FornecedorID integer,

FOREIGN KEY (FornecedorID) REFERENCES Empresas(ID)
);

--CRIAR TABELA ITENSNOTACOMPRA

CREATE TABLE ItensNotaCompra(
Numero integer,
NumeroMercadoria integer,
Quantidade integer,
ValorUnitario integer,

Primary key(Numero, NumeroMercadoria),
FOREIGN KEY (Numero) REFERENCES NotasCompra(Numero ),
FOREIGN KEY (NumeroMercadoria) REFERENCES Mercadorias(NumeroMercadoria)

);


--ALTERA TABELA MERCADORIAS

ALTER TABLE Mercadorias
  ADD EstoqueMin integer,
  ADD EstoqueMax integer,
  ADD PrecoMin float;


--ALTERA TABELA NOTASVENDA

ALTER TABLE NotasVenda
  ADD CPFFuncionario varchar(15),
  ADD FOREIGN KEY (CPFFuncionario) REFERENCES Funcionario(CPF);
  

--MANDA EMAIL

CREATE FUNCTION manda_email()
returns TRIGGER AS $body$
DECLARE qtd integer; min integer;
Begin
	SELECT 	QuantidadeEstoque, EstoqueMin
	INTO		qtd, min
	FROM	mercadorias;
	
	if qtd < min THEN
		--sendEmail();
		raise notice 'email enviado';
	end if;
Return new;
end;
$body$ language plpgsql;
	

CREATE TRIGGER pedido_estoque after INSERT or UPDATE
ON mercadorias FOR each row
EXECUTE PROCEDURE manda_email();

--ATUALIZA PREÇO MIN

CREATE OR REPLACE FUNCTION atualiza_preco()
RETURNS TRIGGER
AS $$
BEGIN
	UPDATE	mercadorias
	SET		PrecoMin = NEW.ValorUnitario
	WHERE 	numeroMercadoria = NEW.numeroMercadoria;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER atualiza_preco AFTER INSERT
ON itensNotaCompra
FOR EACH ROW
EXECUTE PROCEDURE atualiza_preco();

--VERIFICA PREÇO MIN

CREATE FUNCTION verificaPreco()
RETURNS TRIGGER AS $body$
DECLARE valorMin int;
BEGIN
	SELECT 	PrecoMin
	INTO	valorMin
	FROM	mercadorias
	WHERE	NumeroMercadoria = NEW.numeroMercadoria;

	If NEW.valorUnitario < valorMin THEN
        RAISE EXCEPTION 'Preco invalido';
	END IF;
RETURN new;
END;
$body$ language plpgsql;

CREATE TRIGGER verifica_preco BEFORE INSERT
ON ItensNota   
FOR EACH ROW
EXECUTE PROCEDURE verificaPreco();

--VERIFICA ESTOQUE

CREATE FUNCTION verificaEstoque()
RETURNS TRIGGER AS $body$
DECLARE qtdEstoque integer;
BEGIN
	SELECT 	QuantidadeEstoque
	INTO	qtdEstoque
	FROM	mercadorias
	WHERE   numeroMercadoria = NEW.numeroMercadoria;
	
	IF qtdEstoque < NEW.Quantidade THEN
		RAISE EXCEPTION 'Não há estoque suficiente';
	END IF;
RETURN new;
END;
$body$ language plpgsql;

CREATE TRIGGER verifica_estoque BEFORE INSERT or UPDATE
ON itensNota FOR EACH ROW
EXECUTE PROCEDURE verificaEstoque();

--VERIFICA ESTOQUE MAXIMO

CREATE OR REPLACE FUNCTION verificaEstoqueMax()
RETURNS TRIGGER AS $body$
DECLARE qtdEstoque int;
DECLARE qtdMax int;
BEGIN
	SELECT 	EstoqueMin, EstoqueMax
	INTO		qtdEstoque, qtdMax 
	FROM	mercadorias;
	
	IF qtdEstoque + NEW.Quantidade > qtdmax THEN
		RAISE EXCEPTION 'Ultrapassa estoque maximo';
	END IF;
Return new;
END;
$body$ language plpgsql;

CREATE TRIGGER verifica_estoque_max BEFORE INSERT or UPDATE
ON itensNotaCompra FOR EACH ROW
EXECUTE PROCEDURE verificaEstoqueMax();





--------------------------INSERÇÕES----------------------------------

--MERCADORIAS
INSERT INTO mercadorias (numeromercadoria, descricao, quantidadeestoque, estoquemin, estoquemax, precomin)
VALUES (1, 'Queijo', 10, 5, 20, 3);

--CLIENTE
INSERT INTO cliente (codigo, nome, telefone, logradouro, numero, complemento, cidade, estado, numerocontribuinte)
VALUES (1, 'Renan', 12345, 'Rua XX', 20, null , 'Rio', 'RJ', 123);

--NOTASVENDA
INSERT INTO notasvenda (numero, dataemissao, formapagamento, codigocliente, cpfvendedor, cpffuncionario)
VALUES (1, null, 'Cartao', 1, null, null);

--ITENSNOTA
INSERT INTO itensnota (numero, numeromercadoria, quantidade, valorunitario)
VALUES (1, 1, 5, 12);

--DEPARTAMENTO
INSERT INTO departamento (codigodepartamento, nome, cpf_chefe)
VALUES (1, 'TI', '12312');

--FUNCIONARIO
INSERT INTO funcionario (cpf, nome, telefone, logradouro, numero, complemento, cidade, estado, codigodepartamento)
VALUES ('12345', 'Joao', 12345, null, null, null, null, null, null);

-- CARGO

INSERT INTO cargo (codigo, descricao, salario_base)
VALUES (1, 'RH', 5000);
 
 INSERT INTO cargo (codigo, descricao, salario_base)
VALUES (2, 'Vendas', 10000);
 
 INSERT INTO cargo (codigo, descricao, salario_base)
VALUES (3, 'Marketing', 8000);
 
 INSERT INTO cargo (codigo, descricao, salario_base)
VALUES (4, 'Programador', 500000);

 INSERT INTO cargo (codigo, descricao, salario_base)
VALUES (5, 'DBA', 500000);
  
 --CARGOSFUNC
 INSERT INTO cargosfunc (cpf, codigocargo, datainicio, datafim)
VALUES ('12345', 1, null, null);

 --EMPRESAS
  INSERT INTO empresas (id, nome, endereco)
VALUES (1, 'Emp XX', null);

 --NOTASCOMPRA
  INSERT INTO notascompra (numero, dataemissao, fornecedorid)
VALUES (1, null, 1);

 --ITENSNOTACOMPRA
 INSERT INTO itensnotacompra (numero, numeroMercadoria, quantidade, valorunitario)
 VALUES (1, 1, 5, 12);

