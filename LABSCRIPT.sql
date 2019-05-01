DROP TABLE NotasVenda;
DROP TABLE ItensNota;
DROP TABLE Mercadorias;
DROP TABLE Cliente;
DROP TABLE Funcionario;
DROP TABLE CargosFunc;
DROP TABLE Departamento;
DROP TABLE Cargo;
DROP TABLE NotasCompra;
DROP TABLE ItensNotaCompra;
DROP TABLE Empresas;

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
DataaFim Date,

Primary key(CPF, CodigoCargo),
FOREIGN KEY (CPF) REFERENCES Funcionario(CPF),
FOREIGN KEY (CodigoCargo) REFERENCES Cargo(Codigo)
);

--CRIAR TABELA EMPRESAS

CREATE TABLE Empresas(
id integer Primary key,
Nome integer,
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
  ADD CPF varchar(15);
 -- FOREIGN KEY (CPF) REFERENCES ;
  

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
	end if;
Return new;
end;
$body$ language plpgsql;
	

CREATE TRIGGER pedido_estoque after INSERT or UPDATE
ON mercadorias FOR each row
EXECUTE PROCEDURE manda_email();

--ATUALIZA PREÇO 

CREATE FUNCTION atualiza_preco()
RETURNS TRIGGER
AS $$
BEGIN
	UPDATE	mercadorias
	SET		PrecoMin = NEW.PrecoMin
	WHERE 	numeroMercadoria = NEW.numeroMercadoria;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER atualiza_preco AFTER INSERT
ON itensNotaCompra
FOR EACH ROW
EXECUTE PROCEDURE atualiza_preco();

--VERIFICA PREÇO

CREATE FUNCTION verificaPreco()
RETURNS TRIGGER AS $body$
DECLARE valorMin int;
BEGIN
	SELECT 	PrecoMin
	INTO	valorMin
	FROM	mercadorias
	WHERE	NumeroMercadoria = NEW.numeroMercadoria;

	If NEW.valorUnitario < valorMin THEN
        RAISE EXCEPTION 'Valor Invalido';
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
	FROM	mercadorias;
	
	IF qtdEstoque < qtd THEN
		RAISE EXCEPTION 'Não há estoque suficiente';
	END IF;
RETURN new;
END;
$body$ language plpgsql;

CREATE TRIGGER verifica_estoque BEFORE INSERT or UPDATE
ON itensNota FOR EACH ROW
EXECUTE PROCEDURE verificaEstoque();

--VERIFICA ESTOQUE MAXIMO

CREATE FUNCTION verificaEstoqueMax()
returns TRIGGER AS $body$
DECLARE qtdEstoque, max integer
Begin
	SELECT 	QuantidadeEstoque, QuantidadeEstoqueMax
	INTO		qtdEstoque, max 
	FROM	mercadorias
	
	if qtdEstoque + NEW.Quantidade > max THEN
		RAISE EXCEPTION ‘'Ultrapassa estoque maximo';
	end if;
Return new;
end;
$body$ language plpgsql;

CREATE TRIGGER verifica_estoque_max BEFORE INSERT or UPDATE
ON itensNotaCompra FOR EACH ROW
EXECUTE PROCEDURE verificaEstoqueMax();